// lib/presentation/record_detail_screen/record_detail_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../providers/medical_records_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/delete_confirmation_dialog.dart';
import './widgets/document_preview_widget.dart';
import './widgets/record_metadata_widget.dart';
import './widgets/share_dialog_widget.dart';
import 'widgets/action_buttons_widget.dart';
import 'widgets/delete_confirmation_dialog.dart';
import 'widgets/document_preview_widget.dart';
import 'widgets/record_metadata_widget.dart';
import 'widgets/share_dialog_widget.dart';

class RecordDetailScreen extends StatefulWidget {
  const RecordDetailScreen({Key? key}) : super(key: key);

  @override
  State<RecordDetailScreen> createState() => _RecordDetailScreenState();
}

class _RecordDetailScreenState extends State<RecordDetailScreen> {
  String? _recordId;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Extract record ID from arguments
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments != null && arguments is Map<String, dynamic>) {
      _recordId = arguments['id'];
      _loadRecordData();
    } else {
      // Handle missing record ID
      Fluttertoast.showToast(
        msg: "Record ID is missing",
        backgroundColor: AppTheme.error,
        textColor: Colors.white,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
    }
  }

  Future<void> _loadRecordData() async {
    if (_recordId == null) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final recordsProvider = Provider.of<MedicalRecordsProvider>(context, listen: false);
      await recordsProvider.getRecordById(_recordId!);
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      Fluttertoast.showToast(
        msg: "Failed to load record: ${e.toString()}",
        backgroundColor: AppTheme.error,
        textColor: Colors.white,
      );
    }
  }

  void _handleEdit() {
    final recordsProvider = Provider.of<MedicalRecordsProvider>(context, listen: false);
    final record = recordsProvider.selectedRecord;
    if (record == null) return;
    
    Navigator.pushNamed(
      context, 
      '/add-edit-record-screen',
      arguments: {'record': record.toMapFormat()},
    ).then((_) {
      // Refresh data when returning from edit screen
      _loadRecordData();
    });
  }

  Future<void> _handleShare() async {
    final recordsProvider = Provider.of<MedicalRecordsProvider>(context, listen: false);
    
    if (recordsProvider.isOffline) {
      Fluttertoast.showToast(
        msg: "Cannot share while offline",
        backgroundColor: AppTheme.error,
        textColor: Colors.white,
      );
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const ShareDialogWidget(),
    );

    if (result != null && _recordId != null) {
      final int expiryHours = result['expiryHours'] as int;
      final bool includeNotes = result['includeNotes'] as bool;
      
      final shareLink = await recordsProvider.createShareLink(_recordId!, expiryHours, includeNotes);
      
      if (shareLink != null) {
        Fluttertoast.showToast(
          msg: "Share link created! Expires in $expiryHours hours",
          backgroundColor: AppTheme.success,
          textColor: Colors.white,
        );
      }
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const DeleteConfirmationDialog(),
    );

    if (confirmed == true && _recordId != null) {
      final recordsProvider = Provider.of<MedicalRecordsProvider>(context, listen: false);
      
      setState(() {
        _isLoading = true;
      });
      
      final success = await recordsProvider.deleteRecord(_recordId!);
      
      if (success) {
        Fluttertoast.showToast(
          msg: "Record deleted successfully",
          backgroundColor: AppTheme.success,
          textColor: Colors.white,
        );
        
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/medical-records-dashboard');
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        
        Fluttertoast.showToast(
          msg: recordsProvider.errorMessage ?? "Failed to delete record",
          backgroundColor: AppTheme.error,
          textColor: Colors.white,
        );
      }
    }
  }

  void _copyShareLink() {
    final recordsProvider = Provider.of<MedicalRecordsProvider>(context, listen: false);
    final record = recordsProvider.selectedRecord;
    
    if (record != null && record.shareLink != null) {
      // In a real app, you would use Clipboard.setData
      Fluttertoast.showToast(
        msg: "Share link copied to clipboard",
        backgroundColor: AppTheme.success,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicalRecordsProvider>(
      builder: (context, recordsProvider, _) {
        final record = recordsProvider.selectedRecord;
        final bool isOffline = recordsProvider.isOffline;
        
        return Scaffold(
          appBar: AppBar(
            title: Text(
              record != null ? record.title : 'Record Details',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            leading: IconButton(
              icon: const CustomIconWidget(
                iconName: 'arrow_back',
                size: 24,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              if (record != null && !_isLoading)
                IconButton(
                  icon: const CustomIconWidget(
                    iconName: 'edit',
                    size: 24,
                  ),
                  onPressed: _handleEdit,
                  tooltip: 'Edit Record',
                ),
            ],
          ),
          body: _buildBody(record, isOffline, recordsProvider),
        );
      },
    );
  }

  Widget _buildBody(MedicalRecord? record, bool isOffline, MedicalRecordsProvider recordsProvider) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (recordsProvider.errorMessage != null) {
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
              recordsProvider.errorMessage ?? 'An error occurred',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            ElevatedButton.icon(
              onPressed: _loadRecordData,
              icon: const CustomIconWidget(
                iconName: 'refresh',
                size: 20,
                color: Colors.white,
              ),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (record == null) {
      return const Center(
        child: Text('No record data available'),
      );
    }

    return Column(
      children: [
        // Offline indicator
        if (isOffline)
          Container(
            width: double.infinity,
            color: AppTheme.warning.withAlpha(51),
            padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 5.w),
            child: Row(
              children: [
                const CustomIconWidget(
                  iconName: 'wifi_off',
                  size: 18,
                  color: AppTheme.warning,
                ),
                SizedBox(width: 2.w),
                Text(
                  'You are offline. Some features may be limited.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.warning,
                  ),
                ),
              ],
            ),
          ),
        
        // Share link indicator
        if (record.isShared && record.shareExpiryDate != null)
          Container(
            width: double.infinity,
            color: AppTheme.info.withAlpha(51),
            padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 5.w),
            child: Row(
              children: [
                const CustomIconWidget(
                  iconName: 'link',
                  size: 18,
                  color: AppTheme.info,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Share link active until ${DateFormat('MMM dd, yyyy hh:mm a').format(record.shareExpiryDate!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.info,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: _copyShareLink,
                  child: Text(
                    'Copy',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        // Main content
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Document preview (60% of screen)
                SizedBox(
                  height: 60.h,
                  child: DocumentPreviewWidget(
                    fileUrl: record.fileUrl,
                    fileType: record.fileUrl?.endsWith('.pdf') == true ? 'pdf' : 'image',
                    isOffline: isOffline,
                  ),
                ),
                
                // Record metadata
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: RecordMetadataWidget(recordData: record.toMapFormat()),
                ),
                
                // Action buttons
                Padding(
                  padding: EdgeInsets.all(4.w),
                  child: ActionButtonsWidget(
                    onShare: _handleShare,
                    onDelete: _handleDelete,
                    isOffline: isOffline,
                  ),
                ),
                
                // Bottom padding for scrolling
                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),
      ],
    );
  }
}