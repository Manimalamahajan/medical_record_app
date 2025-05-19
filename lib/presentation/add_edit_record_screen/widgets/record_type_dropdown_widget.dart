import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class RecordTypeDropdownWidget extends StatelessWidget {
  final String selectedRecordType;
  final List<String> recordTypes;
  final Function(String?) onChanged;

  const RecordTypeDropdownWidget({
    Key? key,
    required this.selectedRecordType,
    required this.recordTypes,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Record Type',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        SizedBox(height: 0.5.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline,
              width: 1,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedRecordType,
            decoration: InputDecoration(
              prefixIcon: CustomIconWidget(
                iconName: 'category',
                size: 22,
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            items: recordTypes.map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: onChanged,
            icon: Padding(
              padding: EdgeInsets.only(right: 2.w),
              child: CustomIconWidget(
                iconName: 'arrow_drop_down',
                size: 24,
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a record type';
              }
              return null;
            },
            isExpanded: true,
            dropdownColor: AppTheme.lightTheme.colorScheme.surface,
          ),
        ),
      ],
    );
  }
}