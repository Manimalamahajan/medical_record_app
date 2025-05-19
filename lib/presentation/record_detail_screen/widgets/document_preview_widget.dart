import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class DocumentPreviewWidget extends StatefulWidget {
  final String fileUrl;
  final String fileType;
  final bool isOffline;

  const DocumentPreviewWidget({
    Key? key,
    required this.fileUrl,
    required this.fileType,
    required this.isOffline,
  }) : super(key: key);

  @override
  State<DocumentPreviewWidget> createState() => _DocumentPreviewWidgetState();
}

class _DocumentPreviewWidgetState extends State<DocumentPreviewWidget> {
  bool _isLoading = true;
  bool _hasError = false;
  final TransformationController _transformationController = TransformationController();
  
  @override
  void initState() {
    super.initState();
    // Simulate document loading
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surfaceVariant,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.lightTheme.colorScheme.outline,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Preview header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Document Preview',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const CustomIconWidget(
                    iconName: 'zoom_out_map',
                    size: 20,
                  ),
                  onPressed: _resetZoom,
                  tooltip: 'Reset Zoom',
                ),
              ],
            ),
          ),
          
          // Document preview
          Expanded(
            child: _buildPreviewContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            SizedBox(height: 2.h),
            Text(
              'Loading document...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'error_outline',
              size: 48,
              color: AppTheme.error,
            ),
            SizedBox(height: 2.h),
            Text(
              'Failed to load document',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 1.h),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _hasError = false;
                });
                
                // Simulate reload
                Future.delayed(const Duration(seconds: 1), () {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                });
              },
              icon: const CustomIconWidget(
                iconName: 'refresh',
                size: 18,
                color: Colors.white,
              ),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // PDF Preview
    if (widget.fileType.toLowerCase() == 'pdf') {
      return Stack(
        children: [
          // PDF Placeholder
          Center(
            child: Container(
              width: 90.w,
              height: 50.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: InteractiveViewer(
                transformationController: _transformationController,
                minScale: 0.5,
                maxScale: 4.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'picture_as_pdf',
                      size: 64,
                      color: AppTheme.error,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'PDF Document',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Pinch to zoom in/out',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Offline indicator overlay
          if (widget.isOffline)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withAlpha(230),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CustomIconWidget(
                      iconName: 'offline_pin',
                      size: 16,
                      color: Colors.white,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'Cached',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    }
    
    // Image Preview
    return InteractiveViewer(
      transformationController: _transformationController,
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: CachedNetworkImage(
          imageUrl: widget.fileUrl,
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          errorWidget: (context, url, error) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'broken_image',
                size: 64,
                color: AppTheme.error,
              ),
              SizedBox(height: 2.h),
              Text(
                'Image could not be loaded',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}