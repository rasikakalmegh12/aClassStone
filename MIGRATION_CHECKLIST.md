# Offline-First Implementation Checklist

## Phase 1: Setup & Initialization ✅
- [x] Add dependencies to `pubspec.yaml`
  - [x] sqflite (SQLite)
  - [x] hive (Optional caching)
  - [x] connectivity_plus (Network monitoring)
  - [x] uuid (Request IDs)
  - [x] path_provider (Database path)

- [x] Create core services
  - [x] `ConnectivityService` - Network monitoring
  - [x] `DatabaseHelper` - SQLite setup
  - [x] `SyncService` - Queue synchronization
  - [x] `OfflineApiWrapper` - API call interception

- [x] Create data models
  - [x] `CachedResponse` - Cache storage model
  - [x] `QueuedRequest` - Queue storage model

- [x] Create repositories
  - [x] `CacheRepository` - Cache CRUD operations
  - [x] `QueueRepository` - Queue CRUD operations

- [x] Create Queue BLoC
  - [x] `QueueBloc` - Queue management
  - [x] `QueueEvent` - Queue events
  - [x] `QueueState` - Queue states

- [x] Update service provider
  - [x] `AppBlocProvider.initialize()` - Async initialization
  - [x] Service getter methods
  - [x] Proper disposal

- [x] Update main.dart
  - [x] Async initialization call
  - [x] Add QueueBloc to providers

## Phase 2: Update Existing API Calls ⏳
Replace all direct API calls with `OfflineApiWrapper`

### Registration Module
- [ ] Update `RegistrationBloc` to use `OfflineApiWrapper`
  - [ ] Replace direct `/api/auth/register` calls
  - [ ] Enable queuing with `shouldQueue: true`
  - [ ] Handle 202 status code (queued)
  - [ ] Add user ID for sync tracking

- [ ] Update pending registrations fetch
  - [ ] Use `get()` with caching
  - [ ] Set appropriate cache duration
  - [ ] Handle offline fallback

- [ ] Update approval/rejection endpoints
  - [ ] Use `put()` with queuing
  - [ ] Track admin ID for audit
  - [ ] Handle queue responses

### Dashboard Module
- [ ] Update all dashboard data fetches
  - [ ] Use `get()` with caching
  - [ ] Cache durations: 15-30 minutes
  - [ ] Graceful offline handling
  - [ ] Refresh cache control

- [ ] `ExecutiveDashboard`
- [ ] `AdminDashboard`
- [ ] `SuperAdminDashboard`

### Attendance Module
- [ ] Update punch-in/punch-out
  - [ ] Use `post()` with queuing
  - [ ] Include timestamp and location
  - [ ] Queue on network failure
  - [ ] Custom sync handler (optional)

- [ ] Update attendance history fetch
  - [ ] Use `get()` with caching
  - [ ] Cache for 1 hour
  - [ ] Offline data availability

### Profile Module
- [ ] Update profile fetch
  - [ ] Use `get()` with caching
  - [ ] Cache indefinitely (user-managed)

- [ ] Update profile update
  - [ ] Use `put()` with queuing
  - [ ] Optimistic UI updates
  - [ ] Queue on failure

### Meetings Module
- [ ] Update meeting list fetch
  - [ ] Use `get()` with caching
  - [ ] 30-minute cache duration

- [ ] Update meeting detail fetch
  - [ ] Use `get()` with caching
  - [ ] Cache by meeting ID

- [ ] Update meeting actions (start/end)
  - [ ] Use `post()`/`put()` with queuing
  - [ ] Queue if offline

### Other Modules
- [ ] Identify all API endpoints
- [ ] Categorize as read (GET) or write (POST/PUT/DELETE)
- [ ] Apply appropriate offline handling

## Phase 3: Super Admin Queue Management UI 🎯
- [ ] Create Queue Status Screen
  - [ ] Display total queued requests
  - [ ] Show pending, failed, successful counts
  - [ ] Display last sync timestamp

- [ ] Queue Details Screen
  - [ ] List all queued requests
  - [ ] Show endpoint, method, status
  - [ ] Retry button for failed requests
  - [ ] Delete individual requests
  - [ ] Manual sync button

- [ ] Queue Statistics Dashboard
  - [ ] Queue size over time
  - [ ] Sync success rate
  - [ ] Failed request analysis
  - [ ] Most problematic endpoints

- [ ] Connectivity Status Widget
  - [ ] Display current status (Online/Offline)
  - [ ] Show in app bar or drawer
  - [ ] Color-coded indicator

- [ ] Sync Progress Indicator
  - [ ] Show when syncing
  - [ ] Display progress percentage
  - [ ] Completed/failed counts

## Phase 4: Integration Points 🔗

### Navigation
- [ ] Add Queue Status route (Super Admin only)
- [ ] Conditional visibility based on user role

### Widgets
- [ ] Add connectivity indicator to app bar
- [ ] Add queue badge to drawer/menu
- [ ] Add sync progress indicator
- [ ] Toast/snackbar notifications for queue events

### Error Handling
- [ ] Handle 202 responses in all BLoCs
- [ ] Show "queued" feedback to users
- [ ] Graceful offline state
- [ ] Network error messages

## Phase 5: Testing 🧪
- [ ] Unit Tests
  - [ ] `ConnectivityService` test
  - [ ] `CacheRepository` test
  - [ ] `QueueRepository` test
  - [ ] `OfflineApiWrapper` test
  - [ ] `SyncService` test

- [ ] Integration Tests
  - [ ] Online request flow
  - [ ] Offline request flow
  - [ ] Queue sync flow
  - [ ] Cache expiry flow

