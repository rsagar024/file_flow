import 'package:fileflow/core/common/base/presentation/file_flow_stateless_widget.dart';
import 'package:fileflow/core/extensions/build_context_theme_extension.dart';
import 'package:flutter/material.dart';

import '../../themes/app_colors.dart';

class FileFlowAppBar extends FileFlowStatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final Widget? trailing;
  final double? leadingWidth;

  const FileFlowAppBar({super.key, this.title, this.titleWidget, this.leading, this.trailing, this.leadingWidth})
    : assert(title != null || titleWidget != null, 'Either title or titleWidget must be provided');

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget buildContent(BuildContext context) {
    return AppBar(
      surfaceTintColor: AppColors.transparent,
      backgroundColor: AppColors.transparent,
      centerTitle: true,
      leadingWidth: leadingWidth ?? 76,
      titleSpacing: 0,
      actionsPadding: const EdgeInsets.only(right: 16),
      title:
          titleWidget ??
          Text(
            title ?? '',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600, color: context.colors.textPrimary),
          ),
      leading: leading != null ? Padding(padding: const EdgeInsets.only(left: 16), child: leading) : null,
      actions: trailing != null ? [trailing!] : null,
    );
  }
}
