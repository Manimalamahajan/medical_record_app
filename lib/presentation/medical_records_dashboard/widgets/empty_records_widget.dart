import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/custom_image_widget.dart';

class EmptyRecordsWidget extends StatelessWidget {
  const EmptyRecordsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(5.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            CustomImageWidget(
              imageUrl: "https://img.freepik.com/free-vector/doctor-examining-patient-clinic-illustrated_23-2148856559.jpg",
              height: 30.h,
              width: 80.w,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 4.h),
            
            // Title
            Text(
              'No Medical Records Yet',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            
            // Description
            Text(
              'Start tracking your health journey by adding your first medical record.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            
            // Add record button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/add-edit-record-screen');
              },
              icon: const CustomIconWidget(
                iconName: 'add',
                size: 20,
                color: Colors.white,
              ),
              label: const Text('Add Your First Record'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
              ),
            ),
            SizedBox(height: 2.h),
            
            // Tips
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surfaceVariant.withAlpha(77),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline.withAlpha(77),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tips for Getting Started:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  _buildTipItem(
                    context,
                    'Add prescriptions, lab reports, and vaccination records',
                    'description',
                  ),
                  SizedBox(height: 1.h),
                  _buildTipItem(
                    context,
                    'Upload documents by taking photos or importing files',
                    'file_upload',
                  ),
                  SizedBox(height: 1.h),
                  _buildTipItem(
                    context,
                    'Tag records for easy searching and organization',
                    'tag',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(BuildContext context, String text, String iconName) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomIconWidget(
          iconName: iconName,
          size: 18,
          color: AppTheme.lightTheme.colorScheme.primary,
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}