import 'package:apclassstone/bloc/auth/auth_bloc.dart';
import 'package:apclassstone/api/network/network_service.dart';
import 'package:apclassstone/api/network/offline_api_wrapper.dart';
import 'package:apclassstone/data/local/cache_repository.dart';
import 'package:apclassstone/data/local/queue_repository.dart';
import 'package:apclassstone/bloc/queue/queue_bloc.dart';
import 'package:apclassstone/data/repositories/punch_repository.dart';

import '../../bloc/attendance/attendance_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import 'connectivity_service.dart';
import 'sync_service.dart';


import '../../bloc/bloc.dart';
export 'package:apclassstone/api/network/offline_api_wrapper.dart';

/// Service Provider for managing BLoCs and Services
/// Provides singleton instances of all BLoCs and offline-first services
class AppBlocProvider {
  static late LoginBloc _authBloc;
  static late LogoutBloc _logoutBloc;
  static late RegistrationBloc _registrationBloc;
  static late QueueBloc _queueBloc;
  static late PunchInBloc _punchInBloc;
  static late PunchOutBloc _punchOutBloc;
  static late LocationPingBloc _locationPingBloc;
  static late ExecutiveTrackingBloc _executiveTrackingBloc;

  // Offline-first services
  static late ConnectivityService _connectivityService;
  static late CacheRepository _cacheRepository;
  static late QueueRepository _queue_repository;
  static late SyncService _syncService;
  static late OfflineApiWrapper _offlineApiWrapper;
  static late PunchRepository _punchRepository;

  /// Initialize all BLoCs and services
  static Future<void> initialize() async {
    // Initialize connectivity service
    _connectivityService = ConnectivityService.instance;
    await _connectivityService.initialize();

    // Initialize repositories
    _cacheRepository = CacheRepository();
    _queue_repository = QueueRepository();

    // Initialize offline API wrapper
    await OfflineApiWrapper.initialize(
      cacheRepository: _cacheRepository,
      queueRepository: _queue_repository,
      connectivityService: _connectivityService,
      dio: NetworkService.instance.dio,
    );
    _offlineApiWrapper = OfflineApiWrapper.instance;

    // Initialize sync service
    _syncService = await SyncService.initialize(
      queueRepository: _queue_repository,
      connectivityService: _connectivityService,
      networkService: NetworkService.instance,
    );

    // Initialize BLoCs
    _authBloc = LoginBloc();
    _registrationBloc = RegistrationBloc();
    _queueBloc = QueueBloc(
      queueRepository: _queue_repository,
      syncService: _syncService,
      offlineApiWrapper: _offlineApiWrapper,
    );

    // Initialize punch repository and attendance bloc
    _punchRepository = PunchRepository();
    _punchInBloc = PunchInBloc();
    _punchOutBloc = PunchOutBloc();

    // Initialize location ping bloc
    _locationPingBloc = LocationPingBloc();
    _executiveTrackingBloc = ExecutiveTrackingBloc();
  }

  /// ✅ ADD THIS
  static void forceLogout() {
    _authBloc.add(ForceLogoutRequested());
  }


  /// Get AuthBloc instance
  static LoginBloc get authBloc => _authBloc;
  static LogoutBloc get logoutBloc => _logoutBloc;

  /// Get RegistrationBloc instance
  static RegistrationBloc get registrationBloc => _registrationBloc;

  /// Get QueueBloc instance (for super admin)
  static QueueBloc get queueBloc => _queueBloc;

  /// Get AttendanceBloc instance
  static PunchInBloc get punchInBloc => _punchInBloc;
  static PunchOutBloc get punchOutBloc => _punchOutBloc;

  /// Get LocationPingBloc instance
  static LocationPingBloc get locationPingBloc => _locationPingBloc;
  static ExecutiveTrackingBloc get executiveTrackingBloc => _executiveTrackingBloc;

  // Service getters for direct access
  static ConnectivityService get connectivityService => _connectivityService;
  static CacheRepository get cacheRepository => _cacheRepository;
  static QueueRepository get queueRepository => _queue_repository;
  static SyncService get syncService => _syncService;
  static OfflineApiWrapper get offlineApiWrapper => _offlineApiWrapper;
  // static PunchRepository get punchRepository => _punchRepository;



  /// Dispose all BLoCs and services (call this when app closes)
  static void dispose() {
    _authBloc.close();
    _logoutBloc.close();

    _registrationBloc.close();
    _queueBloc.close();
    _punchInBloc.close();
    _punchOutBloc.close();
    _locationPingBloc.close();
    _executiveTrackingBloc.close();
    _connectivityService.dispose();
    _syncService.dispose();
  }
}
