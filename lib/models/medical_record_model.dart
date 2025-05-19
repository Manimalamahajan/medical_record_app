import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// lib/models/medical_record_model.dart



class MedicalRecord {
  final String id;
  final String title;
  final String recordType;
  final String doctorName;
  final String facilityName;
  final DateTime date;
  final String notes;
  final List<String> tags;
  final String? fileUrl;
  final Color color;
  final DateTime lastUpdated;
  final bool isShared;
  final DateTime? shareExpiryDate;
  final String? shareLink;

  MedicalRecord({
    required this.id,
    required this.title,
    required this.recordType,
    required this.doctorName,
    required this.facilityName,
    required this.date,
    required this.notes,
    required this.tags,
    this.fileUrl,
    required this.color,
    required this.lastUpdated,
    this.isShared = false,
    this.shareExpiryDate,
    this.shareLink,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'] as String,
      title: json['title'] as String,
      recordType: json['record_type'] as String,
      doctorName: json['doctor_name'] as String,
      facilityName: json['facility_name'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String? ?? '',
      tags: List<String>.from(json['tags'] as List),
      fileUrl: json['file_url'] as String?,
      color: _getColorForRecordType(json['record_type'] as String),
      lastUpdated: json['last_updated'] != null 
          ? DateTime.parse(json['last_updated'] as String)
          : DateTime.parse(json['date'] as String),
      isShared: json['is_shared'] as bool? ?? false,
      shareExpiryDate: json['share_expiry_date'] != null 
          ? DateTime.parse(json['share_expiry_date'] as String)
          : null,
      shareLink: json['share_link'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'record_type': recordType,
      'doctor_name': doctorName,
      'facility_name': facilityName,
      'date': date.toIso8601String(),
      'notes': notes,
      'tags': tags,
      'file_url': fileUrl,
      'last_updated': lastUpdated.toIso8601String(),
      'is_shared': isShared,
      'share_expiry_date': shareExpiryDate?.toIso8601String(),
      'share_link': shareLink,
    };
  }

  MedicalRecord copyWith({
    String? id,
    String? title,
    String? recordType,
    String? doctorName,
    String? facilityName,
    DateTime? date,
    String? notes,
    List<String>? tags,
    String? fileUrl,
    Color? color,
    DateTime? lastUpdated,
    bool? isShared,
    DateTime? shareExpiryDate,
    String? shareLink,
  }) {
    return MedicalRecord(
      id: id ?? this.id,
      title: title ?? this.title,
      recordType: recordType ?? this.recordType,
      doctorName: doctorName ?? this.doctorName,
      facilityName: facilityName ?? this.facilityName,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      fileUrl: fileUrl ?? this.fileUrl,
      color: color ?? this.color,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isShared: isShared ?? this.isShared,
      shareExpiryDate: shareExpiryDate ?? this.shareExpiryDate,
      shareLink: shareLink ?? this.shareLink,
    );
  }

  // Helper method to determine color based on record type
  static Color _getColorForRecordType(String recordType) {
    switch (recordType) {
      case 'Lab Report':
        return AppTheme.labReport;
      case 'Prescription':
      case 'Medication':
        return AppTheme.medication;
      case 'Vaccination':
        return AppTheme.vaccination;
      case 'Consultation':
      case 'Appointment':
        return AppTheme.appointment;
      case 'Imaging':
      case 'Surgery':
      case 'Insurance':
        return AppTheme.info;
      default:
        return AppTheme.primary;
    }
  }

  // Convenience method to convert from Map<String, dynamic> format used in the app
  factory MedicalRecord.fromMapFormat(Map<String, dynamic> map) {
    return MedicalRecord(
      id: map['id'] as String,
      title: map['title'] as String,
      recordType: map['recordType'] as String,
      doctorName: map['doctorName'] as String,
      facilityName: map['facilityName'] as String? ?? '',
      date: map['date'] is String 
          ? DateTime.parse(map['date'] as String)
          : map['date'] as DateTime,
      notes: map['notes'] as String? ?? '',
      tags: (map['tags'] as List).map((item) => item as String).toList(),
      fileUrl: map['fileUrl'] as String?,
      color: map['color'] as Color? ?? _getColorForRecordType(map['recordType'] as String),
      lastUpdated: map['lastUpdated'] != null 
          ? map['lastUpdated'] is String 
              ? DateTime.parse(map['lastUpdated'] as String)
              : map['lastUpdated'] as DateTime
          : map['date'] is String 
              ? DateTime.parse(map['date'] as String)
              : map['date'] as DateTime,
      isShared: map['isShared'] as bool? ?? false,
      shareExpiryDate: map['shareExpiryDate'] != null 
          ? map['shareExpiryDate'] is String 
              ? DateTime.parse(map['shareExpiryDate'] as String)
              : map['shareExpiryDate'] as DateTime
          : null,
      shareLink: map['shareLink'] as String?,
    );
  }

  // Convert to Map<String, dynamic> format used in the app
  Map<String, dynamic> toMapFormat() {
    return {
      'id': id,
      'title': title,
      'recordType': recordType,
      'doctorName': doctorName,
      'facilityName': facilityName,
      'date': date.toIso8601String(),
      'notes': notes,
      'tags': tags,
      'fileUrl': fileUrl,
      'color': color,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isShared': isShared,
      'shareExpiryDate': shareExpiryDate?.toIso8601String(),
      'shareLink': shareLink,
    };
  }
}