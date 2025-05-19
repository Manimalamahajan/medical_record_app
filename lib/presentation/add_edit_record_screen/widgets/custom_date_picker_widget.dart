import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class CustomDatePickerWidget extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onTap;

  const CustomDatePickerWidget({
    Key? key,
    required this.selectedDate,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        SizedBox(height: 0.5.h),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 1.5.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline,
                width: 1,
              ),
              color: AppTheme.lightTheme.colorScheme.surface,
            ),
            child: Row(
              children: [
                SizedBox(width: 3.w),
                CustomIconWidget(
                  iconName: 'calendar_today',
                  size: 22,
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 3.w),
                Text(
                  DateFormat('MMMM dd, yyyy').format(selectedDate),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.only(right: 3.w),
                  child: CustomIconWidget(
                    iconName: 'arrow_drop_down',
                    size: 24,
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}