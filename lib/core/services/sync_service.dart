import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:modfirstpos/core/connectivity/connectivity_service.dart';
import 'package:modfirstpos/core/network/api_endpoints.dart';
import 'package:modfirstpos/core/network/network_client.dart';
import 'package:modfirstpos/core/utils/json_utils.dart';
import 'package:modfirstpos/modules/customer/repository/customer_local_repository.dart';

/// Background synchronization engine.
///
/// Pushes locally created data (customers, sales) to the backend
/// automatically whenever connectivity is restored, and retries failed
/// pushes on a timer. All failures are swallowed and retried later — the
/// cashier is never blocked by sync.
class SyncService extends GetxService {
  final NetworkClient _client = NetworkClient();
  late final ConnectivityService _connectivity;

  StreamSubscription<bool>? _connectivitySub;
  Timer? _retryTimer;

  final RxBool isSyncing = false.obs;

  static const _retryInterval = Duration(minutes: 2);

  @override
  void onInit() {
    super.onInit();
    _connectivity = Get.find<ConnectivityService>();
    _connectivitySub = _connectivity.statusStream.listen((connected) {
      if (connected) syncNow();
    });
    _retryTimer = Timer.periodic(_retryInterval, (_) => syncNow());
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

  /// Runs a full push of unsynced local data. Safe to call at any time.
  Future<void> syncNow() async {
    if (isSyncing.value || !_connectivity.isConnected) return;
    isSyncing.value = true;
    try {
      await _pushLocalCustomers();
      // NOTE: pending_sales are NOT pushed anymore. Server orders are now
      // created through the checkout flow (orders/create + checkout APIs);
      // the local sales table is an offline ledger only. The old push used a
      // legacy body the backend rejects with 400 on every retry.
    } catch (e) {
      log('SyncService syncNow error: $e');
    } finally {
      isSyncing.value = false;
    }
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

}
