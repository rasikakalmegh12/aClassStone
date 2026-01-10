import 'package:apclassstone/bloc/auth/auth_bloc.dart';
import 'package:apclassstone/bloc/auth/auth_state.dart';
import 'package:apclassstone/bloc/client/get_client/get_client_bloc.dart';
import 'package:apclassstone/bloc/client/post_client/post_client_bloc.dart';
import 'package:apclassstone/bloc/dashboard/dashboard_bloc.dart';
import 'package:apclassstone/bloc/mom/mom_bloc.dart';
import 'package:apclassstone/bloc/work_plan/work_plan_bloc.dart';
import 'package:apclassstone/core/constants/app_constants.dart';
import 'package:apclassstone/presentation/screens/attendance/attendance_tracking.dart';
import 'package:apclassstone/presentation/screens/auth/register_screen.dart';
import 'package:apclassstone/presentation/screens/super_admin/screens/all_users_screen.dart';
import 'package:apclassstone/presentation/screens/super_admin/screens/pending_users_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../api/models/response/GetCatalogueProductResponseBody.dart';
import '../../bloc/attendance/attendance_bloc.dart';
import '../../bloc/bloc.dart';
import '../../bloc/catalogue/get_catalogue_methods/get_catalogue_bloc.dart';
import '../../bloc/catalogue/post_catalogue_methods/post_catalogue_bloc.dart';
import '../../bloc/generate_pdf/generate_pdf_bloc.dart';
import '../../bloc/lead/lead_bloc.dart';
import '../../bloc/registration/registration_bloc.dart';
import '../../bloc/user_management/user_management_bloc.dart';
import '../../bloc/work_plan/work_plan_decision_bloc.dart';
import '../../core/services/repository_provider.dart';
import '../../presentation/catalog/catalog_main.dart';
import '../../presentation/catalog/catalogue_entry.dart';
import '../../presentation/screens/attendance/attendance_monthly_tracking.dart';
import '../../presentation/screens/executive/clients/add_client_screen.dart';
import '../../presentation/screens/executive/clients/clients_list_screen.dart';
import '../../presentation/screens/executive/leads/add_to_lead.dart';
import '../../presentation/screens/executive/leads/leads_list_screen.dart';
import '../../presentation/screens/executive/leads/new_lead_screen.dart';
import '../../presentation/screens/executive/meetings/meetings_list_screen.dart';
import '../../presentation/screens/executive/meetings/new_mom_screen.dart';
import '../../presentation/screens/executive/work_plans/create_work_plan_screen.dart';
import '../../presentation/screens/executive/work_plans/work_plans_list_screen.dart';
import '../../presentation/screens/executive_history/executive_history_tracking_screen.dart';
import '../../presentation/screens/executive_history/executive_tracking.dart';
import '../../presentation/screens/profile/profile_screen.dart';

import '../../presentation/screens/dashboard/admin_dashboard.dart';
import '../../presentation/screens/dashboard/admin_dashboard_screen.dart';
import '../../presentation/screens/dashboard/executive_dashboard.dart';
import '../../presentation/screens/dashboard/executive_dashboard_screen.dart';
import '../../presentation/screens/dashboard/super_admin_dashboard_screen.dart';
import '../../presentation/screens/meeting/meeting_detail_screen.dart';
import '../../presentation/screens/meeting/meeting_list_screen.dart';
import '../../presentation/screens/registration/pending_registrations_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/dashboard/dashboard_router.dart';

import 'package:apclassstone/api/models/models.dart';

