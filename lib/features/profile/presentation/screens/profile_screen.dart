import 'package:cached_network_image/cached_network_image.dart';
import 'package:fileflow/core/common/base/presentation/file_flow_stateful_widget.dart';
import 'package:fileflow/core/common/widgets/file_flow_app_bar.dart';
import 'package:fileflow/core/resources/common/image_resources.dart';
import 'package:fileflow/core/resources/common/string_constants.dart';
import 'package:fileflow/core/themes/app_colors.dart';
import 'package:fileflow/core/themes/text_styles.dart';
import 'package:fileflow/features/auth/presentation/widgets/profile_image_picker_widget.dart';
import 'package:fileflow/features/profile/presentation/items/profile_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ProfileScreen extends FileFlowStatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends FileFlowState<ProfileScreen> {
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
                      imagePath: ImageResources.profileAvatarPlaceholderUrl,
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
                StringConstants.kSampleUserName,
                style: CustomTextStyles.custom18Bold.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
            // Username
            Padding(
              padding: const EdgeInsetsGeometry.fromLTRB(16, 0, 16, 5),
              child: Text(
                StringConstants.kSampleUsername,
                style: CustomTextStyles.custom16Regular.copyWith(
                  color: AppColors.white.withValues(alpha: 0.8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Options
            ...buildProfileItems(context).map((item) {
              return ListTile(
                leading: Icon(item.icon, color: item.color),
                title: Text(
                  item.title,
                  style: CustomTextStyles.custom16Regular.copyWith(
                    color: item.color,
                  ),
                ),
                onTap: item.onTap,
                trailing: item.title == StringConstants.kLightMode
                    ? Switch(value: false, onChanged: (value) {})
                    : null,
              );
            }),
          ],
        ),
      ),
    );
  }
}
