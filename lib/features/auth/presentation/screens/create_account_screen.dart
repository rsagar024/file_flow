import 'package:fileflow/core/common/base/presentation/file_flow_background_stateful_widget.dart';
import 'package:fileflow/core/common/widgets/file_flow_button.dart';
import 'package:fileflow/core/common/widgets/file_flow_text_field_widget.dart';
import 'package:fileflow/core/di/injection_container.dart';
import 'package:fileflow/core/resources/common/string_constants.dart';
import 'package:fileflow/core/utilities/debug_logger.dart';
import 'package:fileflow/core/validator/validator.dart';
import 'package:fileflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateAccountScreen extends FileFlowBackgroundStatefulWidget {
  static const routeName = '/create-account';

  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends FileFlowBackgroundState<CreateAccountScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? selectedImage;
  final authBloc = getIt<AuthBloc>();

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        animateColor: false,
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
        title: const Text(
          StringConstants.kCreateAccount,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileImagePicker(
                      context: context,
                      imagePath: selectedImage,
                      onChanged: (value) {
                        setState(() {
                          selectedImage = value;
                        });
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
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                          Text(
                            StringConstants.kPngJpgUpTo10MB,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      StringConstants.kFullName,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFCBD5E1)),
                    ),
                    FileFlowTextFieldWidget(
                      controller: authBloc.nameController,
                      hintText: StringConstants.kHintName,
                      keyboardType: TextInputType.text,
                      prefixIcon: const Icon(Icons.badge, color: Colors.grey, size: 20),
                      margin: const EdgeInsets.only(top: 8, bottom: 20),
                      validator: Validator.validateFullName,
                    ),
                    const Text(
                      StringConstants.kUsername,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFCBD5E1)),
                    ),
                    FileFlowTextFieldWidget(
                      controller: authBloc.usernameController,
                      hintText: StringConstants.kHintUsername,
                      keyboardType: TextInputType.text,
                      prefixIcon: const Icon(Icons.perm_identity, color: Colors.grey, size: 20),
                      margin: const EdgeInsets.only(top: 8, bottom: 20),
                      validator: Validator.validateUsername,
                    ),
                    const Text(
                      StringConstants.kEmailAddress,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFCBD5E1)),
                    ),
                    FileFlowTextFieldWidget(
                      controller: authBloc.emailController,
                      hintText: StringConstants.kHintEmailAddress,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_rounded, color: Colors.grey, size: 20),
                      margin: const EdgeInsets.only(top: 8, bottom: 20),
                      validator: Validator.validateEmail,
                    ),
                    const Text(
                      StringConstants.kPhoneNumber,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFCBD5E1)),
                    ),
                    FileFlowTextFieldWidget(
                      controller: authBloc.phoneController,
                      hintText: StringConstants.kHintPhoneNumber,
                      keyboardType: TextInputType.phone,
                      prefixIcon: const Icon(Icons.phone, color: Colors.grey, size: 20),
                      margin: const EdgeInsets.only(top: 8, bottom: 20),
                      enabled: false,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: MediaQuery.paddingOf(context).bottom + 10),
        child: /*ElevatedButton.icon(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
            } else {
              printError('Not validate');
            }
          },
          label: const Text(
            StringConstants.kCreateAccount,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          icon: const Icon(Icons.arrow_forward, color: Colors.white),
          iconAlignment: IconAlignment.end,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: const Color(0xFF0062FF),
          ),
        ),*/ FileFlowButton(
          text: StringConstants.kCreateAccount,
          textColor: Colors.white,
          icon: const Icon(Icons.arrow_forward, color: Colors.white),
          iconAlignment: IconAlignment.end,
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
            } else {
              printError('Not validate');
            }
          },
        ),
      ),
    );
  }
}

class ProfileImagePicker extends FormField<String> {
  ProfileImagePicker({
    super.key,
    required BuildContext context,
    required String? imagePath,
    required ValueChanged<String?> onChanged,
  }) : super(
         initialValue: imagePath,
         validator: (value) {
           if (value == null || value.isEmpty) {
             return 'Profile image is required';
           }
           return null;
         },
         builder: (field) {
           final hasError = field.hasError;
           return Column(
             children: [
               Container(
                 height: 110,
                 width: double.infinity,
                 margin: const EdgeInsets.symmetric(vertical: 16),
                 child: Stack(
                   alignment: Alignment.center,
                   children: [
                     Container(
                       height: 100,
                       width: 100,
                       decoration: BoxDecoration(
                         shape: BoxShape.circle,
                         border: Border.all(color: hasError ? Colors.red : Colors.grey, width: 2),
                       ),
                       alignment: Alignment.center,
                       child: field.value == null
                           ? const Icon(Icons.person, size: 30, color: Colors.grey)
                           : ClipOval(child: Image.network(field.value!, fit: BoxFit.cover, width: 100, height: 100)),
                     ),
                     Positioned(
                       bottom: 10,
                       right: MediaQuery.sizeOf(context).width / 2 - 70,
                       child: GestureDetector(
                         onTap: () {
                           // 👇 replace with your image picker logic
                           const String pickedImage = 'dummy_path';

                           field.didChange(pickedImage); // ✅ update form
                           onChanged(pickedImage);
                         },
                         child: const CircleAvatar(
                           radius: 15,
                           backgroundColor: Colors.blue,
                           child: Icon(Icons.edit, size: 18, color: Colors.white),
                         ),
                       ),
                     ),
                   ],
                 ),
               ),
               if (hasError)
                 Padding(
                   padding: const EdgeInsets.only(top: 4),
                   child: Text(field.errorText!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                 ),
             ],
           );
         },
       );
}
