import 'package:fileflow/core/themes/text_styles.dart';
import 'package:flutter/material.dart';

enum SnackbarType { error, warning, success }

class CustomSnackbar {
  static final List<OverlayEntry> _activeSnackbars = [];

  static void show({
    BuildContext? context,
    GlobalKey<NavigatorState>? navigatorKey,
    SnackbarType type = SnackbarType.success,
    required String message,
    Duration duration = const Duration(seconds: 2),
    String? actionLabel,
    VoidCallback? onAction,
    bool persistent = false,
  }) {
    assert(context != null || navigatorKey != null, 'Either context or navigatorKey must be provided.');

    final overlay = context != null ? Overlay.of(context) : navigatorKey!.currentState!.overlay!;

    _removeExistingSnackbar();

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).viewInsets.top,
        left: 0,
        right: 0,
        child: _SnackbarContentWidget(
          type: type,
          message: message,
          onDismissed: () => _removeSnackbar(overlayEntry),
          actionLabel: actionLabel,
          onAction: onAction,
        ),
      ),
    );

    _activeSnackbars.add(overlayEntry);
    overlay.insert(overlayEntry);

    if (!persistent) {
      Future.delayed(duration, () {
        if (_activeSnackbars.contains(overlayEntry)) {
          _removeSnackbar(overlayEntry);
        }
      });
    }
  }

  static void _removeExistingSnackbar() {
    for (var entry in _activeSnackbars) {
      entry.remove();
    }
    _activeSnackbars.clear();
  }

  static void _removeSnackbar(OverlayEntry entry) {
    entry.remove();
    _activeSnackbars.remove(entry);
  }
}

class _SnackbarContentWidget extends StatefulWidget {
  final SnackbarType type;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onDismissed;

  const _SnackbarContentWidget({
    required this.type,
    required this.message,
    this.actionLabel,
    this.onAction,
    required this.onDismissed,
  });

  @override
  State<_SnackbarContentWidget> createState() => _SnackbarContentWidgetState();
}

class _SnackbarContentWidgetState extends State<_SnackbarContentWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icon = _getIconForType(widget.type);
    final backgroundColor = _getBackgroundColorForType(widget.type);

    return SlideTransition(
      position: _slideAnimation,
      child: Dismissible(
        key: UniqueKey(),
        direction: DismissDirection.horizontal,
        onDismissed: (direction) => widget.onDismissed(),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16).copyWith(top: 46),
            decoration: BoxDecoration(color: backgroundColor),
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(widget.message, style: CustomTextStyles.custom14Regular.copyWith(color: Colors.white)),
                ),
                if (widget.actionLabel != null && widget.onAction != null)
                  TextButton(
                    onPressed: widget.onAction,
                    child: Text(
                      widget.actionLabel!,
                      style: CustomTextStyles.custom14Regular.copyWith(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(SnackbarType type) {
    switch (type) {
      case SnackbarType.error:
        return Icons.error_outline;
      case SnackbarType.warning:
        return Icons.warning_amber_outlined;
      case SnackbarType.success:
        return Icons.check_circle_outline;
    }
  }

  Color _getBackgroundColorForType(SnackbarType type) {
    switch (type) {
      case SnackbarType.error:
        return Colors.redAccent;
      case SnackbarType.warning:
        return Colors.yellowAccent;
      case SnackbarType.success:
        return Colors.greenAccent;
    }
  }
}
