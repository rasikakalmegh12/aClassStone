# Offline-First Architecture - Visual Reference

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         FLUTTER APPLICATION                             │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │              PRESENTATION LAYER (UI & BLoCs)                     │  │
│  │  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────┐   │  │
│  │  │ Registration     │  │ Dashboard        │  │ Queue Status │   │  │
│  │  │ BLoC             │  │ BLoC             │  │ BLoC         │   │  │
│  │  └────────┬─────────┘  └────────┬─────────┘  └──────┬───────┘   │  │
│  │           │                     │                    │            │  │
│  │           ├─────────────┬───────┴──────────┬────────┤            │  │
│  │           │             │                  │        │            │  │
│  └───────────┼─────────────┼──────────────────┼────────┼────────────┘  │
│              │             │                  │        │                 │
│  ┌───────────▼─────────────▼──────────────────▼────────▼────────────┐  │
│  │          OFFLINE API WRAPPER                                      │  │
│  │  ┌─────────────┐  ┌──────────────┐  ┌──────────────────┐         │  │
│  │  │ get()       │  │ post()       │  │ put() delete()   │         │  │
│  │  └──────┬──────┘  └──────┬───────┘  └────────┬─────────┘         │  │
│  │         │                │                   │                    │  │
│  │  ┌──────▼────────────────▼───────────────────▼──────┐            │  │
│  │  │ Request Processing & Routing                     │            │  │
│  │  │ - Check connectivity                            │            │  │
│  │  │ - Check cache (for GET)                         │            │  │
│  │  │ - Try network                                   │            │  │
│  │  │ - Fallback to queue (for POST/PUT/DELETE)       │            │  │
│  │  └──────┬──────────────────────────────────────────┘            │  │
│  └─────────┼──────────────────────────────────────────────────────┘  │
│            │                                                           │
│  ┌─────────┴─────────┬───────────────────────────────────────────┐   │
│  │                   │                                           │   │
│  ▼                   ▼                                           ▼   │
│ ┌─────────────────┐ ┌──────────────────┐  ┌──────────────────┐      │
│ │ CONNECTIVITY    │ │ LOCAL DATABASE   │  │ SYNC SERVICE     │      │
│ │ SERVICE         │ │ (SQLite)         │  │                  │      │
│ │                 │ │                  │  │ - Auto-sync on   │      │
│ │ - Monitors      │ │ ┌──────────────┐ │  │   connectivity   │      │
│ │   network       │ │ │ cached_      │ │  │ - Periodic sync  │      │
│ │   status        │ │ │ responses    │ │  │   (5 min)        │      │
│ │ - Emits stream  │ │ │              │ │  │ - Custom         │      │
│ │ - Online/       │ │ │ queued_      │ │  │   handlers       │      │
│ │   offline       │ │ │ requests     │ │  │ - Event stream   │      │
│ │                 │ │ └──────────────┘ │  │                  │      │
│ └─────────────────┘ └──────────────────┘  └──────────────────┘      │
│                                                                        │
└────────────────────────────────────────────────────────────────────┬─┘
                                                                      │
                                                    ┌─────────────────┘
                                                    │
                                ┌───────────────────▼──────────────┐
                                │   NETWORK                        │
                                │ (When Online)                    │
                                │                                  │
                                │ ┌────────────────────────────┐  │
                                │ │ Connectivity Detection     │  │
                                │ │ - WiFi/Mobile/Ethernet    │  │
                                │ │ - Real-time updates       │  │
                                │ │ - Graceful degradation    │  │
                                │ └────────────────────────────┘  │
                                │                                  │
                                │ ┌────────────────────────────┐  │
                                │ │ Backend API Endpoints      │  │
                                │ │ - /api/auth/register       │  │
                                │ │ - /api/dashboard           │  │
                                │ │ - /api/attendance/punch-in │  │
                                │ │ - /api/...                 │  │
                                │ └────────────────────────────┘  │
                                │                                  │
                                └──────────────────────────────────┘
```

---

## Data Flow Diagrams

### GET Request Flow (with Caching)

```
┌─────────────────────┐
│  App requests       │
│  GET /api/data      │
└──────────┬──────────┘
           │
           ▼
