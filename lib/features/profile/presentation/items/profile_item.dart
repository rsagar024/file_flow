import 'package:fileflow/core/common/widgets/confirmation_dialog_widget.dart';
import 'package:fileflow/core/resources/common/string_constants.dart';
import 'package:fileflow/core/themes/app_colors.dart';
import 'package:fileflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fileflow/features/profile/presentation/screens/devices_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProfileItem {
  final String title;
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  ProfileItem({
    required this.title,
    required this.icon,
    this.color,
    required this.onTap,
  });
}

List<ProfileItem> buildProfileItems(BuildContext context) {
  return [
    ProfileItem(
      title: StringConstants.kEditProfile,
      icon: Icons.edit,
      onTap: () {},
    ),
    ProfileItem(
      title: StringConstants.kNotification,
      icon: Icons.notifications,
      onTap: () {},
    ),
    ProfileItem(
      title: StringConstants.kDevices,
      icon: Icons.devices,
      onTap: () => context.push(DevicesScreen.routeName),
    ),
    ProfileItem(
      title: StringConstants.kAppearance,
      icon: Icons.palette,
      onTap: () {},
    ),
    ProfileItem(
      title: StringConstants.kRecycleBin,
      icon: Icons.delete,
      onTap: () {},
    ),
    ProfileItem(
      title: StringConstants.kLogout,
      icon: Icons.logout,
      color: AppColors.error,
      onTap: () async {
        final confirmed = await ConfirmationDialogWidget.show(
          context,
          title: StringConstants.kLogout,
          message: StringConstants.kLogOutOfThisDeviceConfirmMessage,
          confirmText: StringConstants.kLogout,
        );
        if (confirmed && context.mounted) {
          context.read<AuthBloc>().add(const SignOutEvent());
        }
      },
    ),
  ];
}
