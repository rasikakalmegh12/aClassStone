# Offline-First Architecture - Quick Reference

## 🚀 Quick Start (3 Steps)

### Step 1: Import the wrapper
```dart
import 'package:apclassstone/api/network/offline_api_wrapper.dart';
import 'package:apclassstone/core/services/repository_provider.dart';
```

### Step 2: Get the instance
```dart
final offlineApi = AppBlocProvider.offlineApiWrapper;
```

### Step 3: Use instead of Dio
```dart
// GET (with cache)
final response = await offlineApi.get('/api/endpoint');

// POST (with queue)
final response = await offlineApi.post('/api/endpoint', data: data);
```

---

## 📚 API Reference

### OfflineApiWrapper Methods

#### GET Request
```dart
final response = await offlineApi.get(
  '/api/endpoint',
  queryParameters: {'param': 'value'},
  useCache: true,                              // [optional] Use cache
  cacheDuration: Duration(minutes: 30),        // [optional] Cache time
);
```

#### POST Request
```dart
final response = await offlineApi.post(
  '/api/endpoint',
  data: {'key': 'value'},
  shouldQueue: true,                           // [optional] Queue if offline
  userId: 'user123',                           // [optional] User tracking
  metadata: {'action': 'create'},              // [optional] Extra info
);
```

#### PUT Request
```dart
final response = await offlineApi.put(
  '/api/endpoint',
  data: updateData,
  shouldQueue: true,
);
```

#### DELETE Request
```dart
final response = await offlineApi.delete(
  '/api/endpoint',
  shouldQueue: true,
);
```

### Response Status Codes

| Code | Meaning | Action |
|------|---------|--------|
| 200-299 | Success | Data returned successfully |
| 202 | Accepted/Queued | Request queued, will sync later |
| 400-499 | Client Error | Invalid request, check data |
| 500-599 | Server Error | Server issue, retry later |

---

## 🔌 Connectivity Check

```dart
// Check current status
final isOnline = AppBlocProvider.connectivityService.isOnline;
final isOffline = AppBlocProvider.connectivityService.isOffline;

// Listen to changes
AppBlocProvider.connectivityService.statusStream.listen((status) {
  if (status == ConnectivityStatus.online) {
    print('Online!');
  }
});
```

---

## 💾 Cache Management

### Save to cache (automatic for GET)
```dart
final response = await offlineApi.get(
  '/api/data',
  useCache: true,
  cacheDuration: Duration(hours: 1),  // Cache for 1 hour
);
```

### Get cached data
```dart
final cached = await AppBlocProvider.cacheRepository
  .getCachedResponse('/api/data');

if (cached != null && cached.isValid()) {
  print('Cache hit: ${cached.responseData}');
}
```

### Clear cache
```dart
// Clear specific endpoint
await AppBlocProvider.cacheRepository.deleteCachedResponse('/api/data');

// Clear all cache
await AppBlocProvider.cacheRepository.clearAllCache();

// Clear expired cache
await AppBlocProvider.cacheRepository.deleteExpiredCache();
```

---

## 📤 Queue Management

### View pending requests
```dart
final pending = await AppBlocProvider.queueRepository.getPendingRequests();
pending.forEach((req) {
  print('${req.endpoint} - ${req.status}');
});
```

### Get queue statistics
```dart
final stats = await AppBlocProvider.queueRepository.getQueueStatistics();
print('Total: ${stats.totalCount}');
print('Pending: ${stats.pendingCount}');
print('Failed: ${stats.failedCount}');
print('Success: ${stats.successCount}');
```

### Manual sync
```dart
await AppBlocProvider.syncService.startSync();
```

### Listen to sync events
```dart
AppBlocProvider.syncService.syncEventStream.listen((event) {
  if (event.type == SyncEventType.completed) {
    print('Sync complete!');
  }
});
```

### Get queue status (for super admin)
```dart
final status = await AppBlocProvider.offlineApiWrapper.getQueueStatus();
print('Queued: ${status.totalQueued}');
print('Pending: ${status.pending}');
print('Failed: ${status.failed}');
```

---

## 🎯 BLoC Integration Pattern

```dart
class MyBloc extends Bloc<MyEvent, MyState> {
  final OfflineApiWrapper _offlineApi;

  MyBloc({OfflineApiWrapper? offlineApi})
      : _offlineApi = offlineApi ?? AppBlocProvider.offlineApiWrapper,
        super(MyInitial()) {
    on<MyApiEvent>(_onMyApiEvent);
  }

  Future<void> _onMyApiEvent(
    MyApiEvent event,
    Emitter<MyState> emit,
  ) async {
    try {
      emit(MyLoading());
      
      final response = await _offlineApi.get('/api/data');
      
      if (response.statusCode == 200) {
        emit(MyLoaded(data: response.data));
      } else if (response.statusCode == 202) {
        emit(MyQueued());
      } else {
        emit(MyError());
      }
    } catch (e) {
      emit(MyError(message: e.toString()));
    }
  }
}
```

