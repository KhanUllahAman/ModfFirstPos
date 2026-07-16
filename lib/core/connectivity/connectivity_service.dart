import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/shared/widgets/Snackbar/custom_snackbar.dart';


class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  final _connectionStatus = true.obs;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  
  bool _wasDisconnected = false;
  Timer? _snackbarTimer;

  bool get isConnected => _connectionStatus.value;

  /// Reactive connectivity status; sync/offline consumers can listen for
  /// transitions (e.g. to trigger an automatic sync when back online).
  Stream<bool> get statusStream => _connectionStatus.stream;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnection();
    _subscription = _connectivity.onConnectivityChanged.listen(
      (results) => _updateConnectionStatus(results.first),
    );
  }

  Future<void> _checkInitialConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results.first);
    } catch (e) {
      _connectionStatus.value = false;
    }
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    final bool isCurrentlyConnected = result != ConnectivityResult.none;
    
    if (_connectionStatus.value != isCurrentlyConnected) {
      _connectionStatus.value = isCurrentlyConnected;

      _snackbarTimer?.cancel();

      if (!isCurrentlyConnected) {
        _wasDisconnected = true;
        _showNoInternetSnackbar();
      } else if (_wasDisconnected) {
        _showInternetRestoredSnackbar();
        _wasDisconnected = false;
      }
    }
  }

  void _showNoInternetSnackbar() {
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }

    _snackbarTimer = Timer(const Duration(milliseconds: 300), () {
      customSnackBar(
        "No Internet Connection",
        "Please check your internet connection and try again",
        snackBarType: SnackBarType.error,
      );
    });
  }

  void _showInternetRestoredSnackbar() {
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }

    _snackbarTimer = Timer(const Duration(milliseconds: 300), () {
      customSnackBar(
        "Back Online",
        "Your internet connection has been restored",
        snackBarType: SnackBarType.success,
      );
    });
  }

  @override
  void onClose() {
    _snackbarTimer?.cancel();
    _subscription?.cancel();
    super.onClose();
  }
}