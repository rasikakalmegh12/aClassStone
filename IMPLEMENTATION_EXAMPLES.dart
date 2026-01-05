/// EXAMPLE: How to integrate offline-first into your existing BLoCs and repositories
/// This file demonstrates the implementation patterns for different scenarios

// ============================================================================
// EXAMPLE 1: Registration BLoC Integration
// ============================================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apclassstone/api/network/offline_api_wrapper.dart';
import 'package:apclassstone/core/services/repository_provider.dart';

/*
class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  final OfflineApiWrapper _offlineApi;

  RegistrationBloc({OfflineApiWrapper? offlineApi})
      : _offlineApi = offlineApi ?? AppBlocProvider.offlineApiWrapper,
        super(RegistrationInitial()) {
    on<RegisterUserEvent>(_onRegisterUser);
  }

  Future<void> _onRegisterUser(
    RegisterUserEvent event,
    Emitter<RegistrationState> emit,
  ) async {
    try {
      emit(RegistrationLoading());

      // Use offline-aware API call
      final response = await _offlineApi.post(
        '/api/auth/register',
        data: {
          'firstName': event.firstName,
          'lastName': event.lastName,
          'email': event.email,
          'phone': event.phone,
          'role': event.role,
        },
        shouldQueue: true,  // Queue if offline
        userId: event.userId,
        metadata: {'registrationType': 'new_user'},
      );

      // Check if request was queued (202) or succeeded (200)
      if (response.statusCode == 202) {
        // Request queued - will sync when online
        emit(RegistrationQueued(
          message: 'Registration submitted. Will process when online.',
        ));
      } else if (response.statusCode == 200 || response.statusCode == 201) {
        // Immediate success
        emit(RegistrationSuccess(
          message: 'Registration successful',
          data: response.data,
        ));
      } else {
        emit(RegistrationError(
          message: 'Registration failed: ${response.statusMessage}',
        ));
      }
    } catch (e) {
      emit(RegistrationError(message: e.toString()));
    }
  }
}
*/

// ============================================================================
// EXAMPLE 2: Dashboard/List Screen - Using Cache
// ============================================================================

/*
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final OfflineApiWrapper _offlineApi;

  DashboardBloc({OfflineApiWrapper? offlineApi})
      : _offlineApi = offlineApi ?? AppBlocProvider.offlineApiWrapper,
        super(DashboardInitial()) {
    on<FetchDashboardEvent>(_onFetchDashboard);
  }

  Future<void> _onFetchDashboard(
    FetchDashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      emit(DashboardLoading());

      // GET requests are cached - works offline
      final response = await _offlineApi.get(
        '/api/dashboard/data',
        useCache: true,  // Use cached data if offline
        cacheDuration: Duration(minutes: 15),  // Cache for 15 minutes
      );

      if (response.statusCode == 200) {
        final data = response.data;
        emit(DashboardLoaded(data: data));
      } else {
        emit(DashboardError(message: 'Failed to load dashboard'));
      }
    } catch (e) {
      // If offline and no cache, this will throw
      emit(DashboardError(message: 'No connectivity and no cached data'));
    }
  }
}
*/

// ============================================================================
// EXAMPLE 3: Attendance/Punch - With Queue & Custom Sync
// ============================================================================

