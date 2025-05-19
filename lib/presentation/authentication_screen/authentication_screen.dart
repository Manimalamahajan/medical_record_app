// lib/presentation/authentication_screen/authentication_screen.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../providers/auth_provider.dart';
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
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Initialize authentication state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      setState(() {
        _isLoading = authProvider.status == AuthStatus.loading;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(email, password);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        if (success) {
          _showSuccessToast("Login successful!");
          Navigator.pushReplacementNamed(context, '/medical-records-dashboard');
        } else {
          _showErrorToast(authProvider.errorMessage ?? "Login failed. Please try again.");
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorToast("Authentication failed: ${e.toString()}");
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
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.register(name, email, password, phoneNumber);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        if (success) {
          _showSuccessToast("Registration successful!");
          Navigator.pushReplacementNamed(context, '/medical-records-dashboard');
        } else {
          _showErrorToast(authProvider.errorMessage ?? "Registration failed. Please try again.");
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorToast("Registration failed: ${e.toString()}");
      }
    }
  }

  void _handleBiometricAuth() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.loginWithBiometric();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        if (success) {
          _showSuccessToast("Biometric authentication successful!");
          Navigator.pushReplacementNamed(context, '/medical-records-dashboard');
        } else {
          _showErrorToast(authProvider.errorMessage ?? "Biometric authentication failed.");
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorToast("Biometric authentication failed: ${e.toString()}");
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
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.forgotPassword(email);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        if (success) {
          _showSuccessToast("Password reset link sent to $email");
        } else {
          _showErrorToast(authProvider.errorMessage ?? "Failed to send reset link.");
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorToast("Failed to send reset link: ${e.toString()}");
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
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            // If already authenticated, redirect to dashboard
            if (authProvider.status == AuthStatus.authenticated && !_isLoading) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacementNamed(context, '/medical-records-dashboard');
              });
            }
            
            // Show loading state from provider
            final bool showLoading = _isLoading || authProvider.status == AuthStatus.loading;
            final bool showBiometric = authProvider.isBiometricAvailable;
            
            return Stack(
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
                                    (showBiometric ? 42.h : 36.h) : 
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
                                            if (showBiometric)
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
                if (showLoading)
                  Container(
                    color: Colors.black.withAlpha(128),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}