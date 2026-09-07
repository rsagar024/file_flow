import 'package:fileflow/core/extensions/build_context_theme_extension.dart';
import 'package:fileflow/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class FileFlowTextFieldWidget extends FormField<String> {
  FileFlowTextFieldWidget({
    super.key,
    EdgeInsetsGeometry? margin,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    Widget? prefixIcon,
    Widget? suffixIcon,
    TextEditingController? controller,
    bool obscureText = false,
    TextStyle? textStyle,
    TextStyle? hintStyle,
    Color? cursorColor,
    bool readOnly = false,
    bool enabled = true,
    int maxLines = 1,
    int minLines = 1,
    FocusNode? focusNode,
    super.validator,
    ValueChanged<String>? onChanged,
    VoidCallback? onTap,
  }) : super(
         initialValue: controller?.text,
         builder: (field) {
           final hasError = field.hasError;
           final colors = field.context.colors;

           return Padding(
             padding: margin ?? EdgeInsets.zero,
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 TextField(
                   controller: controller,
                   keyboardType: keyboardType,
                   maxLength: maxLength,
                   obscureText: obscureText,
                   readOnly: readOnly,
                   enabled: enabled,
                   focusNode: focusNode,
                   style:
                       textStyle ??
                       TextStyle(
                         fontSize: 15,
                         fontWeight: FontWeight.w500,
                         color: enabled ? colors.textPrimary : colors.disabled,
                       ),
                   cursorColor: cursorColor ?? colors.textPrimary,
                   onTap: onTap,
                   onChanged: (value) {
                     field.didChange(value); // 👈 important
                     if (onChanged != null) onChanged(value);
                   },
                   decoration: InputDecoration(
                     hintText: hintText,
                     hintStyle: hintStyle ?? TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: colors.textTertiary),
                     counterText: '',
                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                     prefixIcon: prefixIcon,
                     suffixIcon: suffixIcon,
                     errorText: null,
                     focusedBorder: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(12),
                       borderSide: BorderSide(color: hasError ? AppColors.red : colors.textPrimary, width: 2),
                     ),
                     enabledBorder: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(12),
                       borderSide: BorderSide(color: hasError ? AppColors.red : AppColors.grey),
                     ),
                     disabledBorder: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(12),
                       borderSide: const BorderSide(color: AppColors.grey),
                     ),
                     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                   ),
                 ),

                 // 👇 Custom error below
                 if (field.hasError) ...[
                   const SizedBox(height: 6),
                   Text(field.errorText ?? '', style: const TextStyle(color: AppColors.red, fontSize: 12)),
                 ],
               ],
             ),
           );
         },
       );
}
