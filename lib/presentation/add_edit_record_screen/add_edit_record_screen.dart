import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/custom_date_picker_widget.dart';
import './widgets/document_upload_widget.dart';
import './widgets/form_field_widget.dart';
import './widgets/record_type_dropdown_widget.dart';
import './widgets/tag_input_widget.dart';
import 'widgets/custom_date_picker_widget.dart';
import 'widgets/document_upload_widget.dart';
import 'widgets/form_field_widget.dart';
import 'widgets/record_type_dropdown_widget.dart';
import 'widgets/tag_input_widget.dart';

class AddEditRecordScreen extends StatefulWidget {
  final Map<String, dynamic>? existingRecord;

  const AddEditRecordScreen({Key? key, this.existingRecord}) : super(key: key);

  @override
  State<AddEditRecordScreen> createState() => _AddEditRecordScreenState();
}

class _AddEditRecordScreenState extends State<AddEditRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _doctorNameController = TextEditingController();
  final TextEditingController _facilityNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  String _selectedRecordType = 'Lab Report';
  List<String> _selectedTags = [];
  File? _selectedFile;
  String? _filePreviewUrl;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  bool _isEditing = false;
  
  final List<String> _recordTypes = [
    'Lab Report',
    'Prescription',
    'Vaccination',
    'Imaging',
    'Surgery',
    'Consultation',
    'Insurance',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (widget.existingRecord != null) {
      _isEditing = true;
      _titleController.text = widget.existingRecord!['title'] as String;
      _doctorNameController.text = widget.existingRecord!['doctorName'] as String;
      _facilityNameController.text = widget.existingRecord!['facilityName'] as String? ?? '';
      _notesController.text = widget.existingRecord!['notes'] as String? ?? '';
      _selectedDate = DateTime.parse(widget.existingRecord!['date'] as String);
      _selectedRecordType = widget.existingRecord!['recordType'] as String;
      _selectedTags = (widget.existingRecord!['tags'] as List?)?.map((tag) => tag as String).toList() ?? [];
      _filePreviewUrl = widget.existingRecord!['fileUrl'] as String?;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _doctorNameController.dispose();
    _facilityNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.lightTheme.colorScheme.primary,
              onPrimary: AppTheme.lightTheme.colorScheme.onPrimary,
              surface: AppTheme.lightTheme.colorScheme.surface,
              onSurface: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _handleFileSelected(File file) {
    setState(() {
      _selectedFile = file;
      _filePreviewUrl = null;
    });
  }

  void _cancelUpload() {
    setState(() {
      _isUploading = false;
      _uploadProgress = 0.0;
    });
  }

  Future<bool> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> _saveDraftLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordDraft = {
        'title': _titleController.text,
        'doctorName': _doctorNameController.text,
        'facilityName': _facilityNameController.text,
        'notes': _notesController.text,
        'date': _selectedDate.toIso8601String(),
        'recordType': _selectedRecordType,
        'tags': _selectedTags,
        'hasFile': _selectedFile != null || _filePreviewUrl != null,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await prefs.setString('record_draft', recordDraft.toString());
      
      Fluttertoast.showToast(
        msg: "Draft saved locally. Please try again when you're online.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to save draft: ${e.toString()}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.error,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Check connectivity
      bool isConnected = await _checkConnectivity();
      if (!isConnected) {
        await _saveDraftLocally();
        return;
      }

      setState(() {
        _isUploading = true;
      });

      try {
        // Simulate file upload with progress
        if (_selectedFile != null) {
          for (int i = 0; i <= 100; i += 10) {
            await Future.delayed(const Duration(milliseconds: 100));
            setState(() {
              _uploadProgress = i / 100;
            });
            if (!_isUploading) break; // Check if upload was cancelled
          }
        }

        if (!_isUploading) return; // Upload was cancelled

        // Simulate API call
        await Future.delayed(const Duration(seconds: 1));

        // Success
        Fluttertoast.showToast(
          msg: _isEditing ? "Record updated successfully!" : "Record added successfully!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.success,
          textColor: Colors.white,
        );

        // Navigate back to dashboard
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/medical-records-dashboard');
        }
      } catch (e) {
        setState(() {
          _isUploading = false;
        });
        
        Fluttertoast.showToast(
          msg: "Error: ${e.toString()}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.error,
          textColor: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Medical Record' : 'Add Medical Record'),
        leading: IconButton(
          icon: const CustomIconWidget(
            iconName: 'arrow_back',
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                  children: [
                    // Document Upload Section
                    DocumentUploadWidget(
                      onFileSelected: _handleFileSelected,
                      existingFileUrl: _filePreviewUrl,
                      selectedFile: _selectedFile,
                    ),
                    SizedBox(height: 3.h),
                    
                    // Required Fields
                    FormFieldWidget(
                      controller: _titleController,
                      label: 'Title',
                      hint: 'Enter record title',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                      prefixIcon: 'title',
                    ),
                    SizedBox(height: 2.h),
                    
                    // Date Picker
                    CustomDatePickerWidget(
                      selectedDate: _selectedDate,
                      onTap: () => _selectDate(context),
                    ),
                    SizedBox(height: 2.h),
                    
                    // Record Type Dropdown
                    RecordTypeDropdownWidget(
                      selectedRecordType: _selectedRecordType,
                      recordTypes: _recordTypes,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedRecordType = value;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 2.h),
                    
                    FormFieldWidget(
                      controller: _doctorNameController,
                      label: 'Doctor Name',
                      hint: 'Enter doctor\'s name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter doctor\'s name';
                        }
                        return null;
                      },
                      prefixIcon: 'person',
                    ),
                    SizedBox(height: 2.h),
                    
                    // Optional Fields - Progressive Disclosure based on record type
                    if (_selectedRecordType == 'Lab Report' || 
                        _selectedRecordType == 'Imaging' || 
                        _selectedRecordType == 'Surgery' ||
                        _selectedRecordType == 'Consultation')
                      Column(
                        children: [
                          FormFieldWidget(
                            controller: _facilityNameController,
                            label: 'Facility Name (Optional)',
                            hint: 'Enter facility name',
                            validator: null,
                            prefixIcon: 'business',
                          ),
                          SizedBox(height: 2.h),
                        ],
                      ),
                    
                    FormFieldWidget(
                      controller: _notesController,
                      label: 'Notes (Optional)',
                      hint: 'Enter additional notes',
                      validator: null,
                      prefixIcon: 'note',
                      maxLines: 3,
                    ),
                    SizedBox(height: 2.h),
                    
                    // Tags Input
                    TagInputWidget(
                      selectedTags: _selectedTags,
                      onTagsChanged: (tags) {
                        setState(() {
                          _selectedTags = tags;
                        });
                      },
                    ),
                    
                    // Extra space at bottom for the fixed submit button
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
              
              // Upload Progress Indicator
              if (_isUploading)
                Container(
                  color: Colors.black.withAlpha(128),
                  child: Center(
                    child: Card(
                      margin: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Uploading Record...',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            SizedBox(height: 2.h),
                            LinearProgressIndicator(
                              value: _uploadProgress,
                              backgroundColor: AppTheme.lightTheme.colorScheme.surface,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.lightTheme.colorScheme.primary,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '${(_uploadProgress * 100).toInt()}%',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            SizedBox(height: 2.h),
                            TextButton(
                              onPressed: _cancelUpload,
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: AppTheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isUploading ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 1.5.h),
            disabledBackgroundColor: AppTheme.lightTheme.colorScheme.primary.withAlpha(128),
          ),
          child: Text(_isEditing ? 'Update Record' : 'Save Record'),
        ),
      ),
    );
  }
}