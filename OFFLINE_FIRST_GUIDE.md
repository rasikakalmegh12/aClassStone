# Offline-First Architecture Implementation Guide

## Overview

This document describes the complete offline-first architecture with local database caching, API request queuing, and automatic sync when connectivity resumes.

## Architecture Components

### 1. **Connectivity Monitoring** (`lib/core/services/connectivity_service.dart`)
- Monitors network connectivity status in real-time
- Emits `ConnectivityStatus` stream with three states: `online`, `offline`, `unknown`
- Provides synchronous access to current status via `isOnline` and `isOffline` getters
- Automatically notifies all listeners when connectivity changes

### 2. **Local Database** (`lib/data/local/`)
- **DatabaseHelper**: SQLite database initialization and management
- **Tables**:
  - `cached_responses`: Stores API responses for offline access
  - `queued_requests`: Stores failed requests for retry/sync

#### Database Schema

**cached_responses**
```
- id (Primary Key)
- endpoint
- responseData (JSON)
- statusCode
- cachedAt (DateTime)
- expiresAt (DateTime, nullable)
- requestMethod (GET/POST/PUT/DELETE)
```

**queued_requests**
```
- id (Primary Key)
- endpoint
- method
- requestBody (JSON)
- headers (JSON)
- status (pending/inProgress/success/failed/retrying)
- createdAt (DateTime)
- attemptedAt (DateTime, nullable)
- retryCount (Integer)
- maxRetries (Integer)
- errorMessage (String, nullable)
- userId (String, nullable)
- metadata (JSON, nullable)
```

### 3. **Repository Layer** (`lib/data/local/`)
- **CacheRepository**: Manages cached API responses
- **QueueRepository**: Manages queued API requests

### 4. **Offline API Wrapper** (`lib/api/network/offline_api_wrapper.dart`)
- Intercepts all API calls
- Routes to cache if offline or cached data available
- Queues failed requests automatically
- Provides `get()`, `post()`, `put()`, `delete()` methods

**Features**:
- Automatic caching of successful responses
- Fallback to cache on network failure
- Request queuing with retry logic
- Excludes login endpoints from queuing
- Queue status visibility

### 5. **Sync Service** (`lib/core/services/sync_service.dart`)
- Manages automatic sync of queued requests when online
- Listens to connectivity changes and triggers sync
- Periodic retry timer (5-minute intervals)
- Custom sync handlers for special endpoints
- Emits sync events for UI feedback

**Sync Flow**:
1. Connectivity restored → Auto-sync triggered
2. Fetches pending requests from queue
3. Retries failed requests with exponential backoff
4. Updates request status (success/failed/retrying)
5. Emits sync events for monitoring

### 6. **Queue Management BLoC** (`lib/bloc/queue/`)
- Visible to super admin only
- Displays queue statistics and status
- Provides manual sync trigger
- Allows request retry and removal
- Streams sync events in real-time

## Implementation Steps

### Step 1: Update pubspec.yaml
✅ Already done. Dependencies added:
- `sqflite: ^2.3.0` - SQLite database
- `hive: ^2.2.3` - Alternative caching (optional)
- `hive_flutter: ^1.1.0` - Flutter integration
- `connectivity_plus: ^5.0.0` - Network monitoring
- `uuid: ^4.0.0` - Request ID generation

### Step 2: Initialize Services
Update in `lib/core/services/repository_provider.dart`:
```dart
static Future<void> initialize() async {
  // Connectivity
  _connectivityService = ConnectivityService.instance;
  await _connectivityService.initialize();
  
  // Database
  _cacheRepository = CacheRepository();
  _queueRepository = QueueRepository();
  
  // Offline Wrapper
  await OfflineApiWrapper.initialize(...);
  
  // Sync Service
  _syncService = await SyncService.initialize(...);
  
  // BLoCs
  _authBloc = LoginBloc();
  _registrationBloc = RegistrationBloc();
  _queueBloc = QueueBloc(...);
}
```

### Step 3: Update main.dart
```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SessionManager.init();
  await AppBlocProvider.initialize();  // ← Now async
  runApp(const MyApp());
}
```

### Step 4: Replace API Calls in Your Code

