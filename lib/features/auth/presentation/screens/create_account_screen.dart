import 'package:fileflow/core/common/base/presentation/file_flow_background_stateful_widget.dart';
import 'package:fileflow/core/common/widgets/file_flow_button.dart';
import 'package:fileflow/core/common/widgets/file_flow_text_field_widget.dart';
import 'package:fileflow/core/di/injection_container.dart';
import 'package:fileflow/core/enums/app_state/app_status.dart';
import 'package:fileflow/core/extensions/build_context_theme_extension.dart';
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
  static const editRouteName = '/edit-profile';

  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends FileFlowBackgroundState<CreateAccountScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final authBloc = getIt<AuthBloc>();
  late final bool isEditMode;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final currentState = authBloc.state;
    isEditMode = currentState.user != null;
    phoneController.text = currentState.user?.phoneNumber ?? currentState.phoneNumber ?? '';
    nameController.text = currentState.user?.displayName ?? '';
    usernameController.text = currentState.user?.username ?? '';
    emailController.text = currentState.user?.email ?? '';
  }

  @override
  void dispose() {
    phoneController.dispose();
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparent,
      appBar: AppBar(
        surfaceTintColor: AppColors.transparent,
        animateColor: false,
        automaticallyImplyLeading: true,
        backgroundColor: AppColors.transparent,
        title: Text(
          isEditMode ? StringConstants.kEditProfile : StringConstants.kCreateAccount,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: context.colors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          if (state.status == AuthAppStatus.authenticated) {
            context.go(DashboardScreen.routeName);
          } else if (state.status == AuthAppStatus.profileUpdateSuccess) {
            CustomSnackbar.show(
              context: context,
              message: StringConstants.kProfileUpdated,
              type: SnackbarType.success,
            );
            Navigator.of(context).maybePop();
          } else if (state.status == AuthAppStatus.failure ||
              state.status == AuthAppStatus.profileUpdateFailure) {
            printError(state.errorMessage ?? 'Unknown error');
            CustomSnackbar.show(
              context: context,
              message: state.errorMessage ?? StringConstants.kFailedToUpdateProfile,
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
                              imagePath: state.imageUrl ?? state.user?.photoUrl,
                              onChanged: (value) {
                                if (value != null) {
                                  authBloc.add(UpdateProfileImageEvent(imagePath: value));
                                }
                              },
                              isEditing: true,
                            );
                          },
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            spacing: 3,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                StringConstants.kProfilePhoto,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.colors.textPrimary),
                              ),
                              Text(
                                StringConstants.kPngJpgUpTo10MB,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: context.colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          StringConstants.kFullName,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: context.colors.textPrimary),
                        ),
                        FileFlowTextFieldWidget(
                          controller: nameController,
                          hintText: StringConstants.kHintName,
                          keyboardType: TextInputType.text,
                          prefixIcon: const Icon(Icons.badge, color: AppColors.grey, size: 20),
                          margin: const EdgeInsets.only(top: 8, bottom: 20),
                          validator: Validator.validateFullName,
                        ),
                        Text(
                          StringConstants.kUsername,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: context.colors.textPrimary),
                        ),
                        FileFlowTextFieldWidget(
                          controller: usernameController,
                          hintText: StringConstants.kHintUsername,
                          keyboardType: TextInputType.text,
                          prefixIcon: const Icon(Icons.perm_identity, color: AppColors.grey, size: 20),
                          margin: const EdgeInsets.only(top: 8, bottom: 20),
                          validator: Validator.validateUsername,
                        ),
                        Text(
                          StringConstants.kEmailAddress,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: context.colors.textPrimary),
                        ),
                        FileFlowTextFieldWidget(
                          controller: emailController,
                          hintText: StringConstants.kHintEmailAddress,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_rounded, color: AppColors.grey, size: 20),
                          margin: const EdgeInsets.only(top: 8, bottom: 20),
                          validator: Validator.validateEmail,
                        ),
                        Text(
                          StringConstants.kPhoneNumber,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: context.colors.textPrimary),
                        ),
                        FileFlowTextFieldWidget(
                          controller: phoneController,
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
          selector: (state) =>
              state.status == AuthAppStatus.loading || state.status == AuthAppStatus.profileUpdating,
          builder: (context, isLoading) {
            return FileFlowButton(
              text: isEditMode ? StringConstants.kSaveChanges : StringConstants.kCreateAccount,
              textColor: AppColors.white,
              icon: isEditMode ? null : const Icon(Icons.arrow_forward, color: AppColors.white),
              iconAlignment: IconAlignment.end,
              isLoading: isLoading,
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  if (isEditMode) {
                    authBloc.add(
                      UpdateProfileDetailsEvent(
                        displayName: nameController.text.trim(),
                        username: usernameController.text.trim(),
                        email: emailController.text.trim(),
                        photoUrl: authBloc.state.imageUrl,
                      ),
                    );
                  } else {
                    authBloc.add(
                      CreateAccountEvent(
                        phoneNumber: phoneController.text,
                        displayName: nameController.text,
                        username: usernameController.text,
                        email: emailController.text,
                      ),
                    );
                  }
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
