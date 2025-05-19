import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
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
  
  List<Map<String, dynamic>> _allRecords = [];
  List<Map<String, dynamic>> _filteredRecords = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreRecords = true;
  bool _isOffline = false;
  String _searchQuery = '';
  String _selectedSortOption = 'Date (Newest)';
  List<String> _selectedTags = [];
  
  final List<String> _sortOptions = [
    'Date (Newest)',
    'Date (Oldest)',
    'Type (A-Z)',
    'Type (Z-A)',
  ];

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _fetchRecords();
    
    _scrollController.addListener(_scrollListener);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOffline = connectivityResult == ConnectivityResult.none;
    });
    
    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        _isOffline = result == ConnectivityResult.none;
      });
      
      if (!_isOffline && _allRecords.isEmpty) {
        _fetchRecords();
      }
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore && 
        _hasMoreRecords) {
      _loadMoreRecords();
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterRecords();
    });
  }

  void _onSortOptionChanged(String? option) {
    if (option != null) {
      setState(() {
        _selectedSortOption = option;
        _sortRecords();
      });
    }
  }

  void _onTagSelected(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
      _filterRecords();
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedTags = [];
      _filterRecords();
    });
  }

  Future<void> _fetchRecords() async {
    if (_isOffline) {
      await _loadCachedRecords();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock data fetch
      final records = _getMockMedicalRecords().take(10).toList();
      
      // Cache records for offline use
      await _cacheRecords(records);
      
      setState(() {
        _allRecords = records;
        _filterRecords();
        _isLoading = false;
        _hasMoreRecords = records.length >= 10;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      Fluttertoast.showToast(
        msg: "Error loading records: ${e.toString()}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.error,
        textColor: Colors.white,
      );
      
      // Try to load cached records if fetch fails
      await _loadCachedRecords();
    }
  }

  Future<void> _loadMoreRecords() async {
    if (_isOffline) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data fetch for pagination
      final currentSize = _allRecords.length;
      final moreRecords = _getMockMedicalRecords()
          .skip(currentSize)
          .take(10)
          .toList();
      
      // Cache the additional records
      await _cacheRecords([..._allRecords, ...moreRecords]);
      
      setState(() {
        _allRecords = [..._allRecords, ...moreRecords];
        _filterRecords();
        _isLoadingMore = false;
        _hasMoreRecords = moreRecords.length >= 10;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      
      Fluttertoast.showToast(
        msg: "Error loading more records: ${e.toString()}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.error,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _refreshRecords() async {
    if (_isOffline) {
      Fluttertoast.showToast(
        msg: "You're offline. Pull to refresh when connected.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.warning,
        textColor: Colors.white,
      );
      return;
    }

    try {
      // Clear current records
      setState(() {
        _allRecords = [];
        _filteredRecords = [];
      });
      
      // Fetch fresh records with timeout
      await Future.delayed(const Duration(seconds: 1));
      final records = _getMockMedicalRecords().take(10).toList();
      
      // Cache the refreshed records
      await _cacheRecords(records);
      
      setState(() {
        _allRecords = records;
        _filterRecords();
        _hasMoreRecords = records.length >= 10;
      });
      
      Fluttertoast.showToast(
        msg: "Records refreshed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.success,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error refreshing records: ${e.toString()}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.error,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _cacheRecords(List<Map<String, dynamic>> records) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_records', records.toString());
    } catch (e) {
      // Silent fail for caching
      debugPrint('Error caching records: ${e.toString()}');
    }
  }

  Future<void> _loadCachedRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_records');
      
      if (cachedData != null && cachedData.isNotEmpty) {
        // This is a simplified approach. In a real app, you'd use proper JSON serialization
        // For demo purposes, we'll just use the mock data
        setState(() {
          _allRecords = _getMockMedicalRecords().take(10).toList();
          _filterRecords();
          _isLoading = false;
        });
        
        if (_isOffline) {
          Fluttertoast.showToast(
            msg: "Showing cached records. Connect to update.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: AppTheme.info,
            textColor: Colors.white,
          );
        }
      } else {
        setState(() {
          _allRecords = [];
          _filteredRecords = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _allRecords = [];
        _filteredRecords = [];
        _isLoading = false;
      });
    }
  }

  void _filterRecords() {
    if (_allRecords.isEmpty) {
      _filteredRecords = [];
      return;
    }
    
    setState(() {
      _filteredRecords = _allRecords.where((record) {
        // Filter by search query
        final matchesQuery = _searchQuery.isEmpty ||
            record['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            record['doctorName'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            record['recordType'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
        
        // Filter by selected tags
        final matchesTags = _selectedTags.isEmpty ||
            _selectedTags.any((tag) => (record['tags'] as List).contains(tag));
        
        return matchesQuery && matchesTags;
      }).toList();
      
      _sortRecords();
    });
  }

  void _sortRecords() {
    switch (_selectedSortOption) {
      case 'Date (Newest)':
        _filteredRecords.sort((a, b) => DateTime.parse(b['date'] as String)
            .compareTo(DateTime.parse(a['date'] as String)));
        break;
      case 'Date (Oldest)':
        _filteredRecords.sort((a, b) => DateTime.parse(a['date'] as String)
            .compareTo(DateTime.parse(b['date'] as String)));
        break;
      case 'Type (A-Z)':
        _filteredRecords.sort((a, b) => (a['recordType'] as String)
            .compareTo(b['recordType'] as String));
        break;
      case 'Type (Z-A)':
        _filteredRecords.sort((a, b) => (b['recordType'] as String)
            .compareTo(a['recordType'] as String));
        break;
    }
  }

  void _navigateToAddRecord() {
    Navigator.pushNamed(context, '/add-edit-record-screen').then((_) {
      // Refresh records when returning from add screen
      _refreshRecords();
    });
  }

  void _navigateToRecordDetail(Map<String, dynamic> record) {
    Navigator.pushNamed(
      context, 
      '/record-detail-screen',
      arguments: record,
    );
  }

  @override
  Widget build(BuildContext context) {
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
              Navigator.pushNamed(context, '/authentication-screen');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Offline banner
          if (_isOffline) const OfflineBannerWidget(),
          
          // Search and filter section
          RecordFilterWidget(
            searchController: _searchController,
            sortOptions: _sortOptions,
            selectedSortOption: _selectedSortOption,
            onSortChanged: _onSortOptionChanged,
            onClearFilters: _clearFilters,
            selectedTags: _selectedTags,
            onTagSelected: _onTagSelected,
            availableTags: _getAvailableTags(),
          ),
          
          // Records list
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshRecords,
              color: AppTheme.primary,
              child: _buildRecordsList(),
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
  }

  Widget _buildRecordsList() {
    if (_isLoading) {
      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        itemCount: 5,
        itemBuilder: (context, index) => const RecordSkeletonWidget(),
      );
    }
    
    if (_allRecords.isEmpty) {
      return const EmptyRecordsWidget();
    }
    
    if (_filteredRecords.isEmpty) {
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
    
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      itemCount: _filteredRecords.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _filteredRecords.length) {
          return const RecordSkeletonWidget();
        }
        
        final record = _filteredRecords[index];
        return RecordCardWidget(
          record: record,
          onTap: () => _navigateToRecordDetail(record),
        );
      },
    );
  }

  List<String> _getAvailableTags() {
    final Set<String> tags = {};
    for (final record in _allRecords) {
      final recordTags = record['tags'] as List;
      for (final tag in recordTags) {
        tags.add(tag as String);
      }
    }
    return tags.toList()..sort();
  }

  List<Map<String, dynamic>> _getMockMedicalRecords() {
    return [
      {
        "id": "rec001",
        "title": "Annual Physical Examination",
        "recordType": "Consultation",
        "doctorName": "Dr. Sarah Johnson",
        "facilityName": "City General Hospital",
        "date": "2023-06-15T09:30:00.000Z",
        "notes": "Regular annual checkup. Blood pressure normal at 120/80. Weight stable. Recommended continued exercise and healthy diet.",
        "tags": ["annual", "checkup", "physical"],
        "fileUrl": "https://example.com/files/annual_checkup_2023.pdf",
        "color": AppTheme.appointment,
      },
      {
        "id": "rec002",
        "title": "Blood Test Results",
        "recordType": "Lab Report",
        "doctorName": "Dr. Michael Chen",
        "facilityName": "MedLab Diagnostics",
        "date": "2023-05-22T14:15:00.000Z",
        "notes": "Complete blood count and metabolic panel. All values within normal range except slightly elevated cholesterol (215 mg/dL).",
        "tags": ["blood test", "cholesterol", "lab"],
        "fileUrl": "https://example.com/files/blood_test_may2023.pdf",
        "color": AppTheme.labReport,
      },
      {
        "id": "rec003",
        "title": "Flu Vaccination",
        "recordType": "Vaccination",
        "doctorName": "Dr. Lisa Wong",
        "facilityName": "Community Health Clinic",
        "date": "2023-10-05T11:00:00.000Z",
        "notes": "Annual influenza vaccination administered. No immediate adverse reactions.",
        "tags": ["flu", "vaccine", "preventive"],
        "fileUrl": "https://example.com/files/flu_vaccine_2023.pdf",
        "color": AppTheme.vaccination,
      },
      {
        "id": "rec004",
        "title": "Hypertension Medication",
        "recordType": "Prescription",
        "doctorName": "Dr. James Wilson",
        "facilityName": "Heart & Vascular Center",
        "date": "2023-04-10T16:45:00.000Z",
        "notes": "Prescription for Lisinopril 10mg, once daily. Follow up in 3 months to assess efficacy.",
        "tags": ["medication", "hypertension", "heart"],
        "fileUrl": "https://example.com/files/lisinopril_prescription.pdf",
        "color": AppTheme.medication,
      },
      {
        "id": "rec005",
        "title": "Chest X-Ray",
        "recordType": "Imaging",
        "doctorName": "Dr. Robert Garcia",
        "facilityName": "Radiology Partners",
        "date": "2023-03-18T10:30:00.000Z",
        "notes": "Chest X-ray performed due to persistent cough. Results show no significant abnormalities. Lungs clear.",
        "tags": ["x-ray", "chest", "imaging"],
        "fileUrl": "https://example.com/files/chest_xray_march2023.pdf",
        "color": AppTheme.info,
      },
      {
        "id": "rec006",
        "title": "Dental Cleaning",
        "recordType": "Consultation",
        "doctorName": "Dr. Emily Patel",
        "facilityName": "Bright Smile Dental",
        "date": "2023-07-12T13:00:00.000Z",
        "notes": "Routine dental cleaning and examination. No cavities detected. Recommended continued flossing.",
        "tags": ["dental", "cleaning", "preventive"],
        "fileUrl": "https://example.com/files/dental_visit_july2023.pdf",
        "color": AppTheme.appointment,
      },
      {
        "id": "rec007",
        "title": "Allergy Test Results",
        "recordType": "Lab Report",
        "doctorName": "Dr. Nicole Adams",
        "facilityName": "Allergy & Asthma Specialists",
        "date": "2023-02-28T15:30:00.000Z",
        "notes": "Skin prick test performed. Positive reactions to dust mites and cat dander. Negative for food allergens tested.",
        "tags": ["allergy", "test", "dust mites"],
        "fileUrl": "https://example.com/files/allergy_test_feb2023.pdf",
        "color": AppTheme.labReport,
      },
      {
        "id": "rec008",
        "title": "Ophthalmology Checkup",
        "recordType": "Consultation",
        "doctorName": "Dr. Thomas Lee",
        "facilityName": "Vision Care Center",
        "date": "2023-08-05T09:15:00.000Z",
        "notes": "Annual eye examination. Prescription updated. Right: -2.25, Left: -2.00. No signs of glaucoma or other concerns.",
        "tags": ["eye", "vision", "glasses"],
        "fileUrl": "https://example.com/files/eye_exam_aug2023.pdf",
        "color": AppTheme.appointment,
      },
      {
        "id": "rec009",
        "title": "COVID-19 Booster",
        "recordType": "Vaccination",
        "doctorName": "Dr. Maria Rodriguez",
        "facilityName": "Public Health Department",
        "date": "2023-01-20T14:00:00.000Z",
        "notes": "COVID-19 bivalent booster administered. Pfizer-BioNTech. Batch #BT7634. No immediate adverse reactions.",
        "tags": ["covid", "vaccine", "booster"],
        "fileUrl": "https://example.com/files/covid_booster_jan2023.pdf",
        "color": AppTheme.vaccination,
      },
      {
        "id": "rec010",
        "title": "Antibiotic Prescription",
        "recordType": "Prescription",
        "doctorName": "Dr. Sarah Johnson",
        "facilityName": "City General Hospital",
        "date": "2023-09-12T11:30:00.000Z",
        "notes": "Amoxicillin 500mg, three times daily for 10 days. Prescribed for sinus infection.",
        "tags": ["antibiotic", "sinus", "infection"],
        "fileUrl": "https://example.com/files/amoxicillin_prescription.pdf",
        "color": AppTheme.medication,
      },
      {
        "id": "rec011",
        "title": "MRI Knee Scan",
        "recordType": "Imaging",
        "doctorName": "Dr. Jason Kim",
        "facilityName": "Sports Medicine Institute",
        "date": "2023-04-25T16:00:00.000Z",
        "notes": "MRI of right knee following sports injury. Minor meniscus tear identified. Conservative treatment recommended.",
        "tags": ["mri", "knee", "injury"],
        "fileUrl": "https://example.com/files/knee_mri_april2023.pdf",
        "color": AppTheme.info,
      },
      {
        "id": "rec012",
        "title": "Cholesterol Medication",
        "recordType": "Prescription",
        "doctorName": "Dr. Michael Chen",
        "facilityName": "Heart & Vascular Center",
        "date": "2023-06-02T10:00:00.000Z",
        "notes": "Atorvastatin 20mg, once daily at bedtime. For management of hypercholesterolemia.",
        "tags": ["cholesterol", "medication", "statin"],
        "fileUrl": "https://example.com/files/atorvastatin_prescription.pdf",
        "color": AppTheme.medication,
      },
      {
        "id": "rec013",
        "title": "Dermatology Consultation",
        "recordType": "Consultation",
        "doctorName": "Dr. Rebecca Tan",
        "facilityName": "Skin Health Clinic",
        "date": "2023-07-28T13:45:00.000Z",
        "notes": "Evaluation of mole on upper back. No concerning features. Recommended annual skin checks.",
        "tags": ["skin", "mole", "dermatology"],
        "fileUrl": "https://example.com/files/derm_consult_july2023.pdf",
        "color": AppTheme.appointment,
      },
      {
        "id": "rec014",
        "title": "Urinalysis Results",
        "recordType": "Lab Report",
        "doctorName": "Dr. James Wilson",
        "facilityName": "MedLab Diagnostics",
        "date": "2023-05-10T09:30:00.000Z",
        "notes": "Routine urinalysis performed. All parameters within normal limits. No evidence of infection or abnormalities.",
        "tags": ["urine", "test", "lab"],
        "fileUrl": "https://example.com/files/urinalysis_may2023.pdf",
        "color": AppTheme.labReport,
      },
      {
        "id": "rec015",
        "title": "Physical Therapy Session",
        "recordType": "Consultation",
        "doctorName": "Dr. Alex Thompson",
        "facilityName": "Rehabilitation Center",
        "date": "2023-08-15T15:00:00.000Z",
        "notes": "PT session for shoulder mobility. Exercises provided for home practice. Improvement noted in range of motion.",
        "tags": ["physical therapy", "shoulder", "rehabilitation"],
        "fileUrl": "https://example.com/files/pt_session_aug2023.pdf",
        "color": AppTheme.appointment,
      },
      {
        "id": "rec016",
        "title": "Tetanus Booster",
        "recordType": "Vaccination",
        "doctorName": "Dr. Lisa Wong",
        "facilityName": "Community Health Clinic",
        "date": "2023-03-05T11:15:00.000Z",
        "notes": "Tdap booster administered. Due for renewal in 10 years (2033).",
        "tags": ["tetanus", "vaccine", "booster"],
        "fileUrl": "https://example.com/files/tetanus_booster_march2023.pdf",
        "color": AppTheme.vaccination,
      },
      {
        "id": "rec017",
        "title": "Colonoscopy Results",
        "recordType": "Imaging",
        "doctorName": "Dr. David Brown",
        "facilityName": "Digestive Health Center",
        "date": "2023-02-10T08:00:00.000Z",
        "notes": "Routine screening colonoscopy. No polyps or abnormalities detected. Next screening recommended in 10 years.",
        "tags": ["colonoscopy", "screening", "preventive"],
        "fileUrl": "https://example.com/files/colonoscopy_feb2023.pdf",
        "color": AppTheme.info,
      },
      {
        "id": "rec018",
        "title": "Sleep Study Results",
        "recordType": "Lab Report",
        "doctorName": "Dr. Jennifer Park",
        "facilityName": "Sleep Disorders Center",
        "date": "2023-09-20T22:00:00.000Z",
        "notes": "Overnight polysomnography performed. Mild obstructive sleep apnea diagnosed. CPAP therapy recommended.",
        "tags": ["sleep", "apnea", "study"],
        "fileUrl": "https://example.com/files/sleep_study_sept2023.pdf",
        "color": AppTheme.labReport,
      },
      {
        "id": "rec019",
        "title": "Migraine Medication",
        "recordType": "Prescription",
        "doctorName": "Dr. Robert Garcia",
        "facilityName": "Neurology Associates",
        "date": "2023-01-15T14:30:00.000Z",
        "notes": "Sumatriptan 50mg as needed for migraine attacks. Not to exceed 200mg in 24 hours or 600mg in one week.",
        "tags": ["migraine", "headache", "medication"],
        "fileUrl": "https://example.com/files/sumatriptan_prescription.pdf",
        "color": AppTheme.medication,
      },
      {
        "id": "rec020",
        "title": "Mammogram Results",
        "recordType": "Imaging",
        "doctorName": "Dr. Maria Rodriguez",
        "facilityName": "Women's Health Center",
        "date": "2023-10-10T10:00:00.000Z",
        "notes": "Routine screening mammogram. No suspicious masses or calcifications. BI-RADS category 1 (negative).",
        "tags": ["mammogram", "breast", "screening"],
        "fileUrl": "https://example.com/files/mammogram_oct2023.pdf",
        "color": AppTheme.info,
      },
    ];
  }
}