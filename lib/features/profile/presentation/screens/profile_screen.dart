import 'package:cached_network_image/cached_network_image.dart';
import 'package:fileflow/core/common/base/presentation/file_flow_stateful_widget.dart';
import 'package:fileflow/core/common/widgets/file_flow_app_bar.dart';
import 'package:fileflow/core/common/widgets/theme_mode_selector.dart';
import 'package:fileflow/core/extensions/build_context_theme_extension.dart';
import 'package:fileflow/core/resources/common/image_resources.dart';
import 'package:fileflow/core/resources/common/string_constants.dart';
import 'package:fileflow/core/themes/app_colors.dart';
import 'package:fileflow/core/themes/cubit/theme_cubit.dart';
import 'package:fileflow/core/themes/text_styles.dart';
import 'package:fileflow/core/themes/theme_reveal_controller.dart';
import 'package:fileflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fileflow/features/auth/presentation/widgets/profile_image_picker_widget.dart';
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
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(
        const CachedNetworkImageProvider(ImageResources.profileBannerUrl),
        context,
      );
    });
  }

  @override
  Widget buildContent(BuildContext context) {
    final user = context.watch<AuthBloc>().state.user;

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
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(
                          ImageResources.profileBannerUrl,
                        ),
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 25,
                    child: ProfileImagePickerWidget(
                      context: context,
                      imagePath: user?.photoUrl ?? ImageResources.profileAvatarPlaceholderUrl,
                      onChanged: (value) {},
                      isEditing: false,
                    ),
                  ),
                ],
              ),
            ),
            // Name
            Padding(
              padding: const EdgeInsetsGeometry.fromLTRB(16, 5, 16, 5),
              child: Text(
                user?.displayName ?? StringConstants.kSampleUserName,
                style: CustomTextStyles.custom18Bold.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            // Username
            Padding(
              padding: const EdgeInsetsGeometry.fromLTRB(16, 0, 16, 5),
              child: Text(
                user?.username != null ? '@${user!.username}' : StringConstants.kSampleUsername,
                style: CustomTextStyles.custom16Regular.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Options
            ...buildProfileItems(context).map((item) {
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
                  style: CustomTextStyles.custom16Regular.copyWith(
                    color: itemColor,
                  ),
                ),
                onTap: item.onTap,
              );
            }),
          ],
        ),
      ),
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
