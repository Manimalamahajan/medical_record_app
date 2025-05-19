// lib/presentation/medical_records_dashboard/medical_records_dashboard.dart
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../providers/auth_provider.dart';
import '../../providers/medical_records_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/empty_records_widget.dart';
import './widgets/offline_banner_widget.dart';
import './widgets/record_card_widget.dart';
import './widgets/record_filter_widget.dart';
import './widgets/record_skeleton_widget.dart';
import 'widgets/empty_records_widget.dart';
import 'widgets/offline_banner_widget.dart';
import 'widgets/record_card_widget.dart';
import 'widgets/record_filter_widget.dart';
import 'widgets/record_skeleton_widget.dart';

class MedicalRecordsDashboard extends StatefulWidget {
  const MedicalRecordsDashboard({Key? key}) : super(key: key);

  @override
  State<MedicalRecordsDashboard> createState() => _MedicalRecordsDashboardState();
}

class _MedicalRecordsDashboardState extends State<MedicalRecordsDashboard> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  final List<String> _sortOptions = [
    'Date (Newest)',
    'Date (Oldest)',
    'Type (A-Z)',
    'Type (Z-A)',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    
    // Initialize data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final recordsProvider = Provider.of<MedicalRecordsProvider>(context, listen: false);
      recordsProvider.fetchRecords();
      
      _searchController.addListener(() {
        recordsProvider.setSearchQuery(_searchController.text);
      });
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final recordsProvider = Provider.of<MedicalRecordsProvider>(context, listen: false);
      if (!recordsProvider.isLoadingMore && recordsProvider.hasMoreRecords && !recordsProvider.isOffline) {
        recordsProvider.loadMoreRecords();
      }
    }
  }

  void _onSortOptionChanged(String? option) {
    if (option != null) {
      final recordsProvider = Provider.of<MedicalRecordsProvider>(context, listen: false);
      recordsProvider.setSortOption(option);
    }
  }

  void _onTagSelected(String tag) {
    final recordsProvider = Provider.of<MedicalRecordsProvider>(context, listen: false);
    recordsProvider.toggleTag(tag);
  }

  void _clearFilters() {
    _searchController.clear();
    final recordsProvider = Provider.of<MedicalRecordsProvider>(context, listen: false);
    recordsProvider.clearFilters();
  }

  Future<void> _refreshRecords() async {
    final recordsProvider = Provider.of<MedicalRecordsProvider>(context, listen: false);
    
    if (recordsProvider.isOffline) {
      Fluttertoast.showToast(
        msg: "You're offline. Pull to refresh when connected.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.warning,
        textColor: Colors.white,
      );
      return;
    }

    await recordsProvider.refreshRecords();
    if (recordsProvider.errorMessage == null) {
      Fluttertoast.showToast(
        msg: "Records refreshed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.success,
        textColor: Colors.white,
      );
    }
  }

  void _navigateToAddRecord() {
    Navigator.pushNamed(context, '/add-edit-record-screen').then((_) {
      // Refresh records when returning from add screen
      final recordsProvider = Provider.of<MedicalRecordsProvider>(context, listen: false);
      recordsProvider.refreshRecords();
    });
  }

  void _navigateToRecordDetail(String recordId) {
    Navigator.pushNamed(
      context, 
      '/record-detail-screen',
      arguments: {'id': recordId},
    );
  }

  void _logout() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.logout().then((_) {
      Navigator.pushReplacementNamed(context, '/authentication-screen');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicalRecordsProvider>(
      builder: (context, recordsProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Medical Records'),
            actions: [
              IconButton(
                icon: const CustomIconWidget(
                  iconName: 'person',
                  size: 24,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Account'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, _) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Name: ${authProvider.user?.name ?? \'User\'}'),
                                  SizedBox(height: 1.h),
                                  Text('Email: ${authProvider.user?.email ?? \'user@example.com\'}'),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _logout();
                          },
                          child: Text(
                            'Logout',
                            style: TextStyle(color: AppTheme.error),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Offline banner
              if (recordsProvider.isOffline) const OfflineBannerWidget(),
              
              // Search and filter section
              RecordFilterWidget(
                searchController: _searchController,
                sortOptions: _sortOptions,
                selectedSortOption: recordsProvider.selectedSortOption,
                onSortChanged: _onSortOptionChanged,
                onClearFilters: _clearFilters,
                selectedTags: recordsProvider.selectedTags,
                onTagSelected: _onTagSelected,
                availableTags: recordsProvider.getAvailableTags(),
              ),
              
              // Error message if any
              if (recordsProvider.errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 5.w),
                  color: AppTheme.error.withAlpha(51),
                  child: Row(
                    children: [
                      const CustomIconWidget(
                        iconName: 'error_outline',
                        size: 18,
                        color: AppTheme.error,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          recordsProvider.errorMessage!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.error,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => recordsProvider.clearError(),
                        child: Text(
                          'Dismiss',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppTheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Records list
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshRecords,
                  color: AppTheme.primary,
                  child: _buildRecordsList(recordsProvider),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _navigateToAddRecord,
            child: const CustomIconWidget(
              iconName: 'add',
              size: 24,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecordsList(MedicalRecordsProvider recordsProvider) {
    // Loading state
    if (recordsProvider.status == RecordsStatus.loading && recordsProvider.records.isEmpty) {
      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        itemCount: 5,
        itemBuilder: (context, index) => const RecordSkeletonWidget(),
      );
    }
    
    // No records state
    if (recordsProvider.records.isEmpty) {
      return const EmptyRecordsWidget();
    }
    
    // No matching records state
    if (recordsProvider.filteredRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'search_off',
              size: 64,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant.withAlpha(128),
            ),
            SizedBox(height: 2.h),
            Text(
              'No matching records found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant.withAlpha(179),
              ),
            ),
            SizedBox(height: 1.h),
            TextButton.icon(
              onPressed: _clearFilters,
              icon: const CustomIconWidget(
                iconName: 'filter_alt_off',
                size: 20,
              ),
              label: const Text('Clear filters'),
            ),
          ],
        ),
      );
    }
    
    // Records list with pagination
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      itemCount: recordsProvider.filteredRecords.length + (recordsProvider.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == recordsProvider.filteredRecords.length) {
          return const RecordSkeletonWidget();
        }
        
        final record = recordsProvider.filteredRecords[index];
        return RecordCardWidget(
          record: record.toMapFormat(),
          onTap: () => _navigateToRecordDetail(record.id),
        );
      },
    );
  }
}