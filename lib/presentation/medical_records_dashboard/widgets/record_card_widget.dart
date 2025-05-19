import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class RecordCardWidget extends StatelessWidget {
  final Map<String, dynamic> record;
  final VoidCallback onTap;

  const RecordCardWidget({
    Key? key,
    required this.record,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateTime recordDate = DateTime.parse(record['date'] as String);
    final String formattedDate = DateFormat('MMM dd, yyyy').format(recordDate);
    final Color recordColor = record['color'] as Color? ?? AppTheme.primary;
    final String recordType = record['recordType'] as String;
    
    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppTheme.lightTheme.colorScheme.outline.withAlpha(77),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Record type icon
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: recordColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: _getIconForRecordType(recordType),
                        size: 24,
                        color: recordColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  
                  // Record details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record['title'] as String,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h),
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'calendar_today',
                              size: 14,
                              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              formattedDate,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        SizedBox(height: 0.5.h),
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'person',
                              size: 14,
                              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                            ),
                            SizedBox(width: 1.w),
                            Expanded(
                              child: Text(
                                record['doctorName'] as String,
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 2.h),
              
              // Record type tag and file indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Record type tag
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: recordColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      recordType,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: recordColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  // File indicator
                  if (record['fileUrl'] != null)
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: _getFileIconName(record['fileUrl'] as String),
                          size: 16,
                          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          'View Document',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              
              // Tags
              if ((record['tags'] as List).isNotEmpty) ...[
                SizedBox(height: 1.5.h),
                Wrap(
                  spacing: 2.w,
                  runSpacing: 1.h,
                  children: (record['tags'] as List).map<Widget>((tag) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surfaceVariant.withAlpha(128),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '#${tag as String}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getIconForRecordType(String recordType) {
    switch (recordType) {
      case 'Lab Report':
        return 'science';
      case 'Prescription':
        return 'medication';
      case 'Vaccination':
        return 'vaccines';
      case 'Imaging':
        return 'image';
      case 'Surgery':
        return 'medical_services';
      case 'Consultation':
        return 'person_search';
      case 'Insurance':
        return 'health_and_safety';
      default:
        return 'description';
    }
  }

  String _getFileIconName(String fileUrl) {
    if (fileUrl.toLowerCase().endsWith('.pdf')) {
      return 'picture_as_pdf';
    } else if (fileUrl.toLowerCase().endsWith('.jpg') || 
               fileUrl.toLowerCase().endsWith('.jpeg') || 
               fileUrl.toLowerCase().endsWith('.png')) {
      return 'image';
    } else {
      return 'insert_drive_file';
    }
  }
}