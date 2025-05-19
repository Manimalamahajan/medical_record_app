import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
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
  bool _isLoading = true;
  bool _hasError = false;
  bool _isOffline = false;
  String? _errorMessage;
  Map<String, dynamic>? _recordData;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _loadRecordData();
    _setupConnectivityListener();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOffline = connectivityResult == ConnectivityResult.none;
    });
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _isOffline = result == ConnectivityResult.none;
      });
    });
  }

  Future<void> _loadRecordData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock data for demonstration
      final mockRecord = _getMockRecordData();
      
      setState(() {
        _recordData = mockRecord;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = "Failed to load record: ${e.toString()}";
      });
    }
  }

  Map<String, dynamic> _getMockRecordData() {
    return {
      "id": "rec123456",
      "title": "Annual Physical Examination",
      "recordType": "Lab Report",
      "date": "2023-06-15",
      "doctorName": "Dr. Sarah Johnson",
      "facilityName": "City General Hospital",
      "diagnosis": "Healthy with minor vitamin D deficiency",
      "notes": "Patient is in good health overall. Recommended vitamin D supplements and regular exercise. Follow-up in 12 months.",
      "tags": ["annual", "physical", "bloodwork"],
      "fileUrl": "https://www.africau.edu/images/default/sample.pdf",
      "fileType": "pdf", // can be "pdf", "image", or "other"
      "lastUpdated": "2023-06-15T14:30:00Z",
      "isShared": false,
      "shareExpiryDate": null,
      "shareLink": null,
    };
  }

  void _handleEdit() {
    Navigator.pushNamed(
      context, 
      '/add-edit-record-screen',
      arguments: _recordData,
    ).then((_) {
      // Refresh data when returning from edit screen
      _loadRecordData();
    });
  }

  Future<void> _handleShare() async {
    if (_isOffline) {
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

    if (result != null) {
      final int expiryHours = result['expiryHours'] as int;
      final bool includeNotes = result['includeNotes'] as bool;
      
      // Simulate share link generation
      setState(() {
        _isLoading = true;
      });
      
      await Future.delayed(const Duration(seconds: 1));
      
      final now = DateTime.now();
      final expiryDate = now.add(Duration(hours: expiryHours));
      
      setState(() {
        _isLoading = false;
        _recordData = {
          ..._recordData!,
          "isShared": true,
          "shareExpiryDate": expiryDate.toIso8601String(),
          "shareLink": "https://medrec.app/share/${_recordData!['id']}?exp=${expiryDate.millisecondsSinceEpoch}&notes=${includeNotes ? '1' : '0'}",
        };
      });
      
      Fluttertoast.showToast(
        msg: "Share link created! Expires in $expiryHours hours",
        backgroundColor: AppTheme.success,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const DeleteConfirmationDialog(),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });
      
      // Simulate deletion process
      await Future.delayed(const Duration(seconds: 1));
      
      Fluttertoast.showToast(
        msg: "Record deleted successfully",
        backgroundColor: AppTheme.success,
        textColor: Colors.white,
      );
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/medical-records-dashboard');
      }
    }
  }

  void _copyShareLink() {
    if (_recordData != null && _recordData!['shareLink'] != null) {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _recordData != null ? _recordData!['title'] : 'Record Details',
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
          if (_recordData != null && !_isLoading)
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
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
              _errorMessage ?? 'An error occurred',
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

    if (_recordData == null) {
      return const Center(
        child: Text('No record data available'),
      );
    }

    return Column(
      children: [
        // Offline indicator
        if (_isOffline)
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
        if (_recordData!['isShared'] == true)
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
                    'Share link active until ${DateFormat('MMM dd, yyyy hh:mm a').format(DateTime.parse(_recordData!['shareExpiryDate']))}',
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
                    fileUrl: _recordData!['fileUrl'],
                    fileType: _recordData!['fileType'],
                    isOffline: _isOffline,
                  ),
                ),
                
                // Record metadata
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: RecordMetadataWidget(recordData: _recordData!),
                ),
                
                // Action buttons
                Padding(
                  padding: EdgeInsets.all(4.w),
                  child: ActionButtonsWidget(
                    onShare: _handleShare,
                    onDelete: _handleDelete,
                    isOffline: _isOffline,
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