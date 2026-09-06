import 'package:fileflow/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class ProfileItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  ProfileItem({required this.title, required this.icon, this.color = AppColors.white, required this.onTap});
}

List<ProfileItem> profileItems = [
  ProfileItem(title: 'Edit Profile', icon: Icons.edit, onTap: () {}),
  ProfileItem(title: 'Notification', icon: Icons.notifications, onTap: () {}),
  ProfileItem(title: 'Devices', icon: Icons.devices, onTap: () {}),
  ProfileItem(title: 'Light Mode', icon: Icons.palette, onTap: () {}),
  ProfileItem(title: 'Recycle Bin', icon: Icons.delete, onTap: () {}),
  ProfileItem(title: 'Logout', icon: Icons.logout, color: Colors.red, onTap: () {}),
];
