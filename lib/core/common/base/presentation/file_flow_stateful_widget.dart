import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fileflow/core/extensions/object_extension.dart';
import 'package:fileflow/core/routes/app_route.dart';
import 'package:fileflow/core/utilities/custom_snackbar.dart';
import 'package:fileflow/core/utilities/dialog_manager.dart';
import 'package:flutter/material.dart';

abstract class FileFlowStatefulWidget extends StatefulWidget {
  const FileFlowStatefulWidget({super.key});
}

abstract class FileFlowState<T extends FileFlowStatefulWidget> extends State<T> with WidgetsBindingObserver {
  late final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _wasConnected = true;

  @protected
  Future<void> onInitAsync() async {}

  @protected
  void onInit() {}

  @protected
  void onVisible() {}

  @protected
  void onInvisible() {}

  @protected
  void onDispose() {}

  @protected
  void onConnectivityChanged(bool isConnected) {}

  void _showConnectivityToast(bool isConnected) {
    CustomSnackbar.show(
      navigatorKey: AppRoute.navigatorKey,
      type: isConnected ? SnackbarType.success : SnackbarType.error,
      message: isConnected ? 'Back Online' : 'You\'re offline. Please connect to the internet.',
      persistent: !isConnected,
    );
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _handleConnectivityResult(result);
    } catch (e, stackTrace) {
      logError(e, stackTrace);
    }
  }

  void _handleConnectivityResult(List<ConnectivityResult> connectivityResult) {
    final isConnected = !connectivityResult.contains(ConnectivityResult.none);
    if (isConnected != _wasConnected) {
      _showConnectivityToast(isConnected);
      onConnectivityChanged(isConnected);
      _wasConnected = isConnected;
    }
  }

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    WidgetsBinding.instance.addObserver(this);

    onInit();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkConnectivity();
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
        _handleConnectivityResult(result);
      });

      await onInitAsync();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: buildContent(context),
    );
  }

  Widget buildContent(BuildContext context);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onVisible();
        _checkConnectivity();
        break;
      case AppLifecycleState.paused:
        onInvisible();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  @protected
  void logError(Object error, [StackTrace? stackTrace]) {
    'Error: $error'.printInConsole();
    if (stackTrace != null) {
      'Stack Trace: $stackTrace'.printInConsole();
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    FocusManager.instance.primaryFocus?.unfocus();
    DialogManager().hideTransparentProgressDialog();
    onDispose();
    super.dispose();
  }
}
