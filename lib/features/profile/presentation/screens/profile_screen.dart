import 'package:fileflow/core/common/base/presentation/file_flow_stateful_widget.dart';
import 'package:fileflow/core/common/widgets/file_flow_app_bar.dart';
import 'package:fileflow/core/common/widgets/theme_mode_selector.dart';
import 'package:fileflow/core/common/widgets/user_avatar.dart';
import 'package:fileflow/core/extensions/build_context_theme_extension.dart';
import 'package:fileflow/core/resources/common/image_resources.dart';
import 'package:fileflow/core/resources/common/string_constants.dart';
import 'package:fileflow/core/themes/app_colors.dart';
import 'package:fileflow/core/themes/cubit/theme_cubit.dart';
import 'package:fileflow/core/themes/text_styles.dart';
import 'package:fileflow/core/themes/theme_reveal_controller.dart';
import 'package:fileflow/features/auth/domain/entities/user_entity.dart';
import 'package:fileflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fileflow/features/profile/presentation/items/profile_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class ProfileScreen extends FileFlowStatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends FileFlowState<ProfileScreen> with TickerProviderStateMixin {
  @override
  Widget buildContent(BuildContext context) {
    final user = context.watch<AuthBloc>().state.user;
    final items = buildProfileItems(context);
    final accountItems = items
        .where(
          (item) =>
              item.title == StringConstants.kEditProfile ||
              item.title == StringConstants.kNotification ||
              item.title == StringConstants.kDevices,
        )
        .toList();
    final preferenceItems = items.where((item) => item.title == StringConstants.kAppearance).toList();
    final otherItems = items
        .where((item) => item.title == StringConstants.kRecycleBin || item.title == StringConstants.kLogout)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.transparent,
      appBar: FileFlowAppBar(
        leading: SvgPicture.asset(ImageResources.iconLogo, height: 30),
        title: StringConstants.kProfile,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner with profile photo in middle
            SizedBox(
              height: 160,
              child: Stack(
                children: [
                  Container(
                    height: 100,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.topLeftCirclePrimary, AppColors.primary],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 50,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.colors.surface,
                        ),
                        child: UserAvatar(imageUrl: user?.photoUrl, displayName: user?.displayName),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Name
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 5, 16, 5),
              child: Text(
                user?.displayName ?? StringConstants.kSampleUserName,
                textAlign: TextAlign.center,
                style: CustomTextStyles.custom18Bold.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            // Username
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Text(
                user?.username != null ? '@${user!.username}' : StringConstants.kSampleUsername,
                textAlign: TextAlign.center,
                style: CustomTextStyles.custom16Regular.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ),
            if (user != null) _buildStorageCard(context, user),
            _buildSectionCard(context, title: StringConstants.kAccount, items: accountItems),
            _buildSectionCard(context, title: StringConstants.kPreferences, items: preferenceItems),
            _buildSectionCard(context, items: otherItems),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageCard(BuildContext context, UserEntity user) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cloud_outlined, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  StringConstants.kStorage,
                  style: CustomTextStyles.custom14SemiBold.copyWith(color: context.colors.textPrimary),
                ),
                const Spacer(),
                Text(
                  '${user.storageUsedFormatted} / ${user.storageLimitFormatted}',
                  style: CustomTextStyles.custom12Regular.copyWith(color: context.colors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (user.storageUsedPercentage / 100).clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: context.colors.background,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, {String? title, required List<ProfileItem> items}) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                title,
                style: CustomTextStyles.custom12SemiBold.copyWith(color: context.colors.textSecondary),
              ),
            ),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Material(
              type: MaterialType.canvas,
              color: context.colors.surfaceVariant,
              child: Column(
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    _buildItemRow(context, items[i]),
                    if (i != items.length - 1)
                      Divider(
                        height: 1,
                        indent: 56,
                        endIndent: 16,
                        color: context.colors.textSecondary.withValues(alpha: 0.12),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(BuildContext context, ProfileItem item) {
    final itemColor = item.color ?? context.colors.textPrimary;

    if (item.title == StringConstants.kAppearance) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(item.icon, color: itemColor),
                const SizedBox(width: 32),
                Text(
                  item.title,
                  style: CustomTextStyles.custom16Regular.copyWith(color: itemColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ThemeModeSelector(
              selectedMode: context.watch<ThemeCubit>().state.mode,
              onSelected: _onThemeModeSelected,
            ),
          ],
        ),
      );
    }

    return ListTile(
      leading: Icon(item.icon, color: itemColor),
      title: Text(
        item.title,
        style: CustomTextStyles.custom16Regular.copyWith(color: itemColor),
      ),
      trailing: item.title == StringConstants.kLogout
          ? null
          : Icon(Icons.chevron_right, color: context.colors.textSecondary),
      onTap: item.onTap,
    );
  }

  Brightness _resolveBrightness(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness;
    }
  }

  void _onThemeModeSelected(ThemeMode mode, Offset origin) {
    final themeCubit = context.read<ThemeCubit>();
    final currentBrightness = _resolveBrightness(themeCubit.state.mode);
    final newBrightness = _resolveBrightness(mode);

    if (currentBrightness == newBrightness) {
      themeCubit.updateMode(mode);
      return;
    }

    ThemeRevealController.instance.toggleWithReveal(
      context: context,
      origin: origin,
      vsync: this,
      applyNewTheme: () => themeCubit.updateMode(mode),
    );
  }
}
