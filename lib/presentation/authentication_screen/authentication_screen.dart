import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/auth_header_widget.dart';
import './widgets/biometric_auth_widget.dart';
import './widgets/login_form_widget.dart';
import './widgets/register_form_widget.dart';
import 'widgets/auth_header_widget.dart';
import 'widgets/biometric_auth_widget.dart';
import 'widgets/login_form_widget.dart';
import 'widgets/register_form_widget.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({Key? key}) : super(key: key);

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  bool _isBiometricAvailable = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkBiometricAvailability();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricAvailability() async {
    // In a real app, you would use local_auth package to check biometric availability
    // For this demo, we'll simulate biometric availability
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _isBiometricAvailable = true; // Simulating that biometrics are available
    });
  }

  Future<bool> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  void _handleLogin(String email, String password) async {
    // Check connectivity first
    bool isConnected = await _checkConnectivity();
    if (!isConnected) {
      _showErrorToast("No internet connection. Please check your network and try again.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock authentication logic
      if (email == "user@example.com" && password == "password123") {
        // Success - store token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', 'mock_jwt_token_for_demo');
        
        if (mounted) {
          _showSuccessToast("Login successful!");
          Navigator.pushReplacementNamed(context, '/medical-records-dashboard');
        }
      } else {
        // Failed authentication
        _showErrorToast("Invalid email or password. Please try again.");
      }
    } catch (e) {
      _showErrorToast("Authentication failed: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleRegister(String name, String email, String password, String phoneNumber) async {
    // Check connectivity first
    bool isConnected = await _checkConnectivity();
    if (!isConnected) {
      _showErrorToast("No internet connection. Please check your network and try again.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock registration success
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', 'mock_jwt_token_for_new_user');
      await prefs.setString('user_name', name);
      await prefs.setString('user_email', email);
      
      if (mounted) {
        _showSuccessToast("Registration successful!");
        Navigator.pushReplacementNamed(context, '/medical-records-dashboard');
      }
    } catch (e) {
      _showErrorToast("Registration failed: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleBiometricAuth() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate biometric authentication
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock successful biometric auth
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', 'mock_jwt_token_from_biometric');
      
      if (mounted) {
        _showSuccessToast("Biometric authentication successful!");
        Navigator.pushReplacementNamed(context, '/medical-records-dashboard');
      }
    } catch (e) {
      _showErrorToast("Biometric authentication failed: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleForgotPassword(String email) async {
    if (email.isEmpty) {
      _showErrorToast("Please enter your email address first.");
      return;
    }

    // Check connectivity
    bool isConnected = await _checkConnectivity();
    if (!isConnected) {
      _showErrorToast("No internet connection. Please check your network and try again.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock password reset email sent
      _showSuccessToast("Password reset link sent to $email");
    } catch (e) {
      _showErrorToast("Failed to send reset link: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.success,
      textColor: Colors.white,
    );
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.error,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            LayoutBuilder(
              builder: (context, constraints) {
                // Responsive layout
                final bool isTablet = constraints.maxWidth > 600;
                final double cardWidth = isTablet ? 70.w : 90.w;
                
                return Center(
                  child: SingleChildScrollView(
                    child: Center(
                      child: Container(
                        width: cardWidth,
                        margin: EdgeInsets.symmetric(vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.lightTheme.colorScheme.shadow.withAlpha(26),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header with logo
                            const AuthHeaderWidget(),
                            
                            // Tab bar
                            Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: AppTheme.lightTheme.colorScheme.outline.withAlpha(128),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: TabBar(
                                controller: _tabController,
                                tabs: const [
                                  Tab(text: 'Login'),
                                  Tab(text: 'Register'),
                                ],
                                labelColor: AppTheme.lightTheme.colorScheme.primary,
                                unselectedLabelColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                                indicatorColor: AppTheme.lightTheme.colorScheme.primary,
                                indicatorWeight: 3,
                              ),
                            ),
                            
                            // Tab content
                            SizedBox(
                              height: _tabController.index == 0 ? 
                                (_isBiometricAvailable ? 42.h : 36.h) : 
                                52.h,
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  // Login Tab
                                  Padding(
                                    padding: EdgeInsets.all(4.w),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: LoginFormWidget(
                                            onLogin: _handleLogin,
                                            onForgotPassword: _handleForgotPassword,
                                          ),
                                        ),
                                        
                                        // Biometric authentication option
                                        if (_isBiometricAvailable)
                                          BiometricAuthWidget(
                                            onBiometricAuth: _handleBiometricAuth,
                                          ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Register Tab
                                  Padding(
                                    padding: EdgeInsets.all(4.w),
                                    child: RegisterFormWidget(
                                      onRegister: _handleRegister,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            
            // Loading overlay
            if (_isLoading)
              Container(
                color: Colors.black.withAlpha(128),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}