- [ ] Manual Testing
  - [ ] Offline registration
  - [ ] Offline data fetch (verify cache)
  - [ ] Connectivity restored → Auto sync
  - [ ] Manual sync button
  - [ ] Queue status view
  - [ ] Failed request retry
  - [ ] Login exclusion (must fail offline)

- [ ] Edge Cases
  - [ ] Toggle online/offline rapidly
  - [ ] Request timeout while offline
  - [ ] Max retry attempts
  - [ ] Cache expiry
  - [ ] Database corruption recovery
  - [ ] Duplicate requests prevention

## Phase 6: Production Readiness 🚀
- [ ] Performance Testing
  - [ ] Database query performance
  - [ ] Memory usage (large queue)
  - [ ] Cache size management
  - [ ] Sync batch processing

- [ ] Security Audit
  - [ ] Token inclusion in queued requests
  - [ ] Sensitive data in cache
  - [ ] Database encryption (optional)
  - [ ] Token refresh during sync

- [ ] Monitoring & Logging
  - [ ] Queue metrics dashboard
  - [ ] Sync success/failure rates
  - [ ] Most failed endpoints
  - [ ] Average sync time
  - [ ] User connectivity patterns

- [ ] Documentation
  - [ ] API documentation updates
  - [ ] User guide for offline features
  - [ ] Admin guide for queue management
  - [ ] Developer guide for new endpoints

- [ ] Deployment
  - [ ] Database migration strategy
  - [ ] Backward compatibility
  - [ ] Gradual rollout plan
  - [ ] Rollback procedure

## Phase 7: Post-Launch (Ongoing)
- [ ] Monitor queue metrics
- [ ] Analyze failed requests
- [ ] Optimize cache durations
- [ ] Improve sync handlers
- [ ] User feedback collection
- [ ] Performance optimization
- [ ] Update documentation

## File Checklist

### Created Files ✅
- [x] `lib/core/services/connectivity_service.dart`
- [x] `lib/core/services/sync_service.dart`
- [x] `lib/data/local/database_helper.dart`
- [x] `lib/data/local/cache_repository.dart`
- [x] `lib/data/local/queue_repository.dart`
- [x] `lib/data/models/cached_response.dart`
- [x] `lib/data/models/queued_request.dart`
- [x] `lib/api/network/offline_api_wrapper.dart`
- [x] `lib/bloc/queue/queue_bloc.dart`
- [x] `lib/bloc/queue/queue_event.dart`
- [x] `lib/bloc/queue/queue_state.dart`
- [x] `lib/bloc/queue/queue.dart`
- [x] `OFFLINE_FIRST_GUIDE.md`
- [x] `IMPLEMENTATION_EXAMPLES.dart`
- [x] `MIGRATION_CHECKLIST.md` (this file)

### Updated Files ⏳
- [x] `pubspec.yaml`
- [x] `lib/core/services/repository_provider.dart`
- [x] `lib/main.dart`
- [ ] `lib/bloc/registration/registration_bloc.dart`
- [ ] `lib/bloc/auth/auth_bloc.dart` (if needed)
- [ ] `lib/bloc/dashboard/dashboard_bloc.dart`
- [ ] `lib/api/integration/api_integration.dart`
- [ ] All other BLoCs using API calls

## Quick Implementation Guide

### For Each API-calling BLoC:

1. **Import offline wrapper**
   ```dart
   import 'package:apclassstone/api/network/offline_api_wrapper.dart';
   import 'package:apclassstone/core/services/repository_provider.dart';
   ```

2. **Add to constructor**
   ```dart
   final OfflineApiWrapper _offlineApi;
   
   MyBloc({OfflineApiWrapper? offlineApi})
       : _offlineApi = offlineApi ?? AppBlocProvider.offlineApiWrapper;
   ```

3. **Replace API calls**
   ```dart
   // OLD
   final response = await dio.get('/api/endpoint');
   
   // NEW (GET with cache)
   final response = await _offlineApi.get(
     '/api/endpoint',
     useCache: true,
     cacheDuration: Duration(minutes: 30),
   );
   
   // NEW (POST with queue)
   final response = await _offlineApi.post(
     '/api/endpoint',
     data: data,
     shouldQueue: true,
     userId: userId,
   );
   ```

4. **Handle 202 status**
   ```dart
   if (response.statusCode == 202) {
     // Request was queued
     emit(RequestQueuedState());
   } else if (response.statusCode! < 400) {
     // Success
     emit(SuccessState());
   } else {
     // Error
     emit(ErrorState());
   }
   ```

5. **Test offline behavior**
   - Toggle airplane mode
   - Verify cache usage
   - Verify queue creation
   - Verify sync on restore

## Important Notes

⚠️ **Login Exclusion**: Login requests CANNOT be queued
- They are excluded from queue by design
- Will throw exception if attempted offline
- Always require active connectivity

📝 **Token Management**: 
- Tokens are included in queued requests
- Ensure token refresh logic works during sync
- Handle token expiry gracefully

🔒 **Data Security**:
- Sensitive data stored in local database
- Consider device-level encryption
- Clear cache on logout

🎯 **Best Practices**:
- Cache GET endpoints with appropriate durations
- Queue write operations (POST/PUT/DELETE)
- Register custom handlers for complex logic
- Monitor queue health regularly

## Support & Troubleshooting

See `OFFLINE_FIRST_GUIDE.md` for:
- Detailed architecture explanation
- Usage examples
- Troubleshooting guide
- Best practices

See `IMPLEMENTATION_EXAMPLES.dart` for:
- Code examples
- Integration patterns
- BLoC modifications
- UI implementations

---

**Last Updated**: December 21, 2025
**Status**: Ready for Phase 2 Implementation
**Next Step**: Start migrating existing BLoCs

