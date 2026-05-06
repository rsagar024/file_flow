import 'package:fileflow/core/common/base/presentation/file_flow_background_stateful_widget.dart';
import 'package:fileflow/core/common/widgets/file_flow_button.dart';
import 'package:fileflow/core/common/widgets/file_flow_text_field_widget.dart';
import 'package:fileflow/core/di/injection_container.dart';
import 'package:fileflow/core/enums/app_state/app_status.dart';
import 'package:fileflow/core/resources/common/string_constants.dart';
import 'package:fileflow/core/themes/app_colors.dart';
import 'package:fileflow/core/utilities/custom_snackbar.dart';
import 'package:fileflow/core/utilities/debug_logger.dart';
import 'package:fileflow/core/validator/validator.dart';
import 'package:fileflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fileflow/features/auth/presentation/widgets/profile_image_picker_widget.dart';
import 'package:fileflow/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CreateAccountScreen extends FileFlowBackgroundStatefulWidget {
  static const routeName = '/create-account';

  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends FileFlowBackgroundState<CreateAccountScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final authBloc = getIt<AuthBloc>();

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparent,
      appBar: AppBar(
        surfaceTintColor: AppColors.transparent,
        animateColor: false,
        automaticallyImplyLeading: true,
        backgroundColor: AppColors.transparent,
        title: const Text(
          StringConstants.kCreateAccount,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.white),
        ),
        centerTitle: true,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          if (state.status == AuthAppStatus.authenticated) {
            context.go(DashboardScreen.routeName);
          } else if (state.status == AuthAppStatus.failure) {
            printError(state.errorMessage ?? 'Unknown error');
            CustomSnackbar.show(
              context: context,
              message: state.errorMessage ?? 'Unknown error',
              type: SnackbarType.error,
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BlocBuilder<AuthBloc, AuthState>(
                          buildWhen: (prev, curr) => prev.imageUrl != curr.imageUrl,
                          builder: (context, state) {
                            return ProfileImagePickerWidget(
                              context: context,
                              imagePath: state.imageUrl,
                              onChanged: (value) {
                                if (value != null) {
                                  authBloc.add(UpdateProfileImageEvent(imagePath: value));
                                }
                              },
                              isEditing: true,
                            );
                          },
                        ),
                        const Align(
                          alignment: Alignment.center,
                          child: Column(
                            spacing: 3,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                StringConstants.kProfilePhoto,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.white),
                              ),
                              Text(
                                StringConstants.kPngJpgUpTo10MB,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          StringConstants.kFullName,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.white),
                        ),
                        FileFlowTextFieldWidget(
                          controller: authBloc.nameController,
                          hintText: StringConstants.kHintName,
                          keyboardType: TextInputType.text,
                          prefixIcon: const Icon(Icons.badge, color: AppColors.grey, size: 20),
                          margin: const EdgeInsets.only(top: 8, bottom: 20),
                          validator: Validator.validateFullName,
                        ),
                        const Text(
                          StringConstants.kUsername,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.white),
                        ),
                        FileFlowTextFieldWidget(
                          controller: authBloc.usernameController,
                          hintText: StringConstants.kHintUsername,
                          keyboardType: TextInputType.text,
                          prefixIcon: const Icon(Icons.perm_identity, color: AppColors.grey, size: 20),
                          margin: const EdgeInsets.only(top: 8, bottom: 20),
                          validator: Validator.validateUsername,
                        ),
                        const Text(
                          StringConstants.kEmailAddress,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.white),
                        ),
                        FileFlowTextFieldWidget(
                          controller: authBloc.emailController,
                          hintText: StringConstants.kHintEmailAddress,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_rounded, color: AppColors.grey, size: 20),
                          margin: const EdgeInsets.only(top: 8, bottom: 20),
                          validator: Validator.validateEmail,
                        ),
                        const Text(
                          StringConstants.kPhoneNumber,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.white),
                        ),
                        FileFlowTextFieldWidget(
                          controller: authBloc.phoneController,
                          hintText: StringConstants.kHintPhoneNumber,
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(Icons.phone, color: AppColors.grey, size: 20),
                          margin: const EdgeInsets.only(top: 8, bottom: 20),
                          enabled: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: MediaQuery.paddingOf(context).bottom),
        child: BlocSelector<AuthBloc, AuthState, bool>(
          selector: (state) => state.status == AuthAppStatus.loading,
          builder: (context, isLoading) {
            return FileFlowButton(
              text: StringConstants.kCreateAccount,
              textColor: AppColors.white,
              icon: const Icon(Icons.arrow_forward, color: AppColors.white),
              iconAlignment: IconAlignment.end,
              isLoading: isLoading,
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  authBloc.add(
                    CreateAccountEvent(
                      phoneNumber: authBloc.phoneController.text,
                      displayName: authBloc.nameController.text,
                      username: authBloc.usernameController.text,
                      email: authBloc.emailController.text,
                    ),
                  );
                } else {
                  printError('Not validate');
                }
              },
            );
          },
        ),
      ),
    );
  }
}
