import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class RecordMetadataWidget extends StatelessWidget {
  final Map<String, dynamic> recordData;

  const RecordMetadataWidget({
    Key? key,
    required this.recordData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 2.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Record Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 2.h),
            
            // Record type and date
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    context,
                    'Record Type',
                    recordData['recordType'] ?? 'Unknown',
                    'category',
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    context,
                    'Date',
                    _formatDate(recordData['date']),
                    'calendar_today',
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            
            // Doctor and facility
            _buildInfoItem(
              context,
              'Doctor',
              recordData['doctorName'] ?? 'Not specified',
              'person',
            ),
            SizedBox(height: 2.h),
            
            _buildInfoItem(
              context,
              'Facility',
              recordData['facilityName'] ?? 'Not specified',
              'local_hospital',
            ),
            SizedBox(height: 2.h),
            
            // Diagnosis/Notes
            if (recordData['diagnosis'] != null) ...[
              _buildInfoItem(
                context,
                'Diagnosis',
                recordData['diagnosis'],
                'medical_information',
                maxLines: 3,
              ),
              SizedBox(height: 2.h),
            ],
            
            if (recordData['notes'] != null && recordData['notes'].toString().isNotEmpty) ...[
              _buildInfoItem(
                context,
                'Notes',
                recordData['notes'],
                'note',
                maxLines: 5,
              ),
              SizedBox(height: 2.h),
            ],
            
            // Tags
            if (recordData['tags'] != null && (recordData['tags'] as List).isNotEmpty) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'tag',
                        size: 20,
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Tags',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Wrap(
                    spacing: 2.w,
                    runSpacing: 1.h,
                    children: (recordData['tags'] as List).map((tag) {
                      return Chip(
                        label: Text(tag.toString()),
                        backgroundColor: AppTheme.lightTheme.colorScheme.primary.withAlpha(26),
                        labelStyle: TextStyle(
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
            
            // Last updated info
            SizedBox(height: 2.h),
            Text(
              'Last updated: ${_formatDateTime(recordData['lastUpdated'])}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    String iconName, {
    int maxLines = 2,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: iconName,
              size: 20,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            SizedBox(width: 2.w),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        Padding(
          padding: EdgeInsets.only(left: 7.w),
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Not specified';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) return 'Unknown';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('MMM dd, yyyy hh:mm a').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }
}