import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class ShareDialogWidget extends StatefulWidget {
  const ShareDialogWidget({Key? key}) : super(key: key);

  @override
  State<ShareDialogWidget> createState() => _ShareDialogWidgetState();
}

class _ShareDialogWidgetState extends State<ShareDialogWidget> {
  int _expiryHours = 24;
  bool _includeNotes = true;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'share',
                  size: 24,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Share Medical Record',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            SizedBox(height: 3.h),
            
            Text(
              'This will generate a temporary link that can be shared with others.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 3.h),
            
            // Expiry time selection
            Text(
              'Link expires after:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 1.h),
            
            _buildExpiryOptions(),
            SizedBox(height: 3.h),
            
            // Include notes option
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Include notes and diagnosis',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Switch(
                  value: _includeNotes,
                  onChanged: (value) {
                    setState(() {
                      _includeNotes = value;
                    });
                  },
                  activeColor: AppTheme.lightTheme.colorScheme.primary,
                ),
              ],
            ),
            SizedBox(height: 3.h),
            
            // Security note
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.warning.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.warning.withAlpha(77),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'security',
                    size: 20,
                    color: AppTheme.warning,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Anyone with the link can access this record until it expires.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 3.h),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                SizedBox(width: 2.w),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'expiryHours': _expiryHours,
                      'includeNotes': _includeNotes,
                    });
                  },
                  child: const Text('Generate Link'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiryOptions() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildExpiryOption(1, '1 hour'),
          Divider(height: 1, color: AppTheme.lightTheme.colorScheme.outline),
          _buildExpiryOption(24, '24 hours'),
          Divider(height: 1, color: AppTheme.lightTheme.colorScheme.outline),
          _buildExpiryOption(72, '3 days'),
          Divider(height: 1, color: AppTheme.lightTheme.colorScheme.outline),
          _buildExpiryOption(168, '7 days'),
        ],
      ),
    );
  }

  Widget _buildExpiryOption(int hours, String label) {
    final isSelected = _expiryHours == hours;
    
    return InkWell(
      onTap: () {
        setState(() {
          _expiryHours = hours;
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isSelected 
                      ? AppTheme.lightTheme.colorScheme.primary
                      : null,
                  fontWeight: isSelected ? FontWeight.w500 : null,
                ),
              ),
            ),
            if (isSelected)
              CustomIconWidget(
                iconName: 'check_circle',
                size: 20,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}