import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../bloc/auth/auth_event.dart';
import '../../../bloc/bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_overlay.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String _selectedRole = AppConstants.roleExecutive;

  final List<Map<String, String>> _roles = [
    {'value': AppConstants.roleExecutive, 'label': 'Executive'},
    {'value': AppConstants.roleAdmin, 'label': 'Admin'},
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState?.validate() == true) {
      context.read<RegistrationBloc>().add(
        RegisterUserEvent(
              fullName: _usernameController.text.trim(),
              password: _passwordController.text,
              email: _emailController.text.trim(),
              phone: _phoneController.text.trim(),
              appCode: AppConstants.appCode,

            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<RegistrationBloc, RegistrationState>(
        listener: (context, state) {
          if (state is RegistrationSuccess) {

            if(state.response.statusCode==200){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.response.message!),
                  backgroundColor: AppColors.success,
                ),
              );
              Navigator.of(context).pop();
            }
            else{

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.response.message!),
                  backgroundColor: AppColors.success,
                ),
              );
            }


          } else if (state is RegistrationError) {
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
                        // Header
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(
                                Icons.arrow_back,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Create Account',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Registration Form
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withOpacity( 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Register with ${AppConstants.appName}',
                                style: GoogleFonts.lato(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),

                              // Name Fields
                              // Row(
                              //   children: [
                              //     Expanded(
                              //       child: CustomTextField(
                              //         controller: _firstNameController,
                              //         label: 'First Name',
                              //         hintText: 'Enter first name',
                              //         prefixIcon: Icons.person_outline,
                              //         validator: (value) {
                              //           if (value?.isEmpty ?? true) {
                              //             return 'First name is required';
                              //           }
                              //           return null;
                              //         },
                              //       ),
                              //     ),
                              //     const SizedBox(width: 12),
                              //     Expanded(
                              //       child: CustomTextField(
                              //         controller: _lastNameController,
                              //         label: 'Last Name',
                              //         hintText: 'Enter last name',
                              //         validator: (value) {
                              //           if (value?.isEmpty ?? true) {
                              //             return 'Last name is required';
                              //           }
                              //           return null;
                              //         },
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              // const SizedBox(height: 16),

                              // Username Field
                              CustomTextField(
                                controller: _usernameController,
                                label: 'Full Name',
                                hintText: 'Enter Full Name',
                                prefixIcon: Icons.person_2_outlined,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Full Name is required';
                                  }
                                  if (value!.length < 3) {
                                    return 'Full Name must be at least 3 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Email Field
                              CustomTextField(
                                controller: _emailController,
                                label: 'Email',
                                hintText: 'Enter your email',
                                prefixIcon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Email is required';
                                  }
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(value!)) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                maxLength: 10,
                                controller: _phoneController,
                                label: 'Phone',
                                hintText: 'Enter your mobile number',
                                prefixIcon: Icons.phone_android_rounded,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Mobile Number is required';
                                  }

                                  if (!RegExp(r'^\d+$').hasMatch(value!)) {
                                    return 'Enter a valid mobile number (digits only)';
                                  }
                                  return null;
                                },
                              ),
                              //
                              // // Role Selection
                              // Column(
                              //   crossAxisAlignment: CrossAxisAlignment.start,
                              //   children: [
                              //     Text(
                              //       'Role',
                              //       style: GoogleFonts.lato(
                              //         fontSize: 14,
                              //         fontWeight: FontWeight.w600,
                              //         color: AppColors.textPrimary,
                              //       ),
                              //     ),
                              //     const SizedBox(height: 8),
                              //     Container(
                              //       padding: const EdgeInsets.symmetric(
                              //         horizontal: 16,
                              //         vertical: 4,
                              //       ),
                              //       decoration: BoxDecoration(
                              //         color: AppColors.grey50,
                              //         borderRadius: BorderRadius.circular(
                              //           AppConstants.borderRadius,
                              //         ),
                              //         border: Border.all(
                              //           color: AppColors.grey200,
                              //         ),
                              //       ),
                              //       child: DropdownButtonHideUnderline(
                              //         child: DropdownButton<String>(
                              //           value: _selectedRole,
                              //           isExpanded: true,
                              //           icon: const Icon(
                              //             Icons.keyboard_arrow_down,
                              //             color: AppColors.grey500,
                              //           ),
                              //           style: GoogleFonts.lato(
                              //             fontSize: 16,
                              //             color: AppColors.textPrimary,
                              //           ),
                              //           onChanged: (String? newValue) {
                              //             if (newValue != null) {
                              //               setState(() {
                              //                 _selectedRole = newValue;
                              //               });
                              //             }
                              //           },
                              //           items: _roles.map<DropdownMenuItem<String>>(
                              //             (Map<String, String> role) {
                              //               return DropdownMenuItem<String>(
                              //                 value: role['value'],
                              //                 child: Text(role['label']!),
                              //               );
                              //             },
                              //           ).toList(),
                              //         ),
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              const SizedBox(height: 16),

                              // Password Fields
                              CustomTextField(
                                controller: _passwordController,
                                label: 'Password',
                                hintText: 'Create a password',
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
                                    return 'Password is required';
                                  }
                                  if (value!.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              CustomTextField(
                                controller: _confirmPasswordController,
                                label: 'Confirm Password',
                                hintText: 'Confirm your password',
                                prefixIcon: Icons.lock_outline,
                                isPassword: true,
                                isPasswordVisible: _isConfirmPasswordVisible,
                                onTogglePasswordVisibility: () {
                                  setState(() {
                                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                  });
                                },
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Please confirm your password';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),

                              // Register Button
                              BlocBuilder<RegistrationBloc, RegistrationState>(
                                builder: (context, state) {
                                  return CustomButton(
                                    text: 'Register',
                                    onPressed: _handleRegister,
                                    isLoading: state is RegistrationLoading,
                                    gradient: AppColors.secondaryGradient,
                                  );
                                },
                              ),
                              const SizedBox(height: 16),

                              // Info Text
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.info.withOpacity( 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.info.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      color: AppColors.info,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Your registration will be reviewed and approved by a Super Admin.',
                                        style: GoogleFonts.lato(
                                          fontSize: 12,
                                          color: AppColors.info,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(duration: const Duration(milliseconds: 600))
                            .slideY(
                              begin: 0.3,
                              end: 0,
                              curve: Curves.easeOutBack,
                            ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            BlocBuilder<RegistrationBloc, RegistrationState>(
              builder: (context, state) {
                if (state is RegistrationLoading) {
                  return const LoadingOverlay(message: 'Submitting registration...');
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
