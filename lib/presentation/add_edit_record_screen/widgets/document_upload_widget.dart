import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/custom_image_widget.dart';

class DocumentUploadWidget extends StatelessWidget {
  final Function(File) onFileSelected;
  final String? existingFileUrl;
  final File? selectedFile;

  const DocumentUploadWidget({
    Key? key,
    required this.onFileSelected,
    this.existingFileUrl,
    this.selectedFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool hasFile = selectedFile != null || existingFileUrl != null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload Document',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Upload a PDF, JPG, or PNG file (max 10MB)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SizedBox(height: 2.h),
                
                // File Preview or Upload Buttons
                if (hasFile)
                  _buildFilePreview(context)
                else
                  _buildUploadButtons(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePreview(BuildContext context) {
    String fileName = '';
    Widget previewWidget;
    
    if (selectedFile != null) {
      fileName = selectedFile!.path.split('/').last;
      
      if (fileName.toLowerCase().endsWith('.pdf')) {
        previewWidget = Container(
          height: 15.h,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.primary.withAlpha(26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'picture_as_pdf',
                  size: 40,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
                SizedBox(height: 1.h),
                Text(
                  'PDF Document',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );
      } else {
        // Image preview for JPG, PNG
        previewWidget = ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            selectedFile!,
            height: 15.h,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      }
    } else if (existingFileUrl != null) {
      fileName = existingFileUrl!.split('/').last;
      
      if (existingFileUrl!.toLowerCase().endsWith('.pdf')) {
        previewWidget = Container(
          height: 15.h,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.primary.withAlpha(26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'picture_as_pdf',
                  size: 40,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
                SizedBox(height: 1.h),
                Text(
                  'PDF Document',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );
      } else {
        // Network image preview
        previewWidget = ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CustomImageWidget(
            imageUrl: existingFileUrl!,
            height: 15.h,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      }
    } else {
      // Fallback (should not happen)
      previewWidget = Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        previewWidget,
        SizedBox(height: 1.h),
        Row(
          children: [
            Expanded(
              child: Text(
                fileName,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showUploadOptions(context),
              icon: const CustomIconWidget(
                iconName: 'refresh',
                size: 18,
              ),
              label: const Text('Change'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUploadButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _captureImage(context),
            icon: const CustomIconWidget(
              iconName: 'camera_alt',
              size: 20,
            ),
            label: const Text('Camera'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickFile(context),
            icon: const CustomIconWidget(
              iconName: 'upload_file',
              size: 20,
            ),
            label: const Text('Browse'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
            ),
          ),
        ),
      ],
    );
  }

  void _showUploadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Upload Document',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'camera_alt',
                size: 24,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                _captureImage(context);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'upload_file',
                size: 24,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              title: const Text('Choose file'),
              onTap: () {
                Navigator.pop(context);
                _pickFile(context);
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _captureImage(BuildContext context) {
    // Simulate camera capture
    // In a real app, you would use image_picker package
    _simulateFileSelection(context, 'camera_image.jpg');
  }

  void _pickFile(BuildContext context) {
    // Simulate file picking
    // In a real app, you would use file_picker package
    _simulateFileSelection(context, 'medical_report.pdf');
  }

  void _simulateFileSelection(BuildContext context, String fileName) {
    // Create a temporary file for demonstration
    final tempDir = Directory.systemTemp;
    final file = File('${tempDir.path}/$fileName');
    
    // In a real app, this would be the actual selected file
    onFileSelected(file);
  }
}