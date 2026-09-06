import 'package:fileflow/core/common/base/presentation/file_flow_stateless_widget.dart';
import 'package:fileflow/core/resources/common/string_constants.dart';
import 'package:fileflow/core/themes/app_colors.dart';
import 'package:fileflow/core/themes/text_styles.dart';
import 'package:fileflow/features/auth/domain/entities/device_entity.dart';
import 'package:flutter/material.dart';

class DeviceListItemWidget extends FileFlowStatelessWidget {
  final DeviceEntity device;
  final bool isCurrentDevice;
  final bool isLoggingOut;
  final VoidCallback? onLogout;

  const DeviceListItemWidget({
    super.key,
    required this.device,
    required this.isCurrentDevice,
    this.isLoggingOut = false,
    this.onLogout,
  });

  IconData get _platformIcon {
    switch (device.platform) {
      case 'android':
        return Icons.phone_android;
      case 'ios':
        return Icons.phone_iphone;
      default:
        return Icons.devices_other;
    }
  }

  String get _relativeLastActive {
    final dt = device.lastLoginAt;
    if (dt == null) return '';
    final diff = DateTime.now().toUtc().difference(dt.toUtc());
    if (diff.inMinutes < 1) return StringConstants.kActiveNow;
    if (diff.inMinutes < 60)
      return '${diff.inMinutes}${StringConstants.kMinutesAgoSuffix}';
    if (diff.inHours < 24)
      return '${diff.inHours}${StringConstants.kHoursAgoSuffix}';
    if (diff.inDays < 7)
      return '${diff.inDays}${StringConstants.kDaysAgoSuffix}';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget buildContent(BuildContext context) {
    final subtitleParts = <String>[
      if (device.deviceModel != null && device.deviceModel!.isNotEmpty)
        device.deviceModel!,
      _relativeLastActive,
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white12,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(_platformIcon, color: AppColors.white, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        device.deviceName?.isNotEmpty == true
                            ? device.deviceName!
                            : StringConstants.kUnknownDevice,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CustomTextStyles.custom14SemiBold.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    if (isCurrentDevice) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          StringConstants.kThisDevice,
                          style: CustomTextStyles.custom11Medium.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitleParts.where((p) => p.isNotEmpty).join(' • '),
                  style: CustomTextStyles.custom12Regular.copyWith(
                    color: AppColors.white54,
                  ),
                ),
              ],
            ),
          ),
          if (!isCurrentDevice)
            isLoggingOut
                ? const Padding(
                    padding: EdgeInsets.all(8),
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.error,
                      ),
                    ),
                  )
                : IconButton(
                    onPressed: onLogout,
                    icon: const Icon(Icons.logout, color: AppColors.error),
                    tooltip: StringConstants.kLogOutTooltip,
                  ),
        ],
      ),
    );
  }
}