**Before (Direct API calls):**
```dart
final response = await dio.get('/api/users');
```

**After (Using OfflineApiWrapper):**
```dart
final wrapper = AppBlocProvider.offlineApiWrapper;
final response = await wrapper.get(
  '/api/users',
  useCache: true,
  cacheDuration: Duration(minutes: 30),
);
```

### Step 5: Implement Offline-First in BLoCs

**Registration BLoC Example:**
```dart
class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  final OfflineApiWrapper _offlineApi = 
    AppBlocProvider.offlineApiWrapper;

  RegistrationBloc() : super(RegistrationInitial()) {
    on<RegisterUserEvent>(_onRegisterUser);
  }

  Future<void> _onRegisterUser(
    RegisterUserEvent event,
    Emitter<RegistrationState> emit,
  ) async {
    try {
      emit(RegistrationLoading());
      
      final response = await _offlineApi.post(
        '/api/auth/register',
        data: event.registrationData,
        shouldQueue: true,  // Queue if offline
        userId: event.userId,
      );

      if (response.statusCode == 202) {
        // Request queued
        emit(RegistrationQueued(
          message: 'Registration queued. Will sync when online.',
        ));
      } else if (response.statusCode! < 400) {
        emit(RegistrationSuccess());
      } else {
        emit(RegistrationError(message: 'Registration failed'));
      }
    } catch (e) {
      emit(RegistrationError(message: e.toString()));
    }
  }
}
```

### Step 6: Register Custom Sync Handlers (Optional)

For special endpoints with custom sync logic:

```dart
// In AppBlocProvider or after initialization
AppBlocProvider.syncService.registerCustomHandler(
  '/api/registrations',
  (request) async {
    // Custom logic to sync registration
    // Return true if successful, false otherwise
    return await _handleRegistrationSync(request);
  },
);
```

### Step 7: Super Admin Queue Status UI

**Example Screen:**
```dart
class QueueStatusScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QueueBloc, QueueState>(
      builder: (context, state) {
        if (state is QueueStatusLoaded) {
          return Column(
            children: [
              ListTile(
                title: Text('Total Queued: ${state.totalQueued}'),
                subtitle: Text('Pending: ${state.pending}'),
              ),
              ListTile(
                title: Text('Failed: ${state.failed}'),
                subtitle: Text('Successful: ${state.successful}'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<QueueBloc>().add(ManualSyncEvent());
                },
                child: Text('Manual Sync'),
              ),
            ],
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
```

## Usage Examples

### GET Request with Caching
```dart
final response = await AppBlocProvider.offlineApiWrapper.get(
  '/api/dashboard',
  useCache: true,
  cacheDuration: Duration(hours: 1),
);
```

### POST Request with Queuing
```dart
final response = await AppBlocProvider.offlineApiWrapper.post(
  '/api/executive_history/punch-in',
  data: {'timestamp': DateTime.now()},
  shouldQueue: true,
  userId: userId,
);
```

### Check Queue Status
```dart
final status = await AppBlocProvider.offlineApiWrapper.getQueueStatus();
print('Queued: ${status.totalQueued}');
print('Pending: ${status.pending}');
```

### Listen to Sync Events
```dart
AppBlocProvider.syncService.syncEventStream.listen((event) {
  if (event.type == SyncEventType.completed) {
    print('All synced!');
  }
});
```

## Login Handling

⚠️ **Important**: Login requests are EXCLUDED from queuing:
- Login must always be real-time
- Cannot be queued offline
- Will throw exception if attempted offline
- Excluded endpoints: `auth/login`, `login/sendotp`, `login/verifyotp`, `loginWithPassword`

```dart
// This will throw exception if offline
try {
  await offlineApi.post('/api/auth/loginWithPassword', data: credentials);
} catch (e) {
  // Handle offline error - show "No connectivity" message
}
```

## Retry Logic

- **Default max retries**: 5
- **Trigger**: Automatic on next connectivity resume
- **Strategy**: Fails are marked for retry, synced when online again
- **Manual retry**: Super admin can manually retry via QueueBloc

## Cache Management

### Cache Expiry
```dart
// Cache for 30 minutes (default)
await offlineApi.get('/api/data', cacheDuration: Duration(minutes: 30));

// Cache until manually cleared
await offlineApi.get('/api/data', cacheDuration: Duration(days: 365));
```

