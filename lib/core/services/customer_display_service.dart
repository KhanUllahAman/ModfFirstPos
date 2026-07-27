import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:get/get.dart';
import 'package:modfirstpos/core/utils/json_utils.dart';

/// Shared config between the cashier tab (client) and the customer-facing
/// tab (server) — both must agree on the port the pairing happens over.
class CustomerDisplayConfig {
  static const int port = 4040;
}

class CustomerDisplayItem {
  final String name;
  final int quantity;
  final double unitPrice;
  final double total;
  final String? imageUrl;

  CustomerDisplayItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'unit_price': unitPrice,
        'total': total,
        'image_url': imageUrl,
      };

  factory CustomerDisplayItem.fromJson(Map<String, dynamic> json) =>
      CustomerDisplayItem(
        name: JsonUtils.asString(json['name']),
        quantity: JsonUtils.asInt(json['quantity']),
        unitPrice: JsonUtils.asDouble(json['unit_price']),
        total: JsonUtils.asDouble(json['total']),
        imageUrl: JsonUtils.asStringOrNull(json['image_url']),
      );
}

/// Runs on the customer-facing tab. Listens on [CustomerDisplayConfig.port]
/// for the cashier tab to connect and push cart snapshots.
class CustomerDisplayServerService extends GetxService {
  HttpServer? _server;
  WebSocket? _activeSocket;

  final RxBool isRunning = false.obs;
  final RxBool hasClient = false.obs;

  final RxList<CustomerDisplayItem> items = <CustomerDisplayItem>[].obs;
  final RxDouble subtotal = 0.0.obs;
  final RxDouble discount = 0.0.obs;
  final RxDouble total = 0.0.obs;
  final RxString currencySymbol = '\$'.obs;
  final RxString storeName = ''.obs;

  Future<void> start() async {
    if (_server != null) return;
    try {
      _server = await HttpServer.bind(
        InternetAddress.anyIPv4,
        CustomerDisplayConfig.port,
      );
      isRunning.value = true;
      _server!.listen((request) async {
        if (WebSocketTransformer.isUpgradeRequest(request)) {
          final socket = await WebSocketTransformer.upgrade(request);
          _activeSocket = socket;
          hasClient.value = true;
          socket.listen(
            _handleMessage,
            onDone: () => hasClient.value = false,
            onError: (_) => hasClient.value = false,
            cancelOnError: true,
          );
        } else {
          request.response.statusCode = HttpStatus.forbidden;
          await request.response.close();
        }
      });
    } catch (e) {
      log('CustomerDisplayServerService start error: $e');
      isRunning.value = false;
    }
  }

  void _handleMessage(dynamic data) {
    try {
      final map = jsonDecode(data as String) as Map<String, dynamic>;
      switch (map['type']) {
        case 'cart_update':
          final rawItems = map['items'];
          items.assignAll(
            rawItems is List
                ? rawItems
                    .whereType<Map>()
                    .map(
                      (e) => CustomerDisplayItem.fromJson(
                        Map<String, dynamic>.from(e),
                      ),
                    )
                    .toList()
                : const [],
          );
          subtotal.value = JsonUtils.asDouble(map['subtotal']);
          discount.value = JsonUtils.asDouble(map['discount']);
          total.value = JsonUtils.asDouble(map['total']);
          final symbol = JsonUtils.asStringOrNull(map['currency_symbol']);
          if (symbol != null && symbol.isNotEmpty) currencySymbol.value = symbol;
          final store = JsonUtils.asStringOrNull(map['store_name']);
          if (store != null && store.isNotEmpty) storeName.value = store;
          break;
        case 'cart_clear':
          items.clear();
          subtotal.value = 0;
          discount.value = 0;
          total.value = 0;
          break;
      }
    } catch (e) {
      log('CustomerDisplayServerService _handleMessage error: $e');
    }
  }

  Future<void> stop() async {
    await _activeSocket?.close();
    await _server?.close(force: true);
    _server = null;
    _activeSocket = null;
    isRunning.value = false;
    hasClient.value = false;
  }

  @override
  void onClose() {
    stop();
    super.onClose();
  }
}

/// Runs on the cashier tab. Connects out to the customer tab's IP (from
/// Settings > Customer IP) and pushes cart snapshots as they change.
class CustomerDisplayClientService extends GetxService {
  WebSocket? _socket;
  String? _targetIp;

  final RxBool isConnected = false.obs;

  Future<void> connect(String ip) async {
    final target = ip.trim();
    if (target.isEmpty) return;
    if (_targetIp == target && isConnected.value) return;

    await disconnect();
    _targetIp = target;
    try {
      _socket = await WebSocket.connect(
        'ws://$target:${CustomerDisplayConfig.port}',
      ).timeout(const Duration(seconds: 4));
      isConnected.value = true;
      _socket!.listen(
        (_) {},
        onDone: () => isConnected.value = false,
        onError: (_) => isConnected.value = false,
        cancelOnError: true,
      );
    } catch (e) {
      log('CustomerDisplayClientService connect error ($target): $e');
      isConnected.value = false;
      _socket = null;
    }
  }

  void pushCartUpdate({
    required List<CustomerDisplayItem> items,
    required double subtotal,
    required double discount,
    required double total,
    String? currencySymbol,
    String? storeName,
  }) {
    final socket = _socket;
    if (socket == null || !isConnected.value) return;
    try {
      socket.add(
        jsonEncode({
          'type': 'cart_update',
          'items': items.map((e) => e.toJson()).toList(),
          'subtotal': subtotal,
          'discount': discount,
          'total': total,
          if (currencySymbol != null) 'currency_symbol': currencySymbol,
          if (storeName != null) 'store_name': storeName,
        }),
      );
    } catch (e) {
      log('CustomerDisplayClientService pushCartUpdate error: $e');
      isConnected.value = false;
    }
  }

  void pushClear() {
    final socket = _socket;
    if (socket == null || !isConnected.value) return;
    try {
      socket.add(jsonEncode({'type': 'cart_clear'}));
    } catch (e) {
      log('CustomerDisplayClientService pushClear error: $e');
      isConnected.value = false;
    }
  }

  Future<void> disconnect() async {
    await _socket?.close();
    _socket = null;
    isConnected.value = false;
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
