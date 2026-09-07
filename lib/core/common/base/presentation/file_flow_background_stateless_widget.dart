import 'package:fileflow/core/common/shapes/background_painter.dart';
import 'package:fileflow/core/extensions/build_context_theme_extension.dart';
import 'package:fileflow/core/extensions/object_extension.dart';
import 'package:fileflow/core/utilities/dialog_manager.dart';
import 'package:flutter/material.dart';

abstract class FileFlowBackgroundStatelessWidget extends StatelessWidget {
  const FileFlowBackgroundStatelessWidget({super.key});

  @protected
  void onInit(BuildContext context) {}

  @protected
  void onDispose(BuildContext context) {}

  @protected
  void onVisible(BuildContext context) {}

  @protected
  void onInvisible(BuildContext context) {}

  @protected
  void logError(Object error, [StackTrace? stackTrace]) {
    'Error: $error'.printInConsole();
    if (stackTrace != null) {
      'Stack Trace: $stackTrace'.printInConsole();
    }
  }

  @override
  Widget build(BuildContext context) {
    onInit(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onVisible(context);
    });

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: CustomPaint(
        painter: BackgroundPainter(
          backgroundColor: context.colors.background,
          isDark: Theme.of(context).brightness == Brightness.dark,
        ),
        child: buildContent(context),
      ),
    );
  }

  @protected
  Widget buildContent(BuildContext context);

  void dispose(BuildContext context) {
    FocusScope.of(context).unfocus();
    DialogManager().hideTransparentProgressDialog();
    onDispose(context);
  }
}
