import 'package:apclassstone/bloc/attendance/attendance_bloc.dart';
import 'package:apclassstone/presentation/widgets/location_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'bloc/auth/auth_bloc.dart';
import 'bloc/auth/auth_state.dart';
import 'bloc/catalogue/get_catalogue_methods/get_catalogue_bloc.dart';
import 'bloc/catalogue/post_catalogue_methods/post_catalogue_bloc.dart';
import 'bloc/dashboard/dashboard_bloc.dart';
import 'bloc/lead/lead_bloc.dart';
import 'bloc/mom/mom_bloc.dart';
import 'bloc/registration/registration_bloc.dart';
import 'bloc/work_plan/work_plan_bloc.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_constants.dart';
import 'core/services/repository_provider.dart';
import 'core/navigation/app_router.dart';
import 'core/session/session_manager.dart';


@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(LocationTaskHandler());
}




Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SessionManager.init();

  // ✅ 2. Geolocator check
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    print('⚠️ Location services disabled');
  }


  AppBlocProvider.initialize();

  // ✅ 3. Foreground Task (with error handling and wake lock settings)
  try {
      FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'location_tracking',
        channelName: 'Location Tracking',
        channelDescription: 'Tracks location while punched in',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        enableVibration: true,
        playSound: false,
        showWhen: false,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(60000), // ✅ 1 minute
        // eventAction: ForegroundTaskEventAction.repeat(180000), // ✅ 1 minute
        allowWakeLock: true, // ✅ Keep CPU awake even when screen is locked
        allowWifiLock: true, // ✅ Keep WiFi awake for network requests
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
      ),
    );
    print('✅ Foreground task initialized with wake lock');
  } catch (e) {
    print('❌ Foreground task init failed: $e');
  }


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
        BlocProvider<GetAssignableUsersBloc>(create: (context) => GetAssignableUsersBloc(),),
        BlocProvider<PostNewLeadBloc>(create: (context) => PostNewLeadBloc(),),
        BlocProvider<GetAssignableUsersBloc>(create: (context) => GetAssignableUsersBloc(),),
            BlocProvider<GetMomDetailsBloc>(create: (context) => GetMomDetailsBloc(),),
            BlocProvider<GetWorkPlanDetailsBloc>(create: (context) => GetWorkPlanDetailsBloc(),),
            BlocProvider<GetWorkPlanListBloc>(create: (context) => GetWorkPlanListBloc(),),
            BlocProvider<PostSearchBloc>(create: (context) => PostSearchBloc(),),
            BlocProvider<GetCatalogueProductDetailsBloc>(create: (context) => GetCatalogueProductDetailsBloc(),),
            BlocProvider(
              create: (context) => AppBlocProvider.authBloc,),
            BlocProvider(
              create: (context) => AppBlocProvider.logoutBloc,),
            BlocProvider(
              create: (context) => AppBlocProvider.registrationBloc,
            ),
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
            BlocProvider(
              create: (context) => AppBlocProvider.locationPingBloc,
            ),
            BlocProvider<LoginBloc>(create: (context) => LoginBloc(),),
            BlocProvider<LogoutBloc>(create: (context) => LogoutBloc(),),
            BlocProvider<PendingBloc>(create: (context) => PendingBloc(),),
            BlocProvider<AllUsersBloc>(create: (context) => AllUsersBloc(),),
            BlocProvider<ApproveRegistrationBloc>(create: (context) => ApproveRegistrationBloc(),),
            BlocProvider<RejectRegistrationBloc>(create: (context) => RejectRegistrationBloc(),),
            BlocProvider<GetProductTypeBloc>(create: (context) => GetProductTypeBloc(),),
            BlocProvider<LocationPingBloc>(create: (context) => LocationPingBloc(),),
            BlocProvider(
              create: (context) => AppBlocProvider.queueBloc,
            ),
            BlocProvider<PostMinesEntryBloc>(create: (context) => PostMinesEntryBloc(),),
            // BlocProvider(
            //   create: (context) => AppBlocProvider.meetingBloc,
            // ),
            // BlocProvider(
            //   create: (context) => AppBlocProvider.userProfileBloc,
            // ),
          ],
          child:
          BlocListener<LoginBloc, LoginState>(
            listener: (context, state) {
              if (state is LoginLoggedOut) {
                // 🔥 Forced logout from anywhere
                context.goNamed('login');
              }
            },
            child: MaterialApp.router(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              theme: _buildTheme(),
              routerConfig: AppRouter.router,
            ),
          ),

          // MaterialApp.router(
          //   title: AppConstants.appName,
          //   debugShowCheckedModeBanner: false,
          //   theme: _buildTheme(),
          //   routerConfig: AppRouter.router,
          // ),
        );
      },
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGold,
        brightness: Brightness.light,
        primary: AppColors.primaryGold,
        onPrimary: AppColors.white,
        secondary: AppColors.secondaryBlue,
        onSecondary: AppColors.white,
        error: AppColors.error,
        onError: AppColors.white,
        surface: AppColors.white,
        onSurface: AppColors.textPrimary,
      ),
      // textTheme: TextStyleTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryGold,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGold,
          foregroundColor: AppColors.white,
          elevation: 2,
          shadowColor: AppColors.black.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryGold,
          side: const BorderSide(color: AppColors.primaryGold, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryGold,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grey50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.grey200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.grey200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryGold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      // cardTheme: const CardThemeData(
      //   color: AppColors.white,
      //   elevation: 2,
      //   shadowColor: Color.fromRGBO(0, 0, 0, 0.1),
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.all(Radius.circular(12.0)),
      //   ),
      // ),
      dividerTheme: const DividerThemeData(
        color: AppColors.grey200,
        thickness: 1,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryGold;
          }
          return AppColors.grey200;
        }),
        checkColor: WidgetStateProperty.all(AppColors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryGold;
          }
          return AppColors.grey400;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryGold;
          }
          return AppColors.grey400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryGold.withValues(alpha: 0.3);
          }
          return AppColors.grey200;
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryGold,
        linearTrackColor: AppColors.grey200,
        circularTrackColor: AppColors.grey200,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.grey800,
        contentTextStyle: const TextStyle(
          color: AppColors.white,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      // dialogTheme: const DialogThemeData(
      //   backgroundColor: AppColors.white,
      //   elevation: 8,
      //   shadowColor: Color.fromRGBO(0, 0, 0, 0.2),
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.all(Radius.circular(16.0)),
      //   ),
      //   titleTextStyle: TextStyle(
      //     fontSize: 18,
      //     fontWeight: FontWeight.bold,
      //     color: AppColors.textPrimary,
      //   ),
      //   contentTextStyle: TextStyle(
      //     fontSize: 14,
      //     color: AppColors.textSecondary,
      //   ),
      // ),
    );
  }
}
