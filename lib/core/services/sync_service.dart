import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:modfirstpos/core/connectivity/connectivity_service.dart';
import 'package:modfirstpos/core/network/api_endpoints.dart';
import 'package:modfirstpos/core/network/network_client.dart';
import 'package:modfirstpos/core/utils/json_utils.dart';
import 'package:modfirstpos/modules/customer/repository/customer_local_repository.dart';
import 'package:modfirstpos/modules/order/repository/pending_order_repository.dart';
import 'package:modfirstpos/modules/shift/controller/shift_controller.dart';
import 'package:modfirstpos/modules/shift/repository/shift_local_repository.dart';

/// Summary of a push batch — synced + duplicates both count as "the server
/// now has it"; only failed rows stay queued for retry.
class SyncSummary {
  final int synced;
  final int duplicates;
  final int failed;

  const SyncSummary({this.synced = 0, this.duplicates = 0, this.failed = 0});

  int get total => synced + duplicates + failed;
}

/// Background synchronization engine.
///
/// Pushes locally created data (customers, shifts, orders) to the backend
/// automatically whenever connectivity is restored, and retries failed
/// pushes on a timer. All failures are swallowed and retried later — the
/// cashier is never blocked by sync.
class SyncService extends GetxService {
  final NetworkClient _client = NetworkClient();
  late final ConnectivityService _connectivity;

  StreamSubscription<bool>? _connectivitySub;
  Timer? _retryTimer;

  final RxBool isSyncing = false.obs;

  /// Total local rows (shifts + orders) still waiting to reach the server —
  /// drives the "Sync Pending" badge in the Menu screen.
  final RxInt pendingCount = 0.obs;

  // In-flight guards so a manual "Sync Now" tap and the automatic
  // connectivity/timer trigger can never push the same unsynced rows twice
  // concurrently (which the server would otherwise see as a real duplicate
  // POST and reject one of them on the unique client_reference constraint).
  Future<SyncSummary>? _shiftsPushInFlight;
  Future<SyncSummary>? _ordersPushInFlight;

  static const _retryInterval = Duration(minutes: 2);

  @override
  void onInit() {
    super.onInit();
    _connectivity = Get.find<ConnectivityService>();
    _connectivitySub = _connectivity.statusStream.listen((connected) {
      if (connected) syncNow();
    });
    _retryTimer = Timer.periodic(_retryInterval, (_) => syncNow());
    refreshPendingCount();
  }

  @override
  void onReady() {
    super.onReady();
    // Initial best-effort sync shortly after app start.
    syncNow();
  }

  @override
  void onClose() {
    _connectivitySub?.cancel();
    _retryTimer?.cancel();
    super.onClose();
  }

  /// Re-counts unsynced shifts + orders — call after any local write
  /// (open/close shift, offline sale) so the Menu badge stays live even
  /// before a sync attempt actually runs.
  Future<void> refreshPendingCount() async {
    try {
      final shifts = await ShiftLocalRepository.getUnsynced();
      final orders = await PendingOrderRepository.getUnsynced();
      pendingCount.value = shifts.length + orders.length;
    } catch (e) {
      log('SyncService refreshPendingCount error: $e');
    }
  }

  /// Runs a full push of unsynced local data. Safe to call at any time.
  Future<void> syncNow() async {
    if (isSyncing.value || !_connectivity.isConnected) return;
    isSyncing.value = true;
    try {
      await _pushLocalCustomers();
      await _pushPendingShifts();
      await _pushPendingOrders();
    } catch (e) {
      log('SyncService syncNow error: $e');
    } finally {
      isSyncing.value = false;
    }
  }

  /// Manual trigger for Menu > Sync Shifts (and the controller's
  /// best-effort post-open/close attempt). Returns a summary for the UI.
  Future<SyncSummary> syncShiftsNow() async {
    if (!_connectivity.isConnected) return const SyncSummary();
    return _pushPendingShifts();
  }

  /// Manual trigger for Menu > Sync Orders.
  Future<SyncSummary> syncOrdersNow() async {
    if (!_connectivity.isConnected) return const SyncSummary();
    return _pushPendingOrders();
  }