### Clear Cache
```dart
// Clear specific endpoint
await AppBlocProvider.cacheRepository
  .deleteCachedResponse('/api/users');

// Clear all cache
await AppBlocProvider.cacheRepository.clearAllCache();

// Clear expired cache
await AppBlocProvider.cacheRepository.deleteExpiredCache();
```

## Monitoring & Debugging

### Check Connectivity Status
```dart
final status = AppBlocProvider.connectivityService.currentStatus;
if (status == ConnectivityStatus.online) {
  print('Online');
} else if (status == ConnectivityStatus.offline) {
  print('Offline');
}
```

### View Queue Statistics
```dart
final stats = await AppBlocProvider.queueRepository.getQueueStatistics();
print('Total: ${stats.totalCount}');
print('Pending: ${stats.pendingCount}');
print('Failed: ${stats.failedCount}');
```

### Fetch Queue Details (Super Admin)
```dart
final requests = await AppBlocProvider.queueRepository.getAllQueuedRequests();
for (final req in requests) {
  print('${req.id}: ${req.endpoint} - ${req.status}');
}
```

## Best Practices

1. **Always use OfflineApiWrapper** instead of direct Dio calls
2. **Enable caching** for read-heavy endpoints (GET)
3. **Enable queuing** for write operations (POST/PUT/DELETE)
4. **Handle status code 202** as "queued" response
5. **Check connectivity** before critical operations
6. **Register custom handlers** for complex sync logic
7. **Monitor queue** regularly in super admin panel
8. **Test offline** scenarios during development
9. **Set appropriate cache durations** based on data freshness needs
10. **Never queue login** requests under any circumstance

## API Response Codes

When offline:
- **GET**: Returns cached response (200) or throws exception
- **POST/PUT/DELETE**: Returns 202 Accepted (queued) or throws exception

When online but queued:
- Returns 202 Accepted
- Request queued with unique ID
- Synced automatically when online

## Troubleshooting

### Queue Not Syncing
1. Check connectivity status: `AppBlocProvider.connectivityService.isOnline`
2. Check sync service: `AppBlocProvider.syncService.isSyncing`
3. Manual trigger: `context.read<QueueBloc>().add(ManualSyncEvent())`

### Cached Data Stale
1. Clear specific cache: `cacheRepository.deleteCachedResponse(endpoint)`
2. Reduce cache duration
3. Manually refresh: Make new request

### Requests Not Queued
1. Check if endpoint is excluded from queue
2. Verify `shouldQueue: true` parameter
3. Check queue repository: `queueRepository.getPendingRequests()`

## Next Steps

1. ✅ Update all existing API calls to use OfflineApiWrapper
2. ✅ Test offline scenarios
3. ✅ Create super admin queue management UI
4. ✅ Add queue status badge to app bar
5. ✅ Implement background sync (optional)
6. ✅ Add sync progress indicators
7. ✅ Create user-friendly "syncing" UI feedback
8. ✅ Monitor production queue metrics

## File Structure Summary

```
lib/
├── core/
│   └── services/
│       ├── connectivity_service.dart      [NEW] Network monitoring
│       ├── sync_service.dart              [NEW] Queue sync engine
│       └── repository_provider.dart       [UPDATED] Service initialization
├── api/
│   └── network/
│       ├── offline_api_wrapper.dart       [NEW] Offline API handling
│       └── network_service.dart           [EXISTING]
├── data/
│   ├── local/
│   │   ├── database_helper.dart           [NEW] SQLite setup
│   │   ├── cache_repository.dart          [NEW] Cache management
│   │   └── queue_repository.dart          [NEW] Queue management
│   └── models/
│       ├── cached_response.dart           [NEW] Cache model
│       └── queued_request.dart            [NEW] Queue model
└── bloc/
    ├── queue/                             [NEW] Queue management BLoC
    │   ├── queue_bloc.dart
    │   ├── queue_event.dart
    │   ├── queue_state.dart
    │   └── queue.dart
    └── [other blocs]
```

---

**Version**: 1.0
**Last Updated**: December 21, 2025
**Maintainer**: Development Team

