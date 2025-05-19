import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class BiometricAuthWidget extends StatelessWidget {
  final VoidCallback onBiometricAuth;

  const BiometricAuthWidget({
    Key? key,
    required this.onBiometricAuth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(
          color: AppTheme.lightTheme.colorScheme.outline.withAlpha(128),
        ),
        SizedBox(height: 1.h),
        
        Text(
          'Or login with biometrics',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        
        SizedBox(height: 1.h),
        
        InkWell(
          onTap: onBiometricAuth,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.primary,
                width: 2,
              ),
            ),
            child: CustomIconWidget(
              iconName: 'fingerprint',
              size: 8.w,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}