import 'package:apclassstone/bloc/auth/auth_bloc.dart';
import 'package:apclassstone/bloc/auth/auth_event.dart';
import 'package:apclassstone/bloc/auth/auth_state.dart';
import 'package:apclassstone/core/session/session_manager.dart';
import 'package:apclassstone/presentation/screens/auth/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

import '../../../core/constants/image_constant.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_overlay.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() == true) {
      context.read<LoginBloc>().add(
            FetchLogin(
              username: _usernameController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  Widget _buildCredentialRow(String role, String email, String password) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              role,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryGold,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                _usernameController.text = email;
                _passwordController.text = password;
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$email / $password',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) async {
          if (state is LoginSuccess) {
            print("Access Token: ${state.response.data!.accessToken!}");
            // ✅ FIXED: Single saveUserSession call with ALL required params
            final success = await SessionManager.saveUserSession(
              userId: state.response.data!.userId.toString(),        // ✅ REQUIRED
              userRole: state.response.data!.role!.toLowerCase(),    // ✅ "executive"
              userName: state.response.data!.fullName,
                              // ✅ Add phone if available
              accessToken: state.response.data!.accessToken!,
              refreshToken: state.response.data!.refreshToken!,
              // headerKey: "Bearer ${state.response.data!.accessToken}", // Optional
            );

            // Set token expiry AFTER session save
            await SessionManager.setAccessTokenExpiry(
              state.response.data!.accessTokenExpiresAt!,
            );

            if (success) {
              print('🎉 Session saved! Role: ${SessionManager.getRefreshToken()}');
              print('🔍 Debug: ${SessionManager.getUserName()}');
              if (mounted) {
                final role = state.response.data!
                    .role
                    ?.toLowerCase()
                    .toString();
                print("Navigating to dashboard for role: $role");
                print("executive role: ${AppConstants.roleExecutive}");
                print("superadmin role: ${AppConstants.roleSuperAdmin}");
                if (role == AppConstants.roleExecutive) {
                  context.goNamed('executive-dashboard', extra: role);
                } else if (role == AppConstants.roleSuperAdmin) {
                  context.goNamed('superadmin-dashboard', extra: role);
                } else {
                  context.goNamed('admin-dashboard', extra: role);
                }
              }
            }
          } else if (state is LoginError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.backgroundGradient,
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),

                        // Logo Section
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                  padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.black.withValues(alpha: 0.1),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child:
                                Image.asset(ImageConstant.logo, fit: BoxFit.contain)
                              ),
                              const SizedBox(height: 24),
                              Text(
                                AppConstants.appName.toUpperCase(),
                                style: textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondaryBlue,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Welcome Back',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(duration: const Duration(milliseconds: 600))
                            .slideY(
                              begin: -0.3,
                              end: 0,
                              curve: Curves.easeOutBack,
                            ),

                        const SizedBox(height: 20),

                        // Login Form
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Sign In',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 18),

                              // Username Field
                              CustomTextField(
                                controller: _usernameController,
                                label: 'Username',
                                hintText: 'Enter your username',
                                prefixIcon: Icons.person_outline,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Please enter your username';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Password Field
                              CustomTextField(
                                controller: _passwordController,
                                label: 'Password',
                                hintText: 'Enter your password',
                                prefixIcon: Icons.lock_outline,
                                isPassword: true,
                                isPasswordVisible: _isPasswordVisible,
                                onTogglePasswordVisibility: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Please enter your password';
                                  }
                                  if (value!.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),

                              // Remember Me & Forgot Password
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Row(
                                  //   children: [
                                  //     Checkbox(
                                  //       value: _rememberMe,
                                  //       onChanged: (value) {
                                  //         setState(() {
                                  //           _rememberMe = value ?? false;
                                  //         });
                                  //       },
                                  //       activeColor: AppColors.primaryGold,
                                  //     ),
                                  //     const Text(
                                  //       'Remember me',
                                  //       style: TextStyle(
                                  //         fontSize: 14,
                                  //         color: AppColors.textSecondary,
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                  TextButton(
                                    onPressed: () {
                                      // Handle forgot password
                                    },
                                    child: Text(
                                      'Forgot Password?',
                                      style: textTheme.labelMedium?.copyWith(
                                        color: AppColors.secondaryBlue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Login Button
                              BlocBuilder<LoginBloc, LoginState>(
                                builder: (context, state) {
                                  return CustomButton(
                                    text: 'Sign In',
                                    onPressed: _handleLogin,
                                    isLoading: state is LoginLoading,
                                    // gradient: AppColors.primaryGradient,
                                    gradient: AppColors.newGradient,
                                  );
                                },
                              ),
                              const SizedBox(height: 20),

                              // Register Link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account? ",
                                    style: textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                                     // context.push("/registrationScreen");
                                    },
                                    child: Text(
                                      'Register',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: AppColors.secondaryBlue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Demo Credentials Helper
                              // Container(
                              //   padding: const EdgeInsets.all(12),
                              //   decoration: BoxDecoration(
                              //     color: AppColors.primaryGold.withValues(alpha: 0.1),
                              //     borderRadius: BorderRadius.circular(8),
                              //     border: Border.all(
                              //       color: AppColors.primaryGold.withValues(alpha: 0.3),
                              //     ),
                              //   ),
                              //   child: Column(
                              //     crossAxisAlignment: CrossAxisAlignment.start,
                              //     children: [
                              //       const Row(
                              //         children: [
                              //           Icon(
                              //             Icons.info_outline,
                              //             color: AppColors.primaryGold,
                              //             size: 18,
                              //           ),
                              //           SizedBox(width: 8),
                              //           Text(
                              //             'Demo Credentials',
                              //             style: TextStyle(
                              //               fontSize: 14,
                              //               fontWeight: FontWeight.w600,
                              //               color: AppColors.primaryGold,
                              //             ),
                              //           ),
                              //         ],
                              //       ),
                              //       const SizedBox(height: 8),
                              //       _buildCredentialRow('Super Admin', 'superadmin@acls.local', 'SuperAdmin123!'),
                              //       _buildCredentialRow('Admin', 'adm@adm.com', '123456'),
                              //       _buildCredentialRow('Executive', 'demouser4@gmail.com', 'demouser4'),
                              //     ],
                              //   ),
                              // ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(
                              delay: const Duration(milliseconds: 300),
                              duration: const Duration(milliseconds: 600),
                            )
                            .slideY(
                              begin: 0.3,
                              end: 0,
                              curve: Curves.easeOutBack,
                            ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            BlocBuilder<LoginBloc, LoginState>(
              builder: (context, state) {
                if (state is LoginLoading) {
                  return const LoadingOverlay();
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
