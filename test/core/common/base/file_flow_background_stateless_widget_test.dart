import 'package:fileflow/core/common/base/presentation/file_flow_background_stateless_widget.dart';
import 'package:fileflow/core/common/shapes/background_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

class _LifecycleRecorder {
  int onInitCalls = 0;
  int onVisibleCalls = 0;
  int onDisposeCalls = 0;
}

class _TestScreen extends FileFlowBackgroundStatelessWidget {
  final _LifecycleRecorder recorder;

  const _TestScreen(this.recorder);

  @override
  void onInit(BuildContext context) {
    recorder.onInitCalls++;
  }

  @override
  void onVisible(BuildContext context) {
    recorder.onVisibleCalls++;
  }

  @override
  void onDispose(BuildContext context) {
    recorder.onDisposeCalls++;
  }

  @override
  Widget buildContent(BuildContext context) {
    return const SizedBox.shrink();
  }
}

void main() {
  group('FileFlowBackgroundStatelessWidget lifecycle', () {
    testWidgets('onInit fires synchronously during build', (tester) async {
      final recorder = _LifecycleRecorder();

      await pumpApp(tester, _TestScreen(recorder));

      expect(recorder.onInitCalls, 1);
    });

    testWidgets('onVisible fires after the first frame', (tester) async {
      final recorder = _LifecycleRecorder();

      // onVisible is a synchronous WidgetsBinding.addPostFrameCallback body
      // (no internal `await`), so it already runs to completion within the
      // same pumpWidget call that triggers the first frame — unlike
      // FileFlowBackgroundState's onInitAsync, which suspends on an internal
      // `await` and needs an extra pump to resolve.
      await pumpApp(tester, _TestScreen(recorder));

      expect(recorder.onVisibleCalls, 1);
    });

    testWidgets('calling dispose(context) invokes onDispose', (tester) async {
      final recorder = _LifecycleRecorder();
      final widget = _TestScreen(recorder);

      await pumpApp(tester, widget);
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(SizedBox).first);
      widget.dispose(context);

      expect(recorder.onDisposeCalls, 1);
    });

    testWidgets('wraps buildContent in a CustomPaint using BackgroundPainter', (tester) async {
      final recorder = _LifecycleRecorder();

      await pumpApp(tester, _TestScreen(recorder));
      await tester.pumpAndSettle();

      final finder = find.byWidgetPredicate((widget) => widget is CustomPaint && widget.painter is BackgroundPainter);
      expect(finder, findsOneWidget);
    });
  });
}