/*
class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final OfflineApiWrapper _offlineApi;
  final SyncService _syncService;

  AttendanceBloc({
    OfflineApiWrapper? offlineApi,
    SyncService? syncService,
  })  : _offlineApi = offlineApi ?? AppBlocProvider.offlineApiWrapper,
        _syncService = syncService ?? AppBlocProvider.syncService,
        super(AttendanceInitial()) {
    on<PunchInEvent>(_onPunchIn);
    on<PunchOutEvent>(_onPunchOut);
    _registerCustomHandlers();
  }

  void _registerCustomHandlers() {
    // Register custom sync handler for punch endpoints
    _syncService.registerCustomHandler(
      '/api/executive_history/punch-in',
      (request) => _customPunchSync(request, 'punch-in'),
    );
    _syncService.registerCustomHandler(
      '/api/executive_history/punch-out',
      (request) => _customPunchSync(request, 'punch-out'),
    );
  }

  Future<void> _onPunchIn(
    PunchInEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    try {
      emit(AttendanceLoading());

      final response = await _offlineApi.post(
        '/api/executive_history/punch-in',
        data: {
          'timestamp': DateTime.now().toIso8601String(),
          'location': event.location,
        },
        shouldQueue: true,  // Queue if offline
        userId: event.userId,
      );

      if (response.statusCode == 202) {
        emit(PunchQueued(message: 'Punch-in queued for sync'));
      } else if (response.statusCode == 200) {
        emit(PunchSuccess(message: 'Punch-in recorded'));
      }
    } catch (e) {
      emit(AttendanceError(message: e.toString()));
    }
  }

  Future<void> _onPunchOut(
    PunchOutEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    try {
      emit(AttendanceLoading());

      final response = await _offlineApi.post(
        '/api/executive_history/punch-out',
        data: {
          'timestamp': DateTime.now().toIso8601String(),
        },
        shouldQueue: true,
        userId: event.userId,
      );

      if (response.statusCode == 202) {
        emit(PunchQueued(message: 'Punch-out queued for sync'));
      } else if (response.statusCode == 200) {
        emit(PunchSuccess(message: 'Punch-out recorded'));
      }
    } catch (e) {
      emit(AttendanceError(message: e.toString()));
    }
  }

  // Custom sync logic for punch operations
  Future<bool> _customPunchSync(QueuedRequest request, String type) async {
    try {
      final json = jsonDecode(request.requestBody ?? '{}');

      // Add additional validation or processing
      json['punchedBy'] = request.userId;

      // Make the actual API call
      final dio = AppBlocProvider.offlineApiWrapper._dio;  // Access via BLoC
      final response = await dio.post(
        request.endpoint,
        data: json,
        options: Options(headers: request.headers),
      );

      return response.statusCode != null && response.statusCode! < 400;
    } catch (e) {
      print('Custom sync error: $e');
      return false;
    }
  }
}
*/

// ============================================================================
// EXAMPLE 4: Super Admin - Queue Status Panel
// ============================================================================

/*
class QueueStatusPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QueueBloc, QueueState>(
      builder: (context, state) {
        if (state is QueueStatusLoaded) {
          return Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'API Queue Status (Super Admin)',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 16),
                  _buildStatRow('Total Queued', state.totalQueued.toString()),
                  _buildStatRow('Pending', state.pending.toString(), Colors.orange),
                  _buildStatRow('Failed', state.failed.toString(), Colors.red),
                  _buildStatRow('Successful', state.successful.toString(), Colors.green),
                  SizedBox(height: 16),
                  Text(
                    'Last Checked: ${state.lastChecked.toString()}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<QueueBloc>().add(FetchQueueStatusEvent());
                        },
                        icon: Icon(Icons.refresh),
                        label: Text('Refresh'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<QueueBloc>().add(ManualSyncEvent());
                        },
                        icon: Icon(Icons.sync),
                        label: Text('Manual Sync'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<QueueBloc>().add(
                            FetchAllQueuedRequestsEvent(),
                          );
                        },
                        icon: Icon(Icons.list),
                        label: Text('Details'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
        return CircularProgressIndicator();
      },
    );
  }

  Widget _buildStatRow(String label, String value, [Color? color]) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Chip(
            label: Text(value),
            backgroundColor: color ?? Colors.blue,
            labelStyle: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
*/

// ============================================================================
// EXAMPLE 5: Repository Pattern - Old way vs New Way
// ============================================================================

/*
// OLD WAY - Direct API calls
class UserRepository {
  final Dio _dio;

  Future<List<User>> getUsers() async {
    try {
      final response = await _dio.get('/api/users');
      return (response.data as List)
          .map((u) => User.fromJson(u))
          .toList();
    } on DioException {
      throw Exception('Failed to fetch users');
    }
  }
}

// NEW WAY - Using OfflineApiWrapper
class UserRepository {
  final OfflineApiWrapper _offlineApi;

  UserRepository({OfflineApiWrapper? offlineApi})
      : _offlineApi = offlineApi ?? AppBlocProvider.offlineApiWrapper;

  Future<List<User>> getUsers() async {
    try {
      // Will use cache if offline, queue on error
      final response = await _offlineApi.get(
        '/api/users',
        useCache: true,
        cacheDuration: Duration(hours: 1),
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((u) => User.fromJson(u))
            .toList();
      }
      throw Exception('Failed to fetch users');
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  Future<void> createUser(User user) async {
    try {
      // Will queue if offline
      final response = await _offlineApi.post(
        '/api/users',
        data: user.toJson(),
        shouldQueue: true,
        userId: user.id,
      );

      if (response.statusCode == 202 || response.statusCode == 201) {
        return;
      }
      throw Exception('Failed to create user');
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }
}
*/

