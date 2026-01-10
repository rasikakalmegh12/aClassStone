import 'package:apclassstone/bloc/auth/auth_bloc.dart';
import 'package:apclassstone/api/network/network_service.dart';
import 'package:apclassstone/api/network/offline_api_wrapper.dart';
import 'package:apclassstone/bloc/client/get_client/get_client_bloc.dart';
import 'package:apclassstone/bloc/client/post_client/post_client_bloc.dart';
import 'package:apclassstone/bloc/lead/lead_bloc.dart';
import 'package:apclassstone/data/local/cache_repository.dart';
import 'package:apclassstone/data/local/queue_repository.dart';
import 'package:apclassstone/bloc/queue/queue_bloc.dart';
import 'package:apclassstone/data/repositories/punch_repository.dart';

import '../../bloc/attendance/attendance_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/catalogue/get_catalogue_methods/get_catalogue_bloc.dart';
import '../../bloc/catalogue/post_catalogue_methods/post_catalogue_bloc.dart';
import '../../bloc/mom/mom_bloc.dart';
import '../../bloc/work_plan/work_plan_bloc.dart';
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

  // Catalogue BLoCs
  static late GetProductTypeBloc _getProductTypeBloc;
  static late GetUtilitiesBloc _getUtilitiesBloc;
  static late GetColorsBloc _getColorsBloc;
  static late GetFinishesBloc _getFinishesBloc;
  static late GetTexturesBloc _getTexturesBloc;
  static late GetNaturalColorsBloc _getNaturalColorsBloc;
  static late GetOriginsBloc _getOriginsBloc;
  static late GetStateCountriesBloc _getStateCountriesBloc;
  static late GetProcessingNatureBloc _getProcessingNatureBloc;
  static late GetNaturalMaterialBloc _getNaturalMaterialBloc;
  static late GetHandicraftsBloc _getHandicraftsBloc;
  static late GetPriceRangeBloc _getPriceRangeBloc;
  static late GetMinesOptionBloc _getMinesOptionBloc;
  static late PostSearchBloc _postSearchBloc;
  static late AttendanceTrackingMonthlyBloc _attendanceTrackingMonthlyBloc;
  static late GetClientDetailsBloc _getClientDetailsBloc;
  static late GetClientListBloc _getClientListBloc;
  static late ActiveSessionBloc _activeSessionBloc;
  static late PostClientAddBloc _postClientAddBloc;
  static late PostClientAddLocationBloc _postClientAddLocationBloc;
  static late PostClientAddContactBloc _postClientAddContactBloc;
  static late PostMomEntryBloc _postMomEntryBloc;
  static late GetMomListBloc _getMomListBloc;
  static late GetMomDetailsBloc _getMomDetailsBloc;
  static late GetWorkPlanListBloc _getWorkPlanListBloc;
  static late GetWorkPlanDetailsBloc _getWorkPlanDetailsBloc;
  static late PostWorkPlanBloc _postWorkPlanBloc;

  // Lead BLoCs
  static late PostNewLeadBloc _postNewLeadBloc;
  static late GetLeadListBloc _getLeadListBloc;
  static late GetLeadDetailsBloc _getLeadDetailsBloc;
  static late GetAssignableUsersBloc _getAssignableUsersBloc;

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

    // Initialize punch repository and executive_history bloc
    _punchRepository = PunchRepository();
    _punchInBloc = PunchInBloc();
    _punchOutBloc = PunchOutBloc();
    _activeSessionBloc=ActiveSessionBloc();
    // Initialize location ping bloc
    _locationPingBloc = LocationPingBloc();
    _executiveTrackingBloc = ExecutiveTrackingBloc();
    _postClientAddBloc=PostClientAddBloc();
    // Initialize catalogue BLoCs
    _getProductTypeBloc = GetProductTypeBloc();
    _getUtilitiesBloc = GetUtilitiesBloc();
    _getColorsBloc = GetColorsBloc();
    _getFinishesBloc = GetFinishesBloc();
    _getTexturesBloc = GetTexturesBloc();
    _getNaturalColorsBloc = GetNaturalColorsBloc();
    _getOriginsBloc = GetOriginsBloc();
    _getStateCountriesBloc = GetStateCountriesBloc();
    _getProcessingNatureBloc = GetProcessingNatureBloc();
    _getNaturalMaterialBloc = GetNaturalMaterialBloc();
    _getHandicraftsBloc = GetHandicraftsBloc();
    _getPriceRangeBloc = GetPriceRangeBloc();
    _getMinesOptionBloc = GetMinesOptionBloc();
    _postSearchBloc = PostSearchBloc();
    _attendanceTrackingMonthlyBloc = AttendanceTrackingMonthlyBloc();
    _postClientAddLocationBloc=PostClientAddLocationBloc();
    _postClientAddContactBloc=PostClientAddContactBloc();
    _postMomEntryBloc=PostMomEntryBloc();
    _getClientDetailsBloc = GetClientDetailsBloc();
    _getClientListBloc=GetClientListBloc();
    _getMomListBloc=GetMomListBloc();
    _getMomDetailsBloc=GetMomDetailsBloc();
    _getWorkPlanListBloc = GetWorkPlanListBloc();
    _getWorkPlanDetailsBloc = GetWorkPlanDetailsBloc();
    _postWorkPlanBloc = PostWorkPlanBloc();

    // Initialize Lead BLoCs
    _postNewLeadBloc = PostNewLeadBloc();
    _getLeadListBloc = GetLeadListBloc();
    _getLeadDetailsBloc = GetLeadDetailsBloc();
    _getAssignableUsersBloc = GetAssignableUsersBloc();


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
  static ActiveSessionBloc get activeSessionBloc => _activeSessionBloc;

  /// Get LocationPingBloc instance
  static LocationPingBloc get locationPingBloc => _locationPingBloc;
  static ExecutiveTrackingBloc get executiveTrackingBloc => _executiveTrackingBloc;

  // Catalogue BLoC getters
  static GetProductTypeBloc get getProductTypeBloc => _getProductTypeBloc;
  static GetUtilitiesBloc get getUtilitiesBloc => _getUtilitiesBloc;
  static GetColorsBloc get getColorsBloc => _getColorsBloc;
  static GetFinishesBloc get getFinishesBloc => _getFinishesBloc;
  static GetTexturesBloc get getTexturesBloc => _getTexturesBloc;
  static GetNaturalColorsBloc get getNaturalColorsBloc => _getNaturalColorsBloc;
  static GetOriginsBloc get getOriginsBloc => _getOriginsBloc;
  static GetStateCountriesBloc get getStateCountriesBloc => _getStateCountriesBloc;
  static GetProcessingNatureBloc get getProcessingNatureBloc => _getProcessingNatureBloc;
  static GetNaturalMaterialBloc get getNaturalMaterialBloc => _getNaturalMaterialBloc;
  static GetHandicraftsBloc get getHandicraftsBloc => _getHandicraftsBloc;
  static GetPriceRangeBloc get getPriceRangeBloc => _getPriceRangeBloc;
  static GetMinesOptionBloc get getMinesOptionBloc => _getMinesOptionBloc;
  static PostSearchBloc get postSearchBloc => _postSearchBloc;
  static AttendanceTrackingMonthlyBloc get attendanceTrackingMonthlyBloc => _attendanceTrackingMonthlyBloc;
  static GetClientDetailsBloc get getClientDetailsBloc => _getClientDetailsBloc;
  static GetClientListBloc get getClientListBloc => _getClientListBloc;
  static PostClientAddBloc get postClientAddBloc => _postClientAddBloc;
  static PostClientAddLocationBloc get postClientAddLocationBloc => _postClientAddLocationBloc;
  static PostClientAddContactBloc get postClientAddContactBloc => _postClientAddContactBloc;
  static PostMomEntryBloc get postMomEntryBloc => _postMomEntryBloc;
  static GetMomListBloc get getMomListBloc => _getMomListBloc;
  static GetMomDetailsBloc get getMomDetailsBloc => _getMomDetailsBloc;
  static GetWorkPlanListBloc get getWorkPlanListBloc => _getWorkPlanListBloc;
  static GetWorkPlanDetailsBloc get getWorkPlanDetailsBloc => _getWorkPlanDetailsBloc;
  static PostWorkPlanBloc get postWorkPlanBloc => _postWorkPlanBloc;

  // Lead BLoC getters
  static PostNewLeadBloc get postNewLeadBloc => _postNewLeadBloc;
  static GetLeadListBloc get getLeadListBloc => _getLeadListBloc;
  static GetLeadDetailsBloc get getLeadDetailsBloc => _getLeadDetailsBloc;
  static GetAssignableUsersBloc get getAssignableUsersBloc => _getAssignableUsersBloc;


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
    _activeSessionBloc.close();
    _postClientAddBloc.close();
    _postClientAddLocationBloc.close();
    _postClientAddContactBloc.close();
    _postMomEntryBloc.close();
    _getMomListBloc.close();
    _getMomDetailsBloc.close();
    _getClientDetailsBloc.close();


    // Dispose catalogue BLoCs
    _getProductTypeBloc.close();
    _getUtilitiesBloc.close();
    _getColorsBloc.close();
    _getFinishesBloc.close();
    _getTexturesBloc.close();
    _getNaturalColorsBloc.close();
    _getOriginsBloc.close();
    _getStateCountriesBloc.close();
    _getProcessingNatureBloc.close();
    _getNaturalMaterialBloc.close();
    _getHandicraftsBloc.close();
    _getPriceRangeBloc.close();
    _getMinesOptionBloc.close();

    _getClientListBloc.close();
    _getClientListBloc.close();
    _attendanceTrackingMonthlyBloc.close();

    // Dispose Lead BLoCs
    _postNewLeadBloc.close();
    _getLeadListBloc.close();
    _getLeadDetailsBloc.close();
    _getAssignableUsersBloc.close();

    _connectivityService.dispose();
    _syncService.dispose();
  }

}