  Future<void> _pushLocalCustomers() async {
    final unsynced = await CustomerLocalRepository.getUnsynced();
    for (final row in unsynced) {
      if (!_connectivity.isConnected) return;
      final localId = JsonUtils.asInt(row['local_id']);
      try {
        final data = jsonDecode(row['data'] as String? ?? '{}');
        final customer = JsonUtils.asMap(data);
        final response = await _client.post(
          endpoint: ApiConstants.userCreateEndpoint,
          body: {
            'full_name': customer['full_name'],
            'phone': customer['phone'],
            if (customer['email'] != null) 'email': customer['email'],
            if (customer['address'] != null) 'address': customer['address'],
            'role': 'customer',
          },
          showErrorSnackbar: false,
        );
        final body = JsonUtils.asMap(response.data);
        if (JsonUtils.asBool(body['success'])) {
          final serverId =
              JsonUtils.asIntOrNull(JsonUtils.asMap(body['payload'])['id']);
          await CustomerLocalRepository.markSynced(localId, serverId: serverId);
          log('SyncService: customer $localId synced (server id $serverId)');
        }
      } catch (e) {
        // Leave unsynced; will retry on the next cycle.
        log('SyncService customer push failed ($localId): $e');
      }
    }
  }

  /// Wraps [_pushPendingShiftsInternal] so overlapping callers (auto timer +
  /// manual tap) share one in-flight request instead of each POSTing the
  /// same unsynced rows.
  Future<SyncSummary> _pushPendingShifts() {
    final existing = _shiftsPushInFlight;
    if (existing != null) return existing;
    final future = _pushPendingShiftsInternal();
    _shiftsPushInFlight = future;
    future.whenComplete(() => _shiftsPushInFlight = null);
    return future;
  }

  Future<SyncSummary> _pushPendingOrders() {
    final existing = _ordersPushInFlight;
    if (existing != null) return existing;
    final future = _pushPendingOrdersInternal();
    _ordersPushInFlight = future;
    future.whenComplete(() => _ordersPushInFlight = null);
    return future;
  }

  Future<SyncSummary> _pushPendingShiftsInternal() async {
    final rows = await ShiftLocalRepository.getUnsynced();
    if (rows.isEmpty) return const SyncSummary();

    try {
      final shiftsPayload =
          rows.map((r) => JsonUtils.asMap(jsonDecode(r['data'] as String))).toList();
      final response = await _client.post(
        endpoint: ApiConstants.posShiftSyncEndpoint,
        body: {'shifts': shiftsPayload},
        showErrorSnackbar: false,
      );
      final body = JsonUtils.asMap(response.data);
      final payload = JsonUtils.asMap(body['payload']);

      final rowsByClientRef = {
        for (final r in rows) r['client_reference'] as String: r,
      };

      var synced = 0;
      var duplicates = 0;

      for (final item in JsonUtils.asMap(payload)['synced'] as List? ?? []) {
        final map = JsonUtils.asMap(item);
        final row = rowsByClientRef[map['client_reference']];
        if (row == null) continue;
        await ShiftLocalRepository.markSynced(
          JsonUtils.asInt(row['local_id']),
          serverShiftId: JsonUtils.asInt(map['shift_id']),
          serverShiftCode: JsonUtils.asString(map['shift_code']),
        );
        synced++;
      }

      for (final item in JsonUtils.asMap(payload)['duplicates'] as List? ?? []) {
        final map = JsonUtils.asMap(item);
        final row = rowsByClientRef[map['client_reference']];
        if (row == null) continue;
        await ShiftLocalRepository.markSynced(
          JsonUtils.asInt(row['local_id']),
          serverShiftId: JsonUtils.asInt(map['shift_id']),
          serverShiftCode: JsonUtils.asString(map['shift_code']),
        );
        duplicates++;
      }

      var failed = 0;
      for (final item in JsonUtils.asMap(payload)['failed'] as List? ?? []) {
        final map = JsonUtils.asMap(item);
        final row = rowsByClientRef[map['client_reference']];
        if (row == null) continue;
        await ShiftLocalRepository.markFailed(
          JsonUtils.asInt(row['local_id']),
          JsonUtils.asString(map['error'] ?? map['message'] ?? 'Sync failed'),
        );
        failed++;
      }

      if ((synced + duplicates) > 0 && Get.isRegistered<ShiftController>()) {
        // The currently-displayed shift's id may have flipped from a local
        // placeholder to the real server id — refresh it.
        await Get.find<ShiftController>().checkCurrentShift();
      }

      log('SyncService: shifts sync -> $synced synced, $duplicates duplicate, $failed failed');
      await refreshPendingCount();
      return SyncSummary(synced: synced, duplicates: duplicates, failed: failed);
    } catch (e) {
      log('SyncService pushPendingShifts error: $e');
      return const SyncSummary();
    }
  }

