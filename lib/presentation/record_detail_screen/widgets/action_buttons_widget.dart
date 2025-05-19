import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class ActionButtonsWidget extends StatelessWidget {
  final VoidCallback onShare;
  final VoidCallback onDelete;
  final bool isOffline;

  const ActionButtonsWidget({
    Key? key,
    required this.onShare,
    required this.onDelete,
    required this.isOffline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                'Share',
                'share',
                AppTheme.info,
                onShare,
                isDisabled: isOffline,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: _buildActionButton(
                context,
                'Download',
                'download',
                AppTheme.lightTheme.colorScheme.primary,
                () {
                  // Download functionality would be implemented here
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isOffline 
                            ? 'Document already available offline' 
                            : 'Document downloaded successfully',
                      ),
                      backgroundColor: isOffline 
                          ? AppTheme.info 
                          : AppTheme.success,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                'Print',
                'print',
                AppTheme.lightTheme.colorScheme.secondary,
                () {
                  // Print functionality would be implemented here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Preparing document for printing...'),
                    ),
                  );
                },
                isDisabled: isOffline,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: _buildActionButton(
                context,
                'Delete',
                'delete',
                AppTheme.error,
                onDelete,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    String iconName,
    Color color,
    VoidCallback onPressed, {
    bool isDisabled = false,
  }) {
    return ElevatedButton.icon(
      onPressed: isDisabled ? null : onPressed,
      icon: CustomIconWidget(
        iconName: iconName,
        size: 20,
        color: isDisabled ? null : Colors.white,
      ),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppTheme.lightTheme.colorScheme.surfaceVariant,
        disabledForegroundColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
      ),
    );
  }
}