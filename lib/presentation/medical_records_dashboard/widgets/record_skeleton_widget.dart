import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';

class RecordSkeletonWidget extends StatelessWidget {
  const RecordSkeletonWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Record type icon skeleton
                _buildSkeletonBox(12.w, 12.w, 8),
                SizedBox(width: 3.w),
                
                // Record details skeleton
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSkeletonBox(70.w, 2.5.h, 4),
                      SizedBox(height: 1.h),
                      _buildSkeletonBox(40.w, 1.5.h, 4),
                      SizedBox(height: 1.h),
                      _buildSkeletonBox(50.w, 1.5.h, 4),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 2.h),
            
            // Record type tag and file indicator skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSkeletonBox(25.w, 3.h, 16),
                _buildSkeletonBox(30.w, 2.h, 4),
              ],
            ),
            
            SizedBox(height: 1.5.h),
            
            // Tags skeleton
            Row(
              children: [
                _buildSkeletonBox(15.w, 2.h, 12),
                SizedBox(width: 2.w),
                _buildSkeletonBox(18.w, 2.h, 12),
                SizedBox(width: 2.w),
                _buildSkeletonBox(12.w, 2.h, 12),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonBox(double width, double height, double borderRadius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(51),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}