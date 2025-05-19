import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../core/utils/logger.dart';
import '../models/medical_record_model.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';

// lib/services/api_service.dart










class ApiService {
  late final Dio _dio;
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? 'https://api.example.com';

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    
    // Add interceptors for logging and token handling
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (log) => Logger.log(log.toString())
    ));
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add token to all requests if available
        // final prefs = await SharedPreferences.getInstance();
        // final token = prefs.getString('token');
        // if (token != null && token.isNotEmpty) {
        //   options.headers['Authorization'] = 'Bearer $token';
        // }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Handle common errors
        Logger.log('API Error: ${e.message}');
        return handler.next(e);
      },
    ));
  }

  // Authentication APIs
  Future<User> login(String email, String password) async {
    try {
      // In a real app, this would call the actual API
      // final response = await _dio.post('/auth/login', data: {
      //   'email': email,
      //   'password': password,
      // });
      
      // Mocked API response
      await Future.delayed(const Duration(seconds: 2));
      if (email == "user@example.com" && password == "password123") {
        return User(
          id: 'user123',
          name: 'Sample User',
          email: 'user@example.com',
          phoneNumber: '+1234567890',
        );
      } else {
        throw DioException(
          requestOptions: RequestOptions(),
          error: 'Invalid credentials',
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 401,
            requestOptions: RequestOptions(),
            data: {'message': 'Invalid email or password'},
          ),
        );
      }
    } catch (e) {
      Logger.log('Login error: $e');
      rethrow;
    }
  }

  Future<User> register(String name, String email, String password, String? phoneNumber) async {
    try {
      // In a real app, this would call the actual API
      // final response = await _dio.post('/auth/register', data: {
      //   'name': name,
      //   'email': email,
      //   'password': password,
      //   'phone_number': phoneNumber,
      // });
      
      // Mocked API response
      await Future.delayed(const Duration(seconds: 2));
      return User(
        id: 'new_user_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        phoneNumber: phoneNumber,
      );
    } catch (e) {
      Logger.log('Register error: $e');
      rethrow;
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      // In a real app, this would call the actual API
      // await _dio.post('/auth/forgot-password', data: {
      //   'email': email,
      // });
      
      // Mocked API response
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      Logger.log('Forgot password error: $e');
      rethrow;
    }
  }

  Future<User> getUserProfile() async {
    try {
      // In a real app, this would call the actual API
      // final response = await _dio.get('/user/profile');
      
      // Mocked API response
      await Future.delayed(const Duration(seconds: 1));
      return User(
        id: 'user123',
        name: 'Sample User',
        email: 'user@example.com',
        phoneNumber: '+1234567890',
      );
    } catch (e) {
      Logger.log('Get user profile error: $e');
      rethrow;
    }
  }

  // Medical Records APIs
  Future<List<MedicalRecord>> getMedicalRecords({int page = 1, int limit = 10}) async {
    try {
      // In a real app, this would call the actual API
      // final response = await _dio.get('/medical-records', queryParameters: {
      //   'page': page,
      //   'limit': limit,
      // });
      
      // Mocked API response
      await Future.delayed(const Duration(seconds: 2));
      final mockRecords = _getMockMedicalRecords()
          .skip((page - 1) * limit)
          .take(limit)
          .toList();
      
      return mockRecords;
    } catch (e) {
      Logger.log('Get medical records error: $e');
      rethrow;
    }
  }

  Future<MedicalRecord> getMedicalRecordById(String id) async {
    try {
      // In a real app, this would call the actual API
      // final response = await _dio.get('/medical-records/$id');
      
      // Mocked API response
      await Future.delayed(const Duration(seconds: 1));
      final mockRecords = _getMockMedicalRecords();
      final record = mockRecords.firstWhere(
        (record) => record.id == id,
        orElse: () => throw DioException(
          requestOptions: RequestOptions(),
          error: 'Record not found',
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 404,
            requestOptions: RequestOptions(),
            data: {'message': 'Record not found'},
          ),
        ),
      );
      
      return record;
    } catch (e) {
      Logger.log('Get medical record by ID error: $e');
      rethrow;
    }
  }

  Future<MedicalRecord> createMedicalRecord({
    required String title,
    required String recordType,
    required String doctorName,
    required String facilityName,
    required DateTime date,
    required String notes,
    required List<String> tags,
    File? documentFile,
  }) async {
    try {
      // In a real app, this would call the actual API with FormData
      // final formData = FormData.fromMap({
      //   'title': title,
      //   'record_type': recordType,
      //   'doctor_name': doctorName,
      //   'facility_name': facilityName,
      //   'date': date.toIso8601String(),
      //   'notes': notes,
      //   'tags': jsonEncode(tags),
      // });
      // 
      // if (documentFile != null) {
      //   formData.files.add(MapEntry(
      //     'document',
      //     await MultipartFile.fromFile(documentFile.path),
      //   ));
      // }
      // 
      // final response = await _dio.post('/medical-records', data: formData);
      
      // Simulate file upload progress
      if (documentFile != null) {
        for (int i = 0; i <= 100; i += 10) {
          await Future.delayed(const Duration(milliseconds: 100));
          // In a real app, you would report progress here
        }
      }
      
      // Mocked API response
      await Future.delayed(const Duration(seconds: 1));
      
      // Generate a new record with unique ID
      final newRecord = MedicalRecord(
        id: 'rec${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        recordType: recordType,
        doctorName: doctorName,
        facilityName: facilityName,
        date: date,
        notes: notes,
        tags: tags,
        fileUrl: documentFile != null ? 'https://example.com/files/${documentFile.path.split('/').last}' : null,
        color: MedicalRecord._getColorForRecordType(recordType),
        lastUpdated: DateTime.now(),
      );
      
      return newRecord;
    } catch (e) {
      Logger.log('Create medical record error: $e');
      rethrow;
    }
  }

  Future<MedicalRecord> updateMedicalRecord({
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
    try {
      // In a real app, this would call the actual API with FormData
      // final formData = FormData.fromMap({
      //   'title': title,
      //   'record_type': recordType,
      //   'doctor_name': doctorName,
      //   'facility_name': facilityName,
      //   'date': date.toIso8601String(),
      //   'notes': notes,
      //   'tags': jsonEncode(tags),
      // });
      // 
      // if (documentFile != null) {
      //   formData.files.add(MapEntry(
      //     'document',
      //     await MultipartFile.fromFile(documentFile.path),
      //   ));
      // }
      // 
      // final response = await _dio.put('/medical-records/$id', data: formData);
      
      // Simulate file upload progress
      if (documentFile != null) {
        for (int i = 0; i <= 100; i += 10) {
          await Future.delayed(const Duration(milliseconds: 100));
          // In a real app, you would report progress here
        }
      }
      
      // Mocked API response
      await Future.delayed(const Duration(seconds: 1));
      
      // Find the record to update
      final mockRecords = _getMockMedicalRecords();
      final existingRecord = mockRecords.firstWhere(
        (record) => record.id == id,
        orElse: () => throw DioException(
          requestOptions: RequestOptions(),
          error: 'Record not found',
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 404,
            requestOptions: RequestOptions(),
            data: {'message': 'Record not found'},
          ),
        ),
      );
      
      // Update the record
      final updatedRecord = existingRecord.copyWith(
        title: title,
        recordType: recordType,
        doctorName: doctorName,
        facilityName: facilityName,
        date: date,
        notes: notes,
        tags: tags,
        fileUrl: documentFile != null ? 'https://example.com/files/${documentFile.path.split('/').last}' : existingRecord.fileUrl,
        color: MedicalRecord._getColorForRecordType(recordType),
        lastUpdated: DateTime.now(),
      );
      
      return updatedRecord;
    } catch (e) {
      Logger.log('Update medical record error: $e');
      rethrow;
    }
  }

  Future<void> deleteMedicalRecord(String id) async {
    try {
      // In a real app, this would call the actual API
      // await _dio.delete('/medical-records/$id');
      
      // Mocked API response
      await Future.delayed(const Duration(seconds: 1));
      // Simulate checking if record exists
      final mockRecords = _getMockMedicalRecords();
      mockRecords.firstWhere(
        (record) => record.id == id,
        orElse: () => throw DioException(
          requestOptions: RequestOptions(),
          error: 'Record not found',
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 404,
            requestOptions: RequestOptions(),
            data: {'message': 'Record not found'},
          ),
        ),
      );
    } catch (e) {
      Logger.log('Delete medical record error: $e');
      rethrow;
    }
  }

  Future<String> createShareLink(String id, int expiryHours, bool includeNotes) async {
    try {
      // In a real app, this would call the actual API
      // final response = await _dio.post('/medical-records/$id/share', data: {
      //   'expiry_hours': expiryHours,
      //   'include_notes': includeNotes,
      // });
      
      // Mocked API response
      await Future.delayed(const Duration(seconds: 1));
      final expiryDate = DateTime.now().add(Duration(hours: expiryHours));
      return 'https://medrec.app/share/$id?exp=${expiryDate.millisecondsSinceEpoch}&notes=${includeNotes ? '1' : '0'}';
    } catch (e) {
      Logger.log('Create share link error: $e');
      rethrow;
    }
  }

  // Utility method to generate mock medical records
  List<MedicalRecord> _getMockMedicalRecords() {
    return [
      MedicalRecord(
        id: "rec001",
        title: "Annual Physical Examination",
        recordType: "Consultation",
        doctorName: "Dr. Sarah Johnson",
        facilityName: "City General Hospital",
        date: DateTime.parse("2023-06-15T09:30:00.000Z"),
        notes: "Regular annual checkup. Blood pressure normal at 120/80. Weight stable. Recommended continued exercise and healthy diet.",
        tags: ["annual", "checkup", "physical"],
        fileUrl: "https://example.com/files/annual_checkup_2023.pdf",
        color: AppTheme.appointment,
        lastUpdated: DateTime.parse("2023-06-15T09:30:00.000Z"),
      ),
      MedicalRecord(
        id: "rec002",
        title: "Blood Test Results",
        recordType: "Lab Report",
        doctorName: "Dr. Michael Chen",
        facilityName: "MedLab Diagnostics",
        date: DateTime.parse("2023-05-22T14:15:00.000Z"),
        notes: "Complete blood count and metabolic panel. All values within normal range except slightly elevated cholesterol (215 mg/dL).",
        tags: ["blood test", "cholesterol", "lab"],
        fileUrl: "https://example.com/files/blood_test_may2023.pdf",
        color: AppTheme.labReport,
        lastUpdated: DateTime.parse("2023-05-22T14:15:00.000Z"),
      ),
      MedicalRecord(
        id: "rec003",
        title: "Flu Vaccination",
        recordType: "Vaccination",
        doctorName: "Dr. Lisa Wong",
        facilityName: "Community Health Clinic",
        date: DateTime.parse("2023-10-05T11:00:00.000Z"),
        notes: "Annual influenza vaccination administered. No immediate adverse reactions.",
        tags: ["flu", "vaccine", "preventive"],
        fileUrl: "https://example.com/files/flu_vaccine_2023.pdf",
        color: AppTheme.vaccination,
        lastUpdated: DateTime.parse("2023-10-05T11:00:00.000Z"),
      ),
      MedicalRecord(
        id: "rec004",
        title: "Hypertension Medication",
        recordType: "Prescription",
        doctorName: "Dr. James Wilson",
        facilityName: "Heart & Vascular Center",
        date: DateTime.parse("2023-04-10T16:45:00.000Z"),
        notes: "Prescription for Lisinopril 10mg, once daily. Follow up in 3 months to assess efficacy.",
        tags: ["medication", "hypertension", "heart"],
        fileUrl: "https://example.com/files/lisinopril_prescription.pdf",
        color: AppTheme.medication,
        lastUpdated: DateTime.parse("2023-04-10T16:45:00.000Z"),
      ),
      MedicalRecord(
        id: "rec005",
        title: "Chest X-Ray",
        recordType: "Imaging",
        doctorName: "Dr. Robert Garcia",
        facilityName: "Radiology Partners",
        date: DateTime.parse("2023-03-18T10:30:00.000Z"),
        notes: "Chest X-ray performed due to persistent cough. Results show no significant abnormalities. Lungs clear.",
        tags: ["x-ray", "chest", "imaging"],
        fileUrl: "https://example.com/files/chest_xray_march2023.pdf",
        color: AppTheme.info,
        lastUpdated: DateTime.parse("2023-03-18T10:30:00.000Z"),
      ),
      // Add more mock records as needed
    ];
  }
}