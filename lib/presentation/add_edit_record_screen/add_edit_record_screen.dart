import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../models/medical_record_model.dart';
import '../../providers/medical_records_provider.dart';
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
  const AddEditRecordScreen({Key? key}) : super(key: key);

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
  bool _isEditing = false;
  String? _recordId;
  
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeData();
  }

  void _initializeData() {
    // Extract record data from arguments if editing an existing record
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments != null && arguments is Map<String, dynamic> && arguments.containsKey('record')) {
      final recordData = arguments['record'] as Map<String, dynamic>;
      _isEditing = true;
      _recordId = recordData['id'];
      _titleController.text = recordData['title'];
      _doctorNameController.text = recordData['doctorName'];
      _facilityNameController.text = recordData['facilityName'] ?? '';
      _notesController.text = recordData['notes'] ?? '';
      _selectedDate = recordData['date'] is DateTime 
          ? recordData['date'] 
          : DateTime.parse(recordData['date']);
      _selectedRecordType = recordData['recordType'];
      _selectedTags = (recordData['tags'] as List).map((e) => e.toString()).toList();
      _filePreviewUrl = recordData['fileUrl'];
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

  Future<bool> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> _saveDraftLocally() async {
    try {
      // Show toast about saving draft locally
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

      final recordsProvider = Provider.of<MedicalRecordsProvider>(context, listen: false);

      try {
        bool success;
        
        if (_isEditing && _recordId != null) {
          // Update existing record
          success = await recordsProvider.updateRecord(
            id: _recordId!,
            title: _titleController.text,
            recordType: _selectedRecordType,
            doctorName: _doctorNameController.text,
            facilityName: _facilityNameController.text,
            date: _selectedDate,
            notes: _notesController.text,
            tags: _selectedTags,
            documentFile: _selectedFile,
          );
        } else {
          // Create new record
          success = await recordsProvider.createRecord(
            title: _titleController.text,
            recordType: _selectedRecordType,
            doctorName: _doctorNameController.text,
            facilityName: _facilityNameController.text,
            date: _selectedDate,
            notes: _notesController.text,
            tags: _selectedTags,
            documentFile: _selectedFile,
          );
        }

        if (success) {
          // Success toast
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
        } else {
          // Error toast
          Fluttertoast.showToast(
            msg: recordsProvider.errorMessage ?? "Failed to ${_isEditing ? 'update' : 'create'} record",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: AppTheme.error,
            textColor: Colors.white,
          );
        }
      } catch (e) {
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
    return Consumer<MedicalRecordsProvider>(
      builder: (context, recordsProvider, _) {
        final bool isUploading = recordsProvider.isUploading;
        final double uploadProgress = recordsProvider.uploadProgress;
        
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
                  if (isUploading)
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
                                  value: uploadProgress,
                                  backgroundColor: AppTheme.lightTheme.colorScheme.surface,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.lightTheme.colorScheme.primary,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  '${(uploadProgress * 100).toInt()}%',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                SizedBox(height: 2.h),
                                TextButton(
                                  onPressed: () => recordsProvider.cancelUpload(),
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
              onPressed: isUploading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                disabledBackgroundColor: AppTheme.lightTheme.colorScheme.primary.withAlpha(128),
              ),
              child: Text(_isEditing ? 'Update Record' : 'Save Record'),
            ),
          ),
        );
      },
    );
  }
}