import 'dart:async';

import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';

/// A controllable fake for [ConnectivityPlatform], used to avoid touching the
/// real connectivity_plus platform channel in widget tests. Install it via
/// [install] before pumping any widget that extends `FileFlowState`/
/// `FileFlowBackgroundState` (both call `Connectivity().checkConnectivity()`
/// and subscribe to `Connectivity().onConnectivityChanged` on init).
class FakeConnectivityPlatform extends ConnectivityPlatform {
  FakeConnectivityPlatform({
    List<ConnectivityResult> initialResult = const [ConnectivityResult.wifi],
  }) : nextCheckResult = initialResult;

  List<ConnectivityResult> nextCheckResult;

  final StreamController<List<ConnectivityResult>> _controller = StreamController<List<ConnectivityResult>>.broadcast();

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => nextCheckResult;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => _controller.stream;

  /// Simulates a connectivity change event.
  void emit(List<ConnectivityResult> result) {
    nextCheckResult = result;
    _controller.add(result);
  }

  void dispose() {
    unawaited(_controller.close());
  }

  /// Installs a fresh instance as the platform singleton and returns it.
  static FakeConnectivityPlatform install({
    List<ConnectivityResult> initialResult = const [ConnectivityResult.wifi],
  }) {
    final fake = FakeConnectivityPlatform(initialResult: initialResult);
    ConnectivityPlatform.instance = fake;
    return fake;
  }
}
