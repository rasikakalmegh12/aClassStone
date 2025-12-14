import 'package:apclassstone/bloc/auth/auth_bloc.dart';
import 'package:apclassstone/bloc/auth/auth_state.dart';
import 'package:apclassstone/presentation/screens/auth/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/bloc.dart';
import '../../bloc/registration/registration_bloc.dart';
import '../../presentation/screens/attendance/attendance_history_screen.dart';
import '../../presentation/screens/auth/profile_screen.dart';
import '../../presentation/screens/dashboard/admin_dashboard_screen.dart';
import '../../presentation/screens/dashboard/executive_dashboard_screen.dart';
import '../../presentation/screens/dashboard/super_admin_dashboard_screen.dart';
import '../../presentation/screens/meeting/meeting_detail_screen.dart';
import '../../presentation/screens/meeting/meeting_list_screen.dart';
import '../../presentation/screens/registration/pending_registrations_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/dashboard/dashboard_router.dart';

import 'package:apclassstone/api/models/models.dart';

class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: '/splash',
    // redirect: _handleRedirect,
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Dashboard + nested dashboards
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) {
          final user = state.extra as String?;
          if (user == null) {
            return const LoginScreen();
          }
          return DashboardRouter(user: user);
        },
        routes: [
          // NOTE: child paths have no leading '/'
          GoRoute(
            path: 'executive',
            name: 'executive-dashboard',
            builder: (context, state) {
              final user = state.extra as String?;
              return ExecutiveDashboardScreen(user: user!);
            },
          ),

          GoRoute(
            path: 'admin',
            name: 'admin-dashboard',
            builder: (context, state) {
              final user = state.extra as String?;
              return MultiBlocProvider(
                providers: [
                  BlocProvider<PendingBloc>(
                    create: (context) => PendingBloc(),
                  ),
                ],
                child: AdminDashboardScreen(user: user!),
              );
            },
          ),

          GoRoute(
            path: 'superadmin',
            name: 'superadmin-dashboard',
            builder: (context, state) {
              final user = state.extra as String?;
              return MultiBlocProvider(
                providers: [
                  BlocProvider<PendingBloc>(
                    create: (context) => PendingBloc(),
                  ),
                ],
                child: SuperAdminDashboardScreen(user: user!),
              );
            },
          ),
        ],
      ),

      // Profile Route
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // Attendance Routes
      GoRoute(
        path: '/attendance',
        name: 'attendance',
        builder: (context, state) => const AttendanceHistoryScreen(),
      ),

      // Meeting Routes
      GoRoute(
        path: '/meetings',
        name: 'meetings',
        builder: (context, state) => const MeetingListScreen(),
        routes: [
          GoRoute(
            path: ':meetingId',
            name: 'meeting-detail',
            builder: (context, state) {
              final meetingId = state.pathParameters['meetingId']!;
              return MeetingDetailScreen(meetingId: meetingId);
            },
          ),
        ],
      ),

      // Registration Management Routes
      GoRoute(
        path: '/pendingRegistrations',
        name: 'pendingRegistrations',
        builder: (context, state) => const PendingRegistrationsScreen(),
      ),

      GoRoute(
        path: '/registrationScreen',
        name: 'registrationScreen',
        builder: (context, state) => const RegisterScreen(),
      ),
    ],
  );

  static GoRouter get router => _router;

  // Navigation Helper Methods
  static void goToLogin(BuildContext context) {
    context.goNamed('login');
  }

  static void goToDashboard(BuildContext context, String user) {
    context.goNamed('dashboard', extra: user);
  }

  static void goToProfile(BuildContext context) {
    context.goNamed('profile');
  }

  static void goToAttendance(BuildContext context) {
    context.goNamed('attendance');
  }

  static void goToMeetings(BuildContext context) {
    context.goNamed('meetings');
  }

  static void goToMeetingDetail(BuildContext context, String meetingId) {
    context.goNamed('meeting-detail', pathParameters: {'meetingId': meetingId});
  }

  static void goToRegistrations(BuildContext context) {
    context.goNamed('pendingRegistrations');
  }

  static void goToExecutiveDashboard(BuildContext context, String user) {
    context.goNamed('executive-dashboard', extra: user);
  }

  static void goToAdminDashboard(BuildContext context, String user) {
    context.goNamed('admin-dashboard', extra: user);
  }

  static void goToSuperAdminDashboard(BuildContext context, String user) {
    context.goNamed('superadmin-dashboard', extra: user);
  }

  // Optional redirect logic (keep commented until wired)
  static String? _handleRedirect(BuildContext context, GoRouterState state) {
    final authBloc = context.read<LoginBloc>();
    final authState = authBloc.state;

    final isGoingToLogin = state.matchedLocation == '/login';
    final isGoingToSplash = state.matchedLocation == '/splash';

    if (authState is LoginLoading || authState is LoginInitial) {
      return isGoingToSplash ? null : '/splash';
    }

    if (authState is LoginSuccess) {
      if (isGoingToLogin || isGoingToSplash) {
        return '/dashboard';
      }
      return null;
    }

    if (authState is LoginError) {
      return isGoingToLogin ? null : '/login';
    }

    return null;
  }
}

// Extension for easier navigation
extension AppRouterExtension on BuildContext {
  void goToLogin() => AppRouter.goToLogin(this);

  void goToDashboard(String user) => AppRouter.goToDashboard(this, user);

  void goToProfile() => AppRouter.goToProfile(this);

  void goToAttendance() => AppRouter.goToAttendance(this);

  void goToMeetings() => AppRouter.goToMeetings(this);

  void goToMeetingDetail(String meetingId) =>
      AppRouter.goToMeetingDetail(this, meetingId);

  void goToRegistrations() => AppRouter.goToRegistrations(this);

  void goToExecutiveDashboard(String user) =>
      AppRouter.goToExecutiveDashboard(this, user);

  void goToAdminDashboard(String user) =>
      AppRouter.goToAdminDashboard(this, user);

  void goToSuperAdminDashboard(String user) =>
      AppRouter.goToSuperAdminDashboard(this, user);
}