---

## 🔐 Login Handling

⚠️ **Important**: Login CANNOT be queued

```dart
// ❌ WRONG - Will fail offline
try {
  await offlineApi.post('/api/auth/loginWithPassword', data: credentials);
} catch (e) {
  // Will throw exception - login not supported offline
}

// ✅ RIGHT - Check connectivity first
if (AppBlocProvider.connectivityService.isOnline) {
  final response = await offlineApi.post('/api/auth/loginWithPassword', data: credentials);
} else {
  showError('No internet connection. Cannot login.');
}
```

---

## 🎨 UI Examples

### Connectivity Indicator
```dart
StreamBuilder<ConnectivityStatus>(
  stream: AppBlocProvider.connectivityService.statusStream,
  initialData: AppBlocProvider.connectivityService.currentStatus,
  builder: (context, snapshot) {
    final status = snapshot.data;
    return Chip(
      label: Text(status == ConnectivityStatus.online ? '🟢 Online' : '🔴 Offline'),
    );
  },
)
```

### Queue Status Badge
```dart
BlocBuilder<QueueBloc, QueueState>(
  builder: (context, state) {
    if (state is QueueStatusLoaded && state.pending > 0) {
      return Badge(
        label: Text('${state.pending}'),
        child: Icon(Icons.cloud_upload),
      );
    }
    return SizedBox();
  },
)
```

### Loading with Queue Message
```dart
if (response.statusCode == 202) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Request queued. Will process when online.'),
      duration: Duration(seconds: 3),
    ),
  );
}
```

---

## 🛠️ Configuration

### Cache Duration Guidelines

| Data Type | Duration | Reason |
|-----------|----------|--------|
| User Profile | 1 hour | Changes less frequently |
| Dashboard | 15 min | User may refresh manually |
| List Views | 30 min | Balance freshness & performance |
| Transactional | No cache | Always fresh |

### Queue Retry Settings

```dart
// Default: 5 retries
// Modify in QueuedRequest model if needed
maxRetries: 5

// Sync triggers:
// 1. Connectivity restored (immediate)
// 2. Manual trigger (super admin)
// 3. Periodic (every 5 minutes)
```

---

## 🐛 Troubleshooting

### Cache Not Working
```dart
// Check if endpoint is GET
if (request.method == 'GET') {
  // Should cache
}

// Check if useCache is true
await offlineApi.get('/api/data', useCache: true);

// Check if cache expired
if (cached.isValid()) {
  // Cache is good
}
```

### Queue Not Syncing
```dart
// Check connectivity
if (!AppBlocProvider.connectivityService.isOnline) {
  // Can't sync offline
}

// Check if syncing already
if (AppBlocProvider.syncService.isSyncing) {
  // Wait for current sync
}

// Manually trigger
await AppBlocProvider.syncService.startSync();
```

### Requests Not Queued
```dart
// Check if endpoint is excluded
if (endpoint.contains('login')) {
  // Won't queue
}

// Check shouldQueue parameter
await offlineApi.post('/api/data', shouldQueue: true);

// Check queue
final pending = await AppBlocProvider.queueRepository.getPendingRequests();
```

---

## 📊 Monitoring

### Check Queue Health
```dart
final stats = await AppBlocProvider.queueRepository.getQueueStatistics();

if (stats.failedCount > 0) {
  // Alert: Some requests failed
  // Show in super admin panel
}

if (stats.pendingCount > 100) {
  // Alert: Large queue
  // May indicate connectivity issues
}
```

### View Detailed Requests
```dart
final requests = await AppBlocProvider.queueRepository.getAllQueuedRequests();

requests.where((r) => r.status == QueueRequestStatus.failed).forEach((r) {
  print('Failed: ${r.endpoint} - ${r.errorMessage}');
});
```

---

## 🔗 Service Access

```dart
// Connectivity
AppBlocProvider.connectivityService

// Repositories
AppBlocProvider.cacheRepository
AppBlocProvider.queueRepository

// Services
AppBlocProvider.syncService
AppBlocProvider.offlineApiWrapper

// BLoCs
AppBlocProvider.queueBloc
```

---

## ✅ Checklist Before Production

- [ ] All API calls migrated to OfflineApiWrapper
- [ ] Appropriate cache durations set
- [ ] Queuing enabled for write operations
- [ ] Login excluded from queue
- [ ] Super admin queue UI implemented
- [ ] Offline scenarios tested
- [ ] Sync events handled in UI
- [ ] Error messages user-friendly
- [ ] Database performance tested
- [ ] Token refresh works during sync
- [ ] Cache cleared on logout
- [ ] Monitoring dashboard created

---

## 📚 Full Documentation

For detailed information, see:
- `OFFLINE_FIRST_GUIDE.md` - Full architecture guide
- `IMPLEMENTATION_EXAMPLES.dart` - Code examples
- `MIGRATION_CHECKLIST.md` - Implementation steps

---

**Version**: 1.0
**Last Updated**: December 21, 2025

