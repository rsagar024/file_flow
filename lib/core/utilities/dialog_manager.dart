import 'package:fileflow/core/themes/text_styles.dart';
import 'package:flutter/material.dart';

class DialogManager {
  static final DialogManager _instance = DialogManager._internal();

  factory DialogManager() => _instance;

  DialogManager._internal();

  OverlayEntry? _overlayEntry;

  void showTransparentProgressDialog(BuildContext context, {required String message}) {
    if (_overlayEntry != null) {
      hideTransparentProgressDialog();
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        child: Material(
          color: Colors.black.withValues(alpha: 0.5),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Colors.blueAccent),
                const SizedBox(height: 16),
                Text(message, style: CustomTextStyles.custom11Medium.copyWith(color: Colors.blueAccent)),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void hideTransparentProgressDialog() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }
}