// ============================================================================
// EXAMPLE 6: Connectivity-Aware UI
// ============================================================================

/*
class ConnectivityIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final connectivityService = AppBlocProvider.connectivityService;

    return StreamBuilder<ConnectivityStatus>(
      stream: connectivityService.statusStream,
      initialData: connectivityService.currentStatus,
      builder: (context, snapshot) {
        final status = snapshot.data ?? ConnectivityStatus.unknown;

        return Padding(
          padding: EdgeInsets.all(8),
          child: Chip(
            label: Text(_getStatusText(status)),
            backgroundColor: _getStatusColor(status),
            labelStyle: TextStyle(color: Colors.white),
            avatar: Icon(
              _getStatusIcon(status),
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  String _getStatusText(ConnectivityStatus status) {
    switch (status) {
      case ConnectivityStatus.online:
        return '🟢 Online';
      case ConnectivityStatus.offline:
        return '🔴 Offline';
      case ConnectivityStatus.unknown:
        return '🟡 Unknown';
    }
  }

  Color _getStatusColor(ConnectivityStatus status) {
    switch (status) {
      case ConnectivityStatus.online:
        return Colors.green;
      case ConnectivityStatus.offline:
        return Colors.red;
      case ConnectivityStatus.unknown:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(ConnectivityStatus status) {
    switch (status) {
      case ConnectivityStatus.online:
        return Icons.cloud_done;
      case ConnectivityStatus.offline:
        return Icons.cloud_off;
      case ConnectivityStatus.unknown:
        return Icons.cloud_queue;
    }
  }
}
*/

// ============================================================================
// EXAMPLE 7: Approval/Reject with Offline Support
// ============================================================================

/*
class ApprovalBloc extends Bloc<ApprovalEvent, ApprovalState> {
  final OfflineApiWrapper _offlineApi;

  ApprovalBloc({OfflineApiWrapper? offlineApi})
      : _offlineApi = offlineApi ?? AppBlocProvider.offlineApiWrapper,
        super(ApprovalInitial()) {
    on<ApproveRegistrationEvent>(_onApprove);
    on<RejectRegistrationEvent>(_onReject);
  }

  Future<void> _onApprove(
    ApproveRegistrationEvent event,
    Emitter<ApprovalState> emit,
  ) async {
    try {
      emit(ApprovalLoading());

      final response = await _offlineApi.put(
        '/api/registrations/${event.registrationId}/approve',
        data: {'remarks': event.remarks},
        shouldQueue: true,
        userId: event.approverId,
        metadata: {'action': 'approve'},
      );

      if (response.statusCode == 202) {
        emit(ApprovalQueued(
          message: 'Approval queued. Will process when online.',
        ));
      } else if (response.statusCode == 200) {
        emit(ApprovalSuccess(message: 'Registration approved'));
      } else {
        emit(ApprovalError(message: 'Failed to approve registration'));
      }
    } catch (e) {
      emit(ApprovalError(message: e.toString()));
    }
  }

  Future<void> _onReject(
    RejectRegistrationEvent event,
    Emitter<ApprovalState> emit,
  ) async {
    try {
      emit(ApprovalLoading());

      final response = await _offlineApi.put(
        '/api/registrations/${event.registrationId}/reject',
        data: {'reason': event.reason},
        shouldQueue: true,
        userId: event.rejecterId,
        metadata: {'action': 'reject'},
      );

      if (response.statusCode == 202) {
        emit(ApprovalQueued(
          message: 'Rejection queued. Will process when online.',
        ));
      } else if (response.statusCode == 200) {
        emit(ApprovalSuccess(message: 'Registration rejected'));
      } else {
        emit(ApprovalError(message: 'Failed to reject registration'));
      }
    } catch (e) {
      emit(ApprovalError(message: e.toString()));
    }
  }
}
*/

// ============================================================================
// NOTE: This file contains commented examples
// Uncomment and adapt these examples to your actual BLoCs and models
// ============================================================================

