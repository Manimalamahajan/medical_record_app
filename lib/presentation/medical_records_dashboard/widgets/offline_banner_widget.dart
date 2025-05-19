import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class OfflineBannerWidget extends StatelessWidget {
  const OfflineBannerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
      color: AppTheme.warning.withAlpha(26),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'wifi_off',
            size: 18,
            color: AppTheme.warning,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              'You\'re offline. Showing cached records.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.warning,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}