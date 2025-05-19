import 'package:flutter/material.dart';
import '../presentation/add_edit_record_screen/add_edit_record_screen.dart';
import '../presentation/medical_records_dashboard/medical_records_dashboard.dart';
import '../presentation/authentication_screen/authentication_screen.dart';
import '../presentation/record_detail_screen/record_detail_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String addEditRecordScreen = '/add-edit-record-screen';
  static const String medicalRecordsDashboard = '/medical-records-dashboard';
  static const String recordDetailScreen = '/record-detail-screen';
  static const String authenticationScreen = '/authentication-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const MedicalRecordsDashboard(), // Using MedicalRecordsDashboard as initial route
    addEditRecordScreen: (context) => const AddEditRecordScreen(),
    medicalRecordsDashboard: (context) => const MedicalRecordsDashboard(),
    recordDetailScreen: (context) => const RecordDetailScreen(),
    authenticationScreen: (context) => const AuthenticationScreen(),
  };
}