┌──────────────────────────┐
│ OfflineApiWrapper.get()  │
└──────────┬───────────────┘
           │
           ▼
    ┌──────────────────┐
    │ Online?          │
    └─┬─────────────┬──┘
      │ No          │ Yes
      │             │
      ▼             ▼
   ┌──────────┐  ┌────────────────┐
   │ Check    │  │ Make Network   │
   │ Cache    │  │ Request        │
   └─┬────────┘  └─┬──────────────┘
     │            │ Success
     │            │ (200-299)
     │            │
     │            ▼
     │        ┌──────────────┐
     │        │ Cache Result │
     │        └─┬───────────┘
     │          │
     └──────┬───┘
            │
            ▼
    ┌──────────────────────┐
    │ Return Response      │
    │ + Data               │
    │ + StatusCode         │
    └──────────────────────┘
```

### POST Request Flow (with Queuing)

```
┌─────────────────────────────┐
│  App requests               │
│  POST /api/register         │
│  data: {user data}          │
└──────────┬──────────────────┘
           │
           ▼
┌──────────────────────────┐
│ OfflineApiWrapper.post() │
└──────────┬───────────────┘
           │
           ▼
    ┌──────────────────┐
    │ Online?          │
    └─┬─────────────┬──┘
      │ No          │ Yes
      │             │
      │             ▼
      │        ┌──────────────────┐
      │        │ Make Network     │
      │        │ Request          │
      │        └┬───────┬────────┘
      │         │       │
      │     Success   Failure
      │      (200)    (Error)
      │         │       │
      │         ▼       ▼
      │      Return  Queue
      │      200      Request
      │               │
      └───────────────┤
                      │
                      ▼
        ┌─────────────────────────┐
        │ Add to Queue            │
        │ - id: uuid              │
        │ - endpoint: /api/...    │
        │ - method: POST          │
        │ - body: {...}           │
        │ - status: pending       │
        │ - retry: 0              │
        └──────────┬──────────────┘
                   │
                   ▼
        ┌──────────────────────────┐
        │ Return 202 Accepted      │
        │ {                        │
        │   status: 'queued'       │
        │   message: 'Will sync...'│
        │ }                        │
        └──────────────────────────┘
```

### Sync Flow (Automatic)

```
┌──────────────────────────────┐
│ Connectivity Restored        │
│ (Online Detection)           │
└──────────┬───────────────────┘
           │
           ▼
┌──────────────────────────────┐
│ SyncService.startSync()      │
└──────────┬───────────────────┘
           │
           ▼
┌──────────────────────────────┐
│ Fetch All Pending Requests   │
│ FROM queued_requests         │
│ WHERE status IN              │
│   ('pending', 'retrying')    │
└──────────┬───────────────────┘
           │
           ▼
    ┌──────────────────┐
    │ For Each Request │
    └──────────┬───────┘
               │
               ▼
    ┌──────────────────────────┐
    │ Update Status:           │
    │ inProgress               │
    └──────────┬───────────────┘
               │
               ▼
    ┌──────────────────────────┐
    │ Make Network Request     │
    │ POST /api/endpoint       │
    │ data: {original data}    │
    └┬──────────────────────┬──┘
     │                      │
   Success                Failure
   (200-299)             (Error)
     │                      │
     ▼                      ▼
┌─────────────────┐  ┌──────────────────┐
│ Update Status:  │  │ Can Retry?       │
│ success         │  │ retryCount < 5   │
└────────┬────────┘  └─┬────────────┬──┘
         │            │ Yes        │ No
         │            │            │
         │            ▼            ▼
         │      ┌──────────────┐ ┌──────────────┐
         │      │ Increment    │ │ Update       │
         │      │ retryCount   │ │ Status:      │
         │      │ Mark:        │ │ failed       │
         │      │ retrying     │ └──────────────┘
         │      └──────┬───────┘       │
         │             │               │
         └──────────┬──┴───────────────┘
                    │
                    ▼
         ┌──────────────────────┐
         │ Emit Sync Event      │
         │ - success/failed/... │
         │ - request id         │
         │ - message            │
         └──────────┬───────────┘
                    │
                    ▼
         ┌──────────────────────┐
         │ All Done?            │
         └─┬────────────────┬───┘
           │ No             │ Yes
           │                │
      ┌────┴────┐          │
      │ Next    │          │
      │ request │          ▼
      └────┬────┘   ┌──────────────────┐
           │        │ Emit:            │
           │        │ SyncCompleted    │
           │        └──────────────────┘
           │
           └────────►[ Loop back ]
```

---

## State Machine - Request Lifecycle

```
                    ┌─────────────┐
                    │   PENDING   │
                    │  (queued)   │
                    └────────┬────┘
                             │
                    ┌────────▼────────┐
                    │   IN_PROGRESS   │
                    │  (syncing)      │
                    └┬──────────────┬─┘
                     │              │
              Success │              │ Failure
                     │              │
          ┌──────────▼──────┐   ┌────▼──────────────┐
          │     SUCCESS     │   │   Can Retry?      │
          │   (synced)      │   │  retryCount < max │
          └─────────────────┘   └─┬──────────────┬──┘
                                  │ Yes          │ No
                                  │              │
                          ┌───────▼──────┐  ┌────▼──────────┐
                          │   RETRYING   │  │    FAILED     │
                          │ (queued again)  │ (max retries) │
                          └───────┬──────┘  └───────────────┘
                                  │
                                  │ [Connectivity restored]
                                  │
                          ┌───────▼──────────┐
                          │    IN_PROGRESS   │
                          │   (retry sync)   │
                          └───────┬──────────┘
                                  │
                                  └──► [Back to Success or Failed]
```

---

## Cache Expiry Timeline

```
Time ──────────────────────────────────────────────────►

Request made & cached
│
│  [Cache Duration: 30 minutes]
│
├─ 5 min: Valid ✓
├─ 15 min: Valid ✓  ◄─ Get returns cached data
├─ 30 min: Valid ✓
├─ 31 min: Expired ✗  ◄─ Next GET will make network request
│
└─ Auto cleanup removes expired entries
```

---

## Database Tables Relationship

```
┌──────────────────────────────────────────────┐
│       Local SQLite Database                  │
│      (apclassstone.db)                       │
│                                              │
│  ┌─────────────────────────────────────────┐│
│  │ cached_responses                         ││
│  ├─────────────────────────────────────────┤│
│  │ id (PK)              │                   ││
│  │ endpoint             │ ◄─ API path      ││
│  │ responseData         │ ◄─ JSON response ││
│  │ statusCode           │                   ││
│  │ cachedAt             │ ◄─ When cached   ││
│  │ expiresAt            │ ◄─ Expiry time   ││
│  │ requestMethod        │                   ││
│  └─────────────────────────────────────────┘│
│                                              │
│  ┌─────────────────────────────────────────┐│
│  │ queued_requests                          ││
│  ├─────────────────────────────────────────┤│
│  │ id (PK)              │                   ││
│  │ endpoint             │ ◄─ API path      ││
│  │ method               │ ◄─ POST/PUT/DEL  ││
│  │ requestBody          │ ◄─ Request data  ││
│  │ headers              │ ◄─ Auth headers  ││
│  │ status               │ ◄─ pending/...   ││
│  │ createdAt            │ ◄─ When queued   ││
│  │ attemptedAt          │ ◄─ Last attempt  ││
│  │ retryCount           │ ◄─ # of retries  ││
│  │ maxRetries           │                   ││
│  │ errorMessage         │ ◄─ Last error    ││
│  │ userId               │ ◄─ User tracking ││
│  │ metadata             │ ◄─ Extra info    ││
│  └─────────────────────────────────────────┘│
│                                              │
│  Indexes:                                    │
│  - cached_responses: endpoint, expiresAt    │
│  - queued_requests: status, createdAt       │
│                                              │
└──────────────────────────────────────────────┘
```

---

## Service Initialization Order

```
main()
  │
  ├─ WidgetsFlutterBinding.ensureInitialized()
  │
  ├─ SessionManager.init()
  │   └─ Load user session from SharedPreferences
  │
  ├─ AppBlocProvider.initialize()
  │   │
  │   ├─ ConnectivityService.initialize()
  │   │   └─ Start monitoring network
  │   │
  │   ├─ DatabaseHelper.initialize()
  │   │   └─ Create/open SQLite database
  │   │
  │   ├─ CacheRepository()
  │   │   └─ Ready to cache responses
  │   │
  │   ├─ QueueRepository()
  │   │   └─ Ready to queue requests
  │   │
  │   ├─ OfflineApiWrapper.initialize()
  │   │   └─ Ready for offline API calls
  │   │
  │   ├─ SyncService.initialize()
  │   │   ├─ Listen to connectivity changes
  │   │   └─ Start auto-sync timer
  │   │
  │   ├─ LoginBloc()
  │   ├─ RegistrationBloc()
  │   └─ QueueBloc()
  │
  └─ runApp(MyApp())
     └─ MultiBlocProvider
        ├─ authBloc
        ├─ registrationBloc
        ├─ queueBloc
        └─ [other blocs]
```

---

## Component Interaction Diagram

```
┌──────────────┐
│   UI/Screen  │
└──────┬───────┘
       │ emit event
       ▼
┌──────────────┐
│     BLoC     │──────────┐
└──────┬───────┘          │
       │                  │
       │ calls            │
       ▼                  │
┌────────────────────┐    │
│ OfflineApiWrapper  │    │
├────────────────────┤    │
│ • get()            │    │ uses
│ • post()           │───►├─────────────────────┐
│ • put()            │    │                     │
│ • delete()         │    ▼                     │
└─┬──────────────────┘   ┌──────────────────┐  │
  │                      │ ConnectivityService  │
  │ uses                 │ • isOnline          │
  │                      │ • statusStream      │
  ▼                      └──────────────────┘  │
┌──────────────────────────┐                   │
│ Local Database           │                   │
├──────────────────────────┤   uses/listens    │
│ • cached_responses       │◄──────────────────┘
│ • queued_requests        │
│                          │
│ ┌──────────────────────┐ │
│ │ CacheRepository      │ │
│ │ QueueRepository      │ │
│ └──────────────────────┘ │
└──────────────────────────┘
        │
        │ uses
        │
        ▼
┌──────────────────────────┐
│ SyncService              │
├──────────────────────────┤
│ • Auto-sync engine       │
│ • Retry logic            │
│ • Event streaming        │
│ • Custom handlers        │
└──────────────────────────┘
        │
        │ syncs to
        │
        ▼
┌──────────────────────────┐
│ Backend APIs             │
│ (When Online)            │
└──────────────────────────┘
```

---

## Queue Status Visibility

```
┌────────────────────────────────┐
│   User Interface               │
├────────────────────────────────┤
│                                │
│  Regular User:                 │
│  ┌──────────────────────────┐  │
│  │ Connectivity Indicator   │  │
│  │ (Online/Offline only)    │  │
│  │                          │  │
│  │ "Syncing..." message     │  │
│  └──────────────────────────┘  │
│                                │
│  ─────────────────────────────  │
│                                │
│  Super Admin User:             │
│  ┌──────────────────────────┐  │
│  │ Queue Status Dashboard   │  │
│  │ • Total queued: 5        │  │
│  │ • Pending: 3             │  │
│  │ • Failed: 2              │  │
│  │ • Last sync: 2 min ago   │  │
│  │                          │  │
│  │ [Refresh] [Manual Sync]  │  │
│  │ [View Details] [Clear]   │  │
│  └──────────────────────────┘  │
│                                │
│  ┌──────────────────────────┐  │
│  │ Queue Details List       │  │
│  │ • /api/register - failed │  │
│  │ • /api/punch-in - pending   │
│  │ • /api/profile - pending│  │
│  │                          │  │
│  │ [Retry] [Remove]         │  │
│  └──────────────────────────┘  │
│                                │
└────────────────────────────────┘
```

---

**Visual Reference Version**: 1.0
**Last Updated**: December 21, 2025

