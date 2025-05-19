import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../core/utils/logger.dart';
import '../models/medical_record_model.dart';
import '../services/api_service.dart';

// lib/providers/medical_records_provider.dart








enum RecordsStatus { initial, loading, loaded, error }

class MedicalRecordsProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  RecordsStatus _status = RecordsStatus.initial;
  List<MedicalRecord> _records = [];
  List<MedicalRecord> _filteredRecords = [];
  int _currentPage = 1;
  bool _hasMoreRecords = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  bool _isOffline = false;
  String _searchQuery = '';
  String _selectedSortOption = 'Date (Newest)';
  List<String> _selectedTags = [];
  MedicalRecord? _selectedRecord;
  double _uploadProgress = 0.0;
  bool _isUploading = false;

  MedicalRecordsProvider({required ApiService apiService}) 
      : _apiService = apiService {
    _checkConnectivity();
  }

  RecordsStatus get status => _status;
  List<MedicalRecord> get records => _records;
  List<MedicalRecord> get filteredRecords => _filteredRecords;
  bool get hasMoreRecords => _hasMoreRecords;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get isOffline => _isOffline;
  String get searchQuery => _searchQuery;
  String get selectedSortOption => _selectedSortOption;
  List<String> get selectedTags => _selectedTags;
  MedicalRecord? get selectedRecord => _selectedRecord;
  double get uploadProgress => _uploadProgress;
  bool get isUploading => _isUploading;

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    _isOffline = connectivityResult == ConnectivityResult.none;
    
    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((result) {
      final wasOffline = _isOffline;
      _isOffline = result == ConnectivityResult.none;
      
      if (wasOffline && !_isOffline && _records.isEmpty) {
        fetchRecords();
      }
      notifyListeners();
    });
  }

  Future<void> fetchRecords({bool refresh = false}) async {
    if (_isOffline) {
      // In a real app, you would load from local database here
      _errorMessage = 'Cannot load records while offline';
      _status = RecordsStatus.error;
      notifyListeners();
      return;
    }

    if (refresh) {
      _currentPage = 1;
      _hasMoreRecords = true;
    }

    if (_status == RecordsStatus.loading) return;

    _status = RecordsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final records = await _apiService.getMedicalRecords(
        page: _currentPage,
        limit: 10,
      );
      
      if (refresh) {
        _records = records;
      } else {
        _records = [..._records, ...records];
      }
      
      _hasMoreRecords = records.length >= 10;
      _status = RecordsStatus.loaded;
      _filterRecords();
    } catch (e) {
      Logger.log('Fetch records error: $e');
      _errorMessage = 'Failed to load medical records';
      _status = RecordsStatus.error;
    }

    notifyListeners();
  }

  Future<void> loadMoreRecords() async {
    if (_isOffline || !_hasMoreRecords || _isLoadingMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      _currentPage++;
      final moreRecords = await _apiService.getMedicalRecords(
        page: _currentPage,
        limit: 10,
      );
      
      _records = [..._records, ...moreRecords];
      _hasMoreRecords = moreRecords.length >= 10;
      _filterRecords();
    } catch (e) {
      Logger.log('Load more records error: $e');
      _currentPage--;
      _errorMessage = 'Failed to load more records';
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> refreshRecords() async {
    if (_isOffline) {
      _errorMessage = 'Cannot refresh while offline';
      notifyListeners();
      return;
    }

    await fetchRecords(refresh: true);
  }

  Future<MedicalRecord?> getRecordById(String id) async {
    if (_isOffline) {
      // In a real app, you would try to find it in local records first
      final localRecord = _records.firstWhere(
        (record) => record.id == id,
        orElse: () => throw Exception('Record not found locally'),
      );
      _selectedRecord = localRecord;
      notifyListeners();
      return localRecord;
    }

    try {
      final record = await _apiService.getMedicalRecordById(id);
      _selectedRecord = record;
      notifyListeners();
      return record;
    } catch (e) {
      Logger.log('Get record by ID error: $e');
      _errorMessage = 'Failed to load record details';
      notifyListeners();
      return null;
    }
  }

  Future<bool> createRecord({
    required String title,
    required String recordType,
    required String doctorName,
    required String facilityName,
    required DateTime date,
    required String notes,
    required List<String> tags,
    File? documentFile,
  }) async {
    if (_isOffline) {
      _errorMessage = 'Cannot create records while offline';
      notifyListeners();
      return false;
    }

    _isUploading = true;
    _uploadProgress = 0.0;
    notifyListeners();

    try {
      final newRecord = await _apiService.createMedicalRecord(
        title: title,
        recordType: recordType,
        doctorName: doctorName,
        facilityName: facilityName,
        date: date,
        notes: notes,
        tags: tags,
        documentFile: documentFile,
      );
      
      _records.insert(0, newRecord);
      _filterRecords();
      _isUploading = false;
      notifyListeners();
      return true;
    } catch (e) {
      Logger.log('Create record error: $e');
      _errorMessage = 'Failed to create record';
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateRecord({
    required String id,
    required String title,
    required String recordType,
    required String doctorName,
    required String facilityName,
    required DateTime date,
    required String notes,
    required List<String> tags,
    File? documentFile,
  }) async {
    if (_isOffline) {
      _errorMessage = 'Cannot update records while offline';
      notifyListeners();
      return false;
    }

    _isUploading = true;
    _uploadProgress = 0.0;
    notifyListeners();

    try {
      final updatedRecord = await _apiService.updateMedicalRecord(
        id: id,
        title: title,
        recordType: recordType,
        doctorName: doctorName,
        facilityName: facilityName,
        date: date,
        notes: notes,
        tags: tags,
        documentFile: documentFile,
      );
      
      // Update record in the list
      final index = _records.indexWhere((record) => record.id == id);
      if (index != -1) {
        _records[index] = updatedRecord;
      }
      
      // Update selected record if it's the same one
      if (_selectedRecord?.id == id) {
        _selectedRecord = updatedRecord;
      }
      
      _filterRecords();
      _isUploading = false;
      notifyListeners();
      return true;
    } catch (e) {
      Logger.log('Update record error: $e');
      _errorMessage = 'Failed to update record';
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteRecord(String id) async {
    if (_isOffline) {
      _errorMessage = 'Cannot delete records while offline';
      notifyListeners();
      return false;
    }

    try {
      await _apiService.deleteMedicalRecord(id);
      
      // Remove record from the list
      _records.removeWhere((record) => record.id == id);
      _filterRecords();
      
      // Clear selected record if it's the same one
      if (_selectedRecord?.id == id) {
        _selectedRecord = null;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      Logger.log('Delete record error: $e');
      _errorMessage = 'Failed to delete record';
      notifyListeners();
      return false;
    }
  }

  Future<String?> createShareLink(String id, int expiryHours, bool includeNotes) async {
    if (_isOffline) {
      _errorMessage = 'Cannot create share link while offline';
      notifyListeners();
      return null;
    }

    try {
      final shareLink = await _apiService.createShareLink(id, expiryHours, includeNotes);
      
      // Update the record with share information
      final index = _records.indexWhere((record) => record.id == id);
      if (index != -1) {
        final expiryDate = DateTime.now().add(Duration(hours: expiryHours));
        _records[index] = _records[index].copyWith(
          isShared: true,
          shareExpiryDate: expiryDate,
          shareLink: shareLink,
        );
      }
      
      // Update selected record if it's the same one
      if (_selectedRecord?.id == id) {
        final expiryDate = DateTime.now().add(Duration(hours: expiryHours));
        _selectedRecord = _selectedRecord!.copyWith(
          isShared: true,
          shareExpiryDate: expiryDate,
          shareLink: shareLink,
        );
      }
      
      notifyListeners();
      return shareLink;
    } catch (e) {
      Logger.log('Create share link error: $e');
      _errorMessage = 'Failed to create share link';
      notifyListeners();
      return null;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _filterRecords();
    notifyListeners();
  }

  void setSortOption(String option) {
    _selectedSortOption = option;
    _sortRecords();
    notifyListeners();
  }

  void toggleTag(String tag) {
    if (_selectedTags.contains(tag)) {
      _selectedTags.remove(tag);
    } else {
      _selectedTags.add(tag);
    }
    _filterRecords();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedTags = [];
    _filterRecords();
    notifyListeners();
  }

  void _filterRecords() {
    if (_records.isEmpty) {
      _filteredRecords = [];
      return;
    }
    
    _filteredRecords = _records.where((record) {
      // Filter by search query
      final matchesQuery = _searchQuery.isEmpty ||
          record.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          record.doctorName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          record.recordType.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Filter by selected tags
      final matchesTags = _selectedTags.isEmpty ||
          _selectedTags.any((tag) => record.tags.contains(tag));
      
      return matchesQuery && matchesTags;
    }).toList();
    
    _sortRecords();
  }

  void _sortRecords() {
    switch (_selectedSortOption) {
      case 'Date (Newest)':
        _filteredRecords.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'Date (Oldest)':
        _filteredRecords.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'Type (A-Z)':
        _filteredRecords.sort((a, b) => a.recordType.compareTo(b.recordType));
        break;
      case 'Type (Z-A)':
        _filteredRecords.sort((a, b) => b.recordType.compareTo(a.recordType));
        break;
    }
  }

  List<String> getAvailableTags() {
    final Set<String> tags = {};
    for (final record in _records) {
      tags.addAll(record.tags);
    }
    return tags.toList()..sort();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void cancelUpload() {
    _isUploading = false;
    _uploadProgress = 0.0;
    notifyListeners();
  }

  // Helper method to simulate upload progress updates
  void updateUploadProgress(double progress) {
    _uploadProgress = progress;
    notifyListeners();
  }
}