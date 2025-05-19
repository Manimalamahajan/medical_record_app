import 'package:flutter/material.dart';

import '../core/utils/logger.dart';
import '../core/utils/pref_utils.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

// lib/providers/auth_provider.dart






enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService;
  final PrefUtils _prefUtils;
  
  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;
  bool _isBiometricAvailable = false;

  AuthProvider({required ApiService apiService, required PrefUtils prefUtils}) 
      : _apiService = apiService, 
        _prefUtils = prefUtils {
    _init();
  }

  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isBiometricAvailable => _isBiometricAvailable;

  bool get isLoggedIn => _status == AuthStatus.authenticated && _user != null;

  Future<void> _init() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final token = _prefUtils.getToken();
      if (token.isNotEmpty) {
        // Token exists, try to get user profile
        _user = await _apiService.getUserProfile();
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      Logger.log('Auth initialization error: $e');
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'Session expired. Please log in again.';
    }

    // Check biometric availability in a real app would use local_auth package
    await Future.delayed(const Duration(milliseconds: 500));
    _isBiometricAvailable = true; // Simulating that biometrics are available

    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _errorMessage = null;
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final user = await _apiService.login(email, password);
      _user = user;
      _status = AuthStatus.authenticated;
      
      // Store token in shared preferences
      await _prefUtils.setToken('mock_jwt_token_for_demo');
      
      notifyListeners();
      return true;
    } catch (e) {
      Logger.log('Login error: $e');
      _status = AuthStatus.error;
      _errorMessage = 'Invalid email or password';
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String? phoneNumber) async {
    _errorMessage = null;
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final user = await _apiService.register(name, email, password, phoneNumber);
      _user = user;
      _status = AuthStatus.authenticated;
      
      // Store token in shared preferences
      await _prefUtils.setToken('mock_jwt_token_for_new_user');
      
      notifyListeners();
      return true;
    } catch (e) {
      Logger.log('Registration error: $e');
      _status = AuthStatus.error;
      _errorMessage = 'Registration failed. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithBiometric() async {
    if (!_isBiometricAvailable) return false;
    
    _errorMessage = null;
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      // In a real app, this would use local_auth package to authenticate
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulate successful authentication
      _user = await _apiService.getUserProfile();
      _status = AuthStatus.authenticated;
      
      // Store token in shared preferences
      await _prefUtils.setToken('mock_jwt_token_from_biometric');
      
      notifyListeners();
      return true;
    } catch (e) {
      Logger.log('Biometric authentication error: $e');
      _status = AuthStatus.error;
      _errorMessage = 'Biometric authentication failed';
      notifyListeners();
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    _errorMessage = null;
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      await _apiService.forgotPassword(email);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } catch (e) {
      Logger.log('Forgot password error: $e');
      _status = AuthStatus.error;
      _errorMessage = 'Failed to send password reset link';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      // Clear token from shared preferences
      await _prefUtils.clearPreferencesData();
      
      _user = null;
      _status = AuthStatus.unauthenticated;
    } catch (e) {
      Logger.log('Logout error: $e');
      _errorMessage = 'Failed to logout';
      _status = AuthStatus.error;
    }

    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    }
    notifyListeners();
  }
}