import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fileflow/core/common/base/presentation/file_flow_stateful_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

class _LifecycleRecorder {
  int onInitCalls = 0;
  int onInitAsyncCalls = 0;
  int onDisposeCalls = 0;
  final List<bool> connectivityChanges = [];
}

class _TestScreen extends FileFlowStatefulWidget {
  final _LifecycleRecorder recorder;

  const _TestScreen(this.recorder);

  @override
  State<_TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends FileFlowState<_TestScreen> {
  @override
  void onInit() {
    widget.recorder.onInitCalls++;
  }

  @override
  Future<void> onInitAsync() async {
    widget.recorder.onInitAsyncCalls++;
  }

  @override
  void onConnectivityChanged(bool isConnected) {
    widget.recorder.connectivityChanges.add(isConnected);
  }

  @override
  void onDispose() {
    widget.recorder.onDisposeCalls++;
  }

  @override
  Widget buildContent(BuildContext context) {
    return const SizedBox.shrink();
  }
}

void main() {
  group('FileFlowStatefulWidget/FileFlowState lifecycle', () {
    testWidgets('onInit fires synchronously and onInitAsync fires after the first frame', (tester) async {
      final recorder = _LifecycleRecorder();

      await pumpApp(tester, _TestScreen(recorder));

      expect(recorder.onInitCalls, 1);

      await tester.pumpAndSettle();

      expect(recorder.onInitAsyncCalls, 1);
    });

    testWidgets('connectivity changes trigger onConnectivityChanged and a snackbar', (tester) async {
      final recorder = _LifecycleRecorder();

      final fakeConnectivity = await pumpApp(tester, _TestScreen(recorder));
      await tester.pumpAndSettle();

      fakeConnectivity.emit([ConnectivityResult.none]);
      await tester.pumpAndSettle();

      expect(recorder.connectivityChanges, [false]);
      expect(find.textContaining('offline'), findsOneWidget);

      fakeConnectivity.emit([ConnectivityResult.wifi]);
      await tester.pumpAndSettle();

      expect(recorder.connectivityChanges, [false, true]);
      expect(find.text('Back Online'), findsOneWidget);

      // Flush the non-persistent "Back Online" snackbar's auto-dismiss timer
      // so no Timer is left pending when the test tears down.
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('removing the widget from the tree triggers onDispose', (tester) async {
      final recorder = _LifecycleRecorder();

      await pumpApp(tester, _TestScreen(recorder));
      await tester.pumpAndSettle();

      await tester.pumpWidget(const SizedBox());

      expect(recorder.onDisposeCalls, 1);
    });
  });
}