  /// Builds the outgoing orders/pos/sync item from a stored row — always
  /// re-derived from the "local" contact-info snapshot rather than trusting
  /// whatever identity was baked into "sync" at creation time. A cached
  /// `user_id` can go stale (backend reset, account deleted) and the sync
  /// endpoint hard-fails with "User not found" instead of falling back, so
  /// every push re-identifies the customer by email/phone when we have it —
  /// this also self-heals previously-failed rows on their next retry.
  Map<String, dynamic> _resolveOrderSyncPayload(Map<String, dynamic> row) {
    final data = JsonUtils.asMap(jsonDecode(row['data'] as String));
    final sync = Map<String, dynamic>.from(JsonUtils.asMap(data['sync']));
    final local = JsonUtils.asMap(data['local']);

    final email = local['customer_email'];
    if (email is String && email.isNotEmpty) {
      sync.remove('user_id');
      sync['email'] = email;
      final phone = local['customer_phone'];
      if (phone is String && phone.isNotEmpty) sync['phone'] = phone;
      final name = local['customer_name'];
      if (name is String && name.isNotEmpty) sync['full_name'] = name;
    }

    return sync;
  }

  Future<SyncSummary> _pushPendingOrdersInternal() async {
    final rows = await PendingOrderRepository.getUnsynced();
    if (rows.isEmpty) return const SyncSummary();

    try {
      // Only the "sync" sub-object matches the orders/pos/sync body shape —
      // "local" carries receipt/printing data that never leaves the device.
      final ordersPayload = rows.map((r) => _resolveOrderSyncPayload(r)).toList();
      final response = await _client.post(
        endpoint: ApiConstants.orderPosSyncEndpoint,
        body: {'orders': ordersPayload},
        showErrorSnackbar: false,
      );
      final body = JsonUtils.asMap(response.data);
      final payload = JsonUtils.asMap(body['payload']);

      final rowsByClientRef = {
        for (final r in rows) r['client_reference'] as String: r,
      };

      var synced = 0;
      var duplicates = 0;

      for (final item in JsonUtils.asMap(payload)['synced'] as List? ?? []) {
        final map = JsonUtils.asMap(item);
        final row = rowsByClientRef[map['client_reference']];
        if (row == null) continue;
        await PendingOrderRepository.markSynced(
          JsonUtils.asInt(row['local_id']),
          serverOrderCode: JsonUtils.asStringOrNull(map['order_code']),
        );
        synced++;
      }

      for (final item in JsonUtils.asMap(payload)['duplicates'] as List? ?? []) {
        final map = JsonUtils.asMap(item);
        final row = rowsByClientRef[map['client_reference']];
        if (row == null) continue;
        await PendingOrderRepository.markSynced(
          JsonUtils.asInt(row['local_id']),
          serverOrderCode: JsonUtils.asStringOrNull(map['order_code']),
        );
        duplicates++;
      }

      var failed = 0;
      for (final item in JsonUtils.asMap(payload)['failed'] as List? ?? []) {
        final map = JsonUtils.asMap(item);
        final row = rowsByClientRef[map['client_reference']];
        if (row == null) continue;
        await PendingOrderRepository.markFailed(
          JsonUtils.asInt(row['local_id']),
          JsonUtils.asString(map['error'] ?? map['message'] ?? 'Sync failed'),
        );
        failed++;
      }

      log('SyncService: orders sync -> $synced synced, $duplicates duplicate, $failed failed');
      await refreshPendingCount();
      return SyncSummary(synced: synced, duplicates: duplicates, failed: failed);
    } catch (e) {
      log('SyncService pushPendingOrders error: $e');
      return const SyncSummary();
    }
  }
}
