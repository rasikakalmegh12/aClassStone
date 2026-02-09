import 'package:apclassstone/core/session/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/image_constant.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _backgroundController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 2000));

    if (mounted) {
      final isLoggedIn = await SessionManager.isLoggedIn();
      print("Checking login status...$isLoggedIn");
      print("Checking login status...${SessionManager.getUserId()}");
      if (isLoggedIn) {

// File: `lib/presentation/screens/splash/splash_screen.dart`
// Use the exact route names defined in `AppRouter` and pass the role as extra.
        if (mounted) {
          final role = SessionManager.getUserRole().toString().toLowerCase();
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

        // context.go("/dashboard",extra: SessionManager.getUserIdSync().toString().toLowerCase());
      } else {
        context.go("/login");
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // gradient: AppColors.primaryGradient,
          gradient: AppColors.newGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Logo Container
                      Container(
                        width: 150,
                        height: 150,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child:
                          Image.asset(ImageConstant.logo, fit: BoxFit.contain)
                        // const Icon(
                        //   Icons.diamond,
                        //   size: 80,
                        //   color: AppColors.primaryGold,
                        // ),
                      )
                          .animate(controller: _logoController)
                          .scale(
                            begin: const Offset(0.3, 0.3),
                            end: const Offset(1.0, 1.0),
                            curve: Curves.elasticOut,
                          )
                          .fadeIn(
                            duration: const Duration(milliseconds: 600),
                          )
                          .then(delay: const Duration(milliseconds: 200))
                          .shake(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          ),

                      const SizedBox(height: 40),

                      // Company Name Animation
                      const Text(
                        AppConstants.appName,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          letterSpacing: 2,
                        ),
                      )
                          .animate(controller: _textController)
                          .slideY(
                            begin: 1.0,
                            end: 0.0,
                            curve: Curves.easeOutBack,
                          )
                          .fadeIn(
                            duration: const Duration(milliseconds: 800),
                          ),

                      const SizedBox(height: 16),

                      // Tagline Animation
                      Text(
                        AppConstants.companyTagline,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.white.withOpacity(0.9),
                          letterSpacing: 1,
                        ),
                        textAlign: TextAlign.center,
                      )
                          .animate(controller: _textController)
                          .slideY(
                            begin: 1.0,
                            end: 0.0,
                            curve: Curves.easeOutBack,
                          )
                          .fadeIn(
                            delay: const Duration(milliseconds: 200),
                            duration: const Duration(milliseconds: 800),
                          ),

                      const SizedBox(height: 60),

                      // Animated Loading Indicator
                      SizedBox(
                        width: 200,
                        child: LinearProgressIndicator(
                          backgroundColor: AppColors.white.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.white,
                          ),
                        ),
                      )
                          .animate(controller: _textController)
                          .fadeIn(
                            delay: const Duration(milliseconds: 400),
                            duration: const Duration(milliseconds: 600),
                          )
                          .slideX(
                            begin: -1.0,
                            end: 0.0,
                            curve: Curves.easeOutCubic,
                          ),
                    ],
                  ),
                ),
              ),

              // Bottom Section with Floating Stones Animation
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    )
                        .animate(
                          onPlay: (controller) => controller.repeat(),
                        )
                        .moveY(
                          begin: 0,
                          end: -20,
                          duration: Duration(
                            milliseconds: 1000 + (index * 200),
                          ),
                          curve: Curves.easeInOut,
                        )
                        .then()
                        .moveY(
                          begin: -20,
                          end: 0,
                          duration: Duration(
                            milliseconds: 1000 + (index * 200),
                          ),
                          curve: Curves.easeInOut,
                        );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