import '../../presentation/screens/super_admin/screens/super_admin_dashboard.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
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
      // GoRoute(
      //   path: '/dashboard',
      //   name: 'dashboard',
      //   builder: (context, state) {
      //     final user = state.extra as String?;
      //     if (user == null) {
      //       return const LoginScreen();
      //     }
      //
      //
      //     // Only trigger redirect when the incoming location is exactly '/dashboard'
      //     // to avoid redirect loops. Use a post-frame callback to call context.go.
      //     if ((state.matchedLocation == '/dashboard') && user != null) {
      //       WidgetsBinding.instance.addPostFrameCallback((_) {
      //         if (user == AppConstants.roleExecutive) {
      //           context.go('/dashboard/executive', extra: user);
      //         } else if (user == AppConstants.roleSuperAdmin) {
      //           context.go('/dashboard/superadmin', extra: user);
      //         } else {
      //           context.go('/dashboard/admin', extra: user);
      //         }
      //       });
      //
      //       // Return an empty placeholder while the redirect happens.
      //       return const SizedBox.shrink();
      //     }
      //
      //     // If we're already on a child route (or role is not yet available),
      //     // return the dashboard router which will build the nested screens.
      //     return DashboardRouter(user: user);
      //   },
      //   routes: [
      //     // NOTE: child paths have no leading '/'
      //     GoRoute(
      //       path: 'executive',
      //       name: 'executive-dashboard',
      //       builder: (context, state) {
      //         final user = state.extra as String?;
      //         return ExecutiveDashboardScreen(user: user!);
      //       },
      //     ),
      //
      //     GoRoute(
      //       path: 'admin',
      //       name: 'admin-dashboard',
      //       builder: (context, state) {
      //         final user = state.extra as String?;
      //         return MultiBlocProvider(
      //           providers: [
      //             BlocProvider<PendingBloc>(
      //               create: (context) => PendingBloc(),
      //             ),
      //           ],
      //           child: AdminDashboardScreen(user: user!),
      //         );
      //       },
      //     ),
      //
      //     GoRoute(
      //       path: 'superadmin',
      //       name: 'superadmin-dashboard',
      //       builder: (context, state) {
      //         final user = state.extra as String?;
      //         return MultiBlocProvider(
      //           providers: [
      //             BlocProvider<PendingBloc>(create: (context) => PendingBloc(),),
      //             BlocProvider<AllUsersBloc>(create: (context) => AllUsersBloc(),),
      //             BlocProvider<ApproveRegistrationBloc>(create: (context) => ApproveRegistrationBloc(),),
      //             BlocProvider<RejectRegistrationBloc>(create: (context) => RejectRegistrationBloc(),),
      //           ],
      //           child: SuperAdminDashboardScreen(user: user!),
      //         );
      //       },
      //
      //     ),
      //   ],
      // ),


      GoRoute(
        path: '/executive',
        name: 'executive-dashboard',
        builder: (context, state) {
          final user = state.extra as String?;
          return
            MultiBlocProvider(
              providers: [
                BlocProvider<PendingBloc>(
                  create: (context) => PendingBloc(),
                ),

                BlocProvider<ActiveSessionBloc>(
                  create: (context) => ActiveSessionBloc(),
                ),
                BlocProvider(create: (_) => PunchInBloc()),
                BlocProvider(create: (_) => PunchOutBloc()),
                BlocProvider(create: (_) => LocationPingBloc()),
                BlocProvider(create: (_) => ActiveSessionBloc()),
              ],
              child:  ExecutiveDashboard(user: user!)
            );

        },
      ),

      GoRoute(
        path: '/admin',
        name: 'admin-dashboard',
        builder: (context, state) {
          final user = state.extra as String?;
          return MultiBlocProvider(
            providers: [
              BlocProvider<PendingBloc>(
                create: (context) => PendingBloc(),
              ),
              BlocProvider<AllUsersBloc>(create: (context) => AllUsersBloc(),),
            ],
            child: AdminDashboard(user: user!),
          );
        },
      ),

      GoRoute(
        path: '/superadmin',
        name: 'superadmin-dashboard',
        builder: (context, state) {
          final user = state.extra as String?;
          return MultiBlocProvider(
            providers: [
              BlocProvider<PendingBloc>(create: (context) => PendingBloc(),),
              BlocProvider<AllUsersBloc>(create: (context) => AllUsersBloc(),),
              BlocProvider<ApproveRegistrationBloc>(create: (context) => ApproveRegistrationBloc(),),
              BlocProvider<RejectRegistrationBloc>(create: (context) => RejectRegistrationBloc(),),
            ],
            child: SuperAdminDashboard(user: user!),
          );
        },

      ),
      GoRoute(
        path: '/allUsersScreen',
        name: 'allUsersScreen',
        builder: (context, state) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<PendingBloc>(create: (context) => PendingBloc(),),
              BlocProvider<AllUsersBloc>(create: (context) => AllUsersBloc(),),
              BlocProvider<ApproveRegistrationBloc>(create: (context) => ApproveRegistrationBloc(),),
              BlocProvider<RejectRegistrationBloc>(create: (context) => RejectRegistrationBloc(),),
              BlocProvider<UserManagementBloc>(create: (context) => UserManagementBloc(),),
              ],
            child: const AllUsersScreen(),
          );
        },
      ),
      GoRoute(
        path: '/pendingUsersScreen',
        name: 'pendingUsersScreen',
        builder: (context, state) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<PendingBloc>(create: (context) => PendingBloc(),),
              BlocProvider<AllUsersBloc>(create: (context) => AllUsersBloc(),),
              BlocProvider<ApproveRegistrationBloc>(create: (context) => ApproveRegistrationBloc(),),
              BlocProvider<RejectRegistrationBloc>(create: (context) => RejectRegistrationBloc(),),
            ],
            child: const PendingUsersScreen(),
          );
        },
      ),
      GoRoute(
        path: '/catalogueEntry',
        name: 'catalogueEntry',
        builder: (context, state) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<GetProductTypeBloc>(create: (context) => GetProductTypeBloc(),),
              BlocProvider<GetUtilitiesBloc>(create: (context) => GetUtilitiesBloc(),),
              BlocProvider<GetColorsBloc>(create: (context) => GetColorsBloc(),),
              BlocProvider<GetFinishesBloc>(create: (context) => GetFinishesBloc(),),
              BlocProvider<GetTexturesBloc>(create: (context) => GetTexturesBloc(),),
              BlocProvider<GetNaturalColorsBloc>(create: (context) => GetNaturalColorsBloc(),),
              BlocProvider<GetOriginsBloc>(create: (context) => GetOriginsBloc(),),
              BlocProvider<GetStateCountriesBloc>(create: (context) => GetStateCountriesBloc(),),
              BlocProvider<GetProcessingNatureBloc>(create: (context) => GetProcessingNatureBloc(),),
              BlocProvider<GetNaturalMaterialBloc>(create: (context) => GetNaturalMaterialBloc(),),
              BlocProvider<GetHandicraftsBloc>(create: (context) => GetHandicraftsBloc(),),
              BlocProvider<GetMinesOptionBloc>(create: (context) => GetMinesOptionBloc(),),
              BlocProvider<GetPriceRangeBloc>(create: (context) => GetPriceRangeBloc(),),



              BlocProvider<PostColorsBloc>(create: (context) => PostColorsBloc(),),
              BlocProvider<PostFinishesBloc>(create: (context) => PostFinishesBloc(),),
              BlocProvider<PostTexturesBloc>(create: (context) => PostTexturesBloc(),),
              BlocProvider<PostNaturalColorsBloc>(create: (context) => PostNaturalColorsBloc(),),
              BlocProvider<PostOriginsBloc>(create: (context) => PostOriginsBloc(),),
              BlocProvider<PostStateCountriesBloc>(create: (context) => PostStateCountriesBloc(),),
              BlocProvider<PostProcessingNaturesBloc>(create: (context) => PostProcessingNaturesBloc(),),
              BlocProvider<PostNaturalMaterialsBloc>(create: (context) => PostNaturalMaterialsBloc(),),
              BlocProvider<PostHandicraftsTypesBloc>(create: (context) => PostHandicraftsTypesBloc(),),
              BlocProvider<ProductEntryBloc>(create: (context) => ProductEntryBloc(),),
              BlocProvider<CatalogueImageEntryBloc>(create: (context) => CatalogueImageEntryBloc(),),
              BlocProvider<PutCatalogueOptionsEntryBloc>(create: (context) => PutCatalogueOptionsEntryBloc(),),
              BlocProvider<PostMinesEntryBloc>(create: (context) => PostMinesEntryBloc(),),
              BlocProvider<PostSearchBloc>(create: (context) => PostSearchBloc(),),
            ],
            child: const CatalogueEntryPage(),
          );
        },
      ),
      // Profile Route
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const UserProfilePage(),
      ),

      // Attendance Routes

      GoRoute(
          path: '/attendanceTracking',
          name: 'attendanceTracking',
          builder: (context, state) {
            return   MultiBlocProvider(
              providers: [
                BlocProvider<ExecutiveAttendanceBloc>(create: (context) => ExecutiveAttendanceBloc(),),
              ],
              child: const AttendanceTracking(),
            );
          }
      ),


      GoRoute(
          path: '/attendanceMonthlyTracking',
          name: 'attendanceMonthlyTracking',
          builder: (context, state) {
            final userId = state.extra as String?;
            return   MultiBlocProvider(
              providers: [
                BlocProvider<AttendanceTrackingMonthlyBloc>(create: (context) => AttendanceTrackingMonthlyBloc(),),
              ],
              child: AttendanceMonthlyTracking(userId: userId!,),
            );
          }
      ),

      // Executive Tracking Routes
      GoRoute(
        path: '/executiveHistoryTracking',
        name: 'executiveHistoryTracking',
        builder: (context, state) {
        return   MultiBlocProvider(
              providers: [
              BlocProvider<ExecutiveAttendanceBloc>(create: (context) => ExecutiveAttendanceBloc(),),

              ],
              child: const ExecutiveHistoryScreen(),
              );
        }
      ),

      GoRoute(
        path: '/executiveTracking',
        name: 'executiveTracking',
        builder: (context, state) {
          // Retrieve the extra data
          final extra = state.extra as Map<String, dynamic>;
          final userId = extra['userId'] as String;
          final date = extra['date'] as String;

          return
            MultiBlocProvider(
              providers: [
                BlocProvider<ExecutiveTrackingBloc>(create: (context) => ExecutiveTrackingBloc(),),
              ],
              child: ExecutiveTracking(userId: userId, date: date),
            );

        },
      ),

      GoRoute(
        path: '/clientsListScreen',
        name: 'clientsListScreen',
        builder: (context, state) {

          return MultiBlocProvider(
              providers: [
                BlocProvider<GetClientListBloc>(create: (context) => GetClientListBloc(),),
                BlocProvider<GetClientDetailsBloc>(create: (context) => GetClientDetailsBloc(),),
                BlocProvider<PostClientAddContactBloc>(create: (context) => PostClientAddContactBloc(),),
                BlocProvider<PostClientAddLocationBloc>(create: (context) => PostClientAddLocationBloc(),),
              ],
              child: const ClientsListScreen(),
            );

        },
      ),

      GoRoute(
        path: '/addClientScreen',
        name: 'addClientScreen',
        builder: (context, state) {



          return
            MultiBlocProvider(
              providers: [
                BlocProvider<GetClientListBloc>(create: (context) => GetClientListBloc(),),
                BlocProvider<GetClientDetailsBloc>(create: (context) => GetClientDetailsBloc(),),
                BlocProvider<PostClientAddBloc>(create: (context) => PostClientAddBloc(),),
              ],
              child: const AddClientScreen(),
            );

        },
      ),

      GoRoute(
        path: '/momScreen',
        name: 'momScreen',
        builder: (context, state) {
          return
            MultiBlocProvider(
              providers: [
                BlocProvider<GetClientListBloc>(create: (context) => GetClientListBloc(),),
                BlocProvider<GetClientDetailsBloc>(create: (context) => GetClientDetailsBloc(),),
                BlocProvider<PostMomEntryBloc>(create: (context) => PostMomEntryBloc(),),
                BlocProvider(create: (_) => MomImageUploadBloc()),
                BlocProvider<GetCatalogueProductListBloc>(create: (context) => GetCatalogueProductListBloc(),),
                BlocProvider<GetCatalogueProductDetailsBloc>(create: (context) => GetCatalogueProductDetailsBloc(),),
              ],
              child: const NewMomScreen(),
            );

        },
      ),

      GoRoute(
        path: '/momDetailsScreen',
        name: 'momDetailsScreen',
        builder: (context, state) {

          return  MultiBlocProvider(
            providers: [
              BlocProvider<GetClientListBloc>(create: (context) => GetClientListBloc(),),
              BlocProvider<GetClientDetailsBloc>(create: (context) => GetClientDetailsBloc(),),
              BlocProvider<PostWorkPlanBloc>(create: (context) => PostWorkPlanBloc(),),
              BlocProvider<GetWorkPlanDetailsBloc>(create: (context) => GetWorkPlanDetailsBloc(),),
              BlocProvider<GetWorkPlanListBloc>(create: (context) => GetWorkPlanListBloc(),),
              BlocProvider<GetMomDetailsBloc>(create: (context) => GetMomDetailsBloc(),),
              BlocProvider<GetMomListBloc>(create: (context) => GetMomListBloc(),),
            ],
            child: const MeetingsListScreen(),
          );
        },
      ),

      GoRoute(
        path: '/createWorkPlan',
        name: 'createWorkPlan',
        builder: (context, state) {

          return  MultiBlocProvider(
            providers: [
              BlocProvider<GetClientListBloc>(create: (context) => GetClientListBloc(),),
              BlocProvider<GetClientDetailsBloc>(create: (context) => GetClientDetailsBloc(),),
              BlocProvider<PostWorkPlanBloc>(create: (context) => PostWorkPlanBloc(),),
              BlocProvider<GetWorkPlanDetailsBloc>(create: (context) => GetWorkPlanDetailsBloc(),),
              BlocProvider<GetWorkPlanListBloc>(create: (context) => GetWorkPlanListBloc(),),
              BlocProvider<WorkPlanDecisionBloc>(create: (context) => WorkPlanDecisionBloc(),),
            ],
            child: const CreateWorkPlanScreen(),
          );
        },
      ),

      GoRoute(
        path: '/workPlanDetails',
        name: 'workPlanDetails',
        builder: (context, state) {

          return  MultiBlocProvider(
            providers: [
              BlocProvider<GetClientListBloc>(create: (context) => GetClientListBloc(),),
              BlocProvider<GetClientDetailsBloc>(create: (context) => GetClientDetailsBloc(),),
              BlocProvider<PostClientAddBloc>(create: (context) => PostClientAddBloc(),),
              BlocProvider<GetMomListBloc>(create: (context) => GetMomListBloc(),),
              BlocProvider<GetMomDetailsBloc>(create: (context) => GetMomDetailsBloc(),),
              BlocProvider<GetWorkPlanListBloc>(create: (context) => GetWorkPlanListBloc(),),
              BlocProvider<GetWorkPlanDetailsBloc>(create: (context) => GetWorkPlanDetailsBloc(),),
              BlocProvider<WorkPlanDecisionBloc>(create: (context) => WorkPlanDecisionBloc(),),
            ],
            child: const WorkPlansListScreen(),
          );
        },
      ),
      GoRoute(
        path: '/leadScreenList',
        name: 'leadScreenList',
        builder: (context, state) {

          return  MultiBlocProvider(
            providers: [
              BlocProvider<GetClientListBloc>(create: (context) => GetClientListBloc(),),
              BlocProvider<GetClientDetailsBloc>(create: (context) => GetClientDetailsBloc(),),
              BlocProvider<PostClientAddBloc>(create: (context) => PostClientAddBloc(),),
              BlocProvider<GetMomListBloc>(create: (context) => GetMomListBloc(),),
              BlocProvider<GetMomDetailsBloc>(create: (context) => GetMomDetailsBloc(),),
              BlocProvider<GetLeadDetailsBloc>(create: (context) => GetLeadDetailsBloc(),),
              BlocProvider<GetLeadListBloc>(create: (context) => GetLeadListBloc(),),
            ],
            child: const LeadsListScreen(),
          );
        },
      ),
      GoRoute(
        path: '/newLeadScreen',
        name: 'newLeadScreen',
        builder: (context, state) {
          final leadData = state.extra as Map<String, dynamic>?;
          return MultiBlocProvider(
            providers: [
              BlocProvider<GetCatalogueProductListBloc>(
                create: (context) => GetCatalogueProductListBloc(),
              ),
              BlocProvider<GetClientListBloc>(create: (context) => GetClientListBloc(),),
              BlocProvider<GetClientDetailsBloc>(create: (context) => GetClientDetailsBloc(),),
              BlocProvider<PostClientAddBloc>(create: (context) => PostClientAddBloc(),),
              BlocProvider<GetMomListBloc>(create: (context) => GetMomListBloc(),),
              BlocProvider<GetMomDetailsBloc>(create: (context) => GetMomDetailsBloc(),),
              BlocProvider<GetAssignableUsersBloc>(create: (context) => GetAssignableUsersBloc(),),
            ],
            child: NewLeadScreen(
              existingLead: leadData, // Pass the extra data
            ),
          );
        },
      ),

      // Meeting Routes
      GoRoute(
        name: 'addToLead',
        path: '/addToLead',
        builder: (context, state) {
          final selected = state.extra as List<Items>;
          return AddToLeadPage(selectedProducts: selected);
        },
      ),

      GoRoute(
        path: '/cataloguePage',
        name: 'cataloguePage',
        builder: (context, state) {
          final meetingId = state.pathParameters['meetingId'];
          // return MeetingDetailScreen(meetingId: meetingId);
          return MultiBlocProvider(
              providers:[
                BlocProvider<GetCatalogueProductListBloc>(create: (context) => GetCatalogueProductListBloc(),),
                BlocProvider<GetCatalogueProductDetailsBloc>(create: (context) => GetCatalogueProductDetailsBloc(),),
                // Filter BLoCs - using singleton instances from AppBlocProvider
                BlocProvider<GetProductTypeBloc>.value(value: AppBlocProvider.getProductTypeBloc),
                BlocProvider<GetUtilitiesBloc>.value(value: AppBlocProvider.getUtilitiesBloc),
                BlocProvider<GetColorsBloc>.value(value: AppBlocProvider.getColorsBloc),
                BlocProvider<GetFinishesBloc>.value(value: AppBlocProvider.getFinishesBloc),
                BlocProvider<GetTexturesBloc>.value(value: AppBlocProvider.getTexturesBloc),
                BlocProvider<GetNaturalColorsBloc>.value(value: AppBlocProvider.getNaturalColorsBloc),
                BlocProvider<GetOriginsBloc>.value(value: AppBlocProvider.getOriginsBloc),
                BlocProvider<GetStateCountriesBloc>.value(value: AppBlocProvider.getStateCountriesBloc),
                BlocProvider<GetProcessingNatureBloc>.value(value: AppBlocProvider.getProcessingNatureBloc),
                BlocProvider<GetNaturalMaterialBloc>.value(value: AppBlocProvider.getNaturalMaterialBloc),
                BlocProvider<GetHandicraftsBloc>.value(value: AppBlocProvider.getHandicraftsBloc),
                BlocProvider<GetPriceRangeBloc>.value(value: AppBlocProvider.getPriceRangeBloc),
                BlocProvider<GetMinesOptionBloc>.value(value: AppBlocProvider.getMinesOptionBloc),
                BlocProvider<GeneratePdfBloc>.value(value: AppBlocProvider.generatePdfBloc),
              ],
              child: const CataloguePage());
        },
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

  // static GoRouter get router => _router;
  //
  // // Navigation Helper Methods
  // static void goToLogin(BuildContext context) {
  //   context.goNamed('login');
  // }
  //
  // static void goToDashboard(BuildContext context, String user) {
  //   context.goNamed('dashboard', extra: user);
  // }
  //
  // static void goToProfile(BuildContext context) {
  //   context.goNamed('profile');
  // }
  //
  // static void goToAttendance(BuildContext context) {
  //   context.goNamed('executive_history');
  // }
  //
  // static void goToMeetings(BuildContext context) {
  //   context.goNamed('meetings');
  // }
  //
  // static void goToMeetingDetail(BuildContext context, String meetingId) {
  //   context.goNamed('meeting-detail', pathParameters: {'meetingId': meetingId});
  // }
  //
  // static void goToRegistrations(BuildContext context) {
  //   context.goNamed('pendingRegistrations');
  // }
  //
  // static void goToExecutiveDashboard(BuildContext context, String user) {
  //   context.goNamed('executive-dashboard', extra: user);
  // }
  //
  // static void goToAdminDashboard(BuildContext context, String user) {
  //   context.goNamed('admin-dashboard', extra: user);
  // }
  //
  // static void goToSuperAdminDashboard(BuildContext context, String user) {
  //   context.goNamed('superadmin-dashboard', extra: user);
  // }

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

// // Extension for easier navigation
// extension AppRouterExtension on BuildContext {
//   void goToLogin() => AppRouter.goToLogin(this);
//
//   void goToDashboard(String user) => AppRouter.goToDashboard(this, user);
//
//   void goToProfile() => AppRouter.goToProfile(this);
//
//   void goToAttendance() => AppRouter.goToAttendance(this);
//
//   void goToMeetings() => AppRouter.goToMeetings(this);
//
//   void goToMeetingDetail(String meetingId) =>
//       AppRouter.goToMeetingDetail(this, meetingId);
//
//   void goToRegistrations() => AppRouter.goToRegistrations(this);
//   void goToAllUsersScreen() => AppRouter._router.pushNamed('allUsersScreen');
//   void goToPendingUsersScreen() => AppRouter._router.pushNamed('pendingUsersScreen');
//
//   void goToExecutiveDashboard(String user) =>
//       AppRouter.goToExecutiveDashboard(this, user);
//
//   void goToAdminDashboard(String user) =>
//       AppRouter.goToAdminDashboard(this, user);
//
//   void goToSuperAdminDashboard(String user) =>
//       AppRouter.goToSuperAdminDashboard(this, user);
// }
