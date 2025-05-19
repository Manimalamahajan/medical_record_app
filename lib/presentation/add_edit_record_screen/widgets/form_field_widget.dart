import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class FormFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?)? validator;
  final String prefixIcon;
  final int maxLines;

  const FormFieldWidget({
    Key? key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.validator,
    required this.prefixIcon,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        SizedBox(height: 0.5.h),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: CustomIconWidget(
              iconName: prefixIcon,
              size: 22,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: maxLines > 1 ? 2.h : 0,
              horizontal: maxLines > 1 ? 4.w : 0,
            ),
          ),
          validator: validator,
          maxLines: maxLines,
          textInputAction: maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
        ),
      ],
    );
  }
}