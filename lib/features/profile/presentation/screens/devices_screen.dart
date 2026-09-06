import 'package:fileflow/core/common/base/presentation/file_flow_background_stateful_widget.dart';
import 'package:fileflow/core/common/widgets/confirmation_dialog_widget.dart';
import 'package:fileflow/core/common/widgets/file_flow_app_bar.dart';
import 'package:fileflow/core/common/widgets/file_flow_button.dart';
import 'package:fileflow/core/di/injection_container.dart';
import 'package:fileflow/core/resources/common/string_constants.dart';
import 'package:fileflow/core/themes/app_colors.dart';
import 'package:fileflow/core/themes/text_styles.dart';
import 'package:fileflow/core/utilities/custom_snackbar.dart';
import 'package:fileflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fileflow/features/profile/presentation/bloc/devices/devices_bloc.dart';
import 'package:fileflow/features/profile/presentation/widgets/device_list_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DevicesScreen extends FileFlowBackgroundStatefulWidget {
  static const routeName = '/devices';

  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends FileFlowBackgroundState<DevicesScreen> {
  @override
  Widget buildContent(BuildContext context) {
    final uid = context.read<AuthBloc>().state.user?.uid ?? '';

    return BlocProvider<DevicesBloc>(
      create: (_) =>
          getIt<DevicesBloc>()..add(DevicesSubscribeRequested(uid: uid)),
      child: Scaffold(
        backgroundColor: AppColors.transparent,
        appBar: FileFlowAppBar(
          title: StringConstants.kDevices,
          leading: IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
          ),
        ),
        body: BlocConsumer<DevicesBloc, DevicesState>(
          listenWhen: (previous, current) =>
              previous.errorMessage != current.errorMessage,
          listener: (context, state) {
            if (state.errorMessage != null) {
              CustomSnackbar.show(
                context: context,
                type: SnackbarType.error,
                message: state.errorMessage!,
              );
            }
          },
          builder: (context, state) {
            if (state.status == DevicesStatus.loading ||
                state.status == DevicesStatus.initial) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state.devices.isEmpty) {
              return Center(
                child: Text(
                  StringConstants.kNoDevicesFound,
                  style: CustomTextStyles.custom14Regular.copyWith(
                    color: AppColors.white54,
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.devices.length,
                      itemBuilder: (context, index) {
                        final device = state.devices[index];
                        final isCurrentDevice =
                            device.deviceId == state.currentDeviceId;
                        return DeviceListItemWidget(
                          device: device,
                          isCurrentDevice: isCurrentDevice,
                          isLoggingOut:
                              state.actionInProgressDeviceId == device.deviceId,
                          onLogout: isCurrentDevice
                              ? null
                              : () async {
                                  final confirmed = await ConfirmationDialogWidget.show(
                                    context,
                                    title: StringConstants.kLogOutDevice,
                                    message:
                                        '${StringConstants.kLogOutDeviceConfirmMessagePrefix}'
                                        '${device.deviceName ?? StringConstants.kThisDeviceFallbackName}'
                                        '${StringConstants.kLogOutDeviceConfirmMessageSuffix}',
                                    confirmText: StringConstants.kLogout,
                                  );
                                  if (confirmed && context.mounted) {
                                    context.read<DevicesBloc>().add(
                                      DevicesLogoutOneRequested(
                                        deviceId: device.deviceId ?? '',
                                      ),
                                    );
                                  }
                                },
                        );
                      },
                    ),
                  ),
                  if (state.otherDevices.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: FileFlowButton(
                        text: StringConstants.kLogOutAllOtherDevicesButton,
                        backgroundColor: AppColors.error,
                        isLoading: state.isLogoutAllInProgress,
                        onPressed: () async {
                          final confirmed = await ConfirmationDialogWidget.show(
                            context,
                            title: StringConstants.kLogOutAllOtherDevicesTitle,
                            message:
                                StringConstants.kLogOutAllOtherDevicesMessage,
                            confirmText: StringConstants.kLogoutAll,
                          );
                          if (confirmed && context.mounted) {
                            context.read<DevicesBloc>().add(
                              const DevicesLogoutAllOthersRequested(),
                            );
                          }
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
