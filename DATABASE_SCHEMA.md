# Database Schema Documentation

## Overview

The offline-first architecture uses SQLite for persistent local storage. The database contains two main tables for caching API responses and queuing failed requests.

## Database Structure

### File Location
```
Device Storage
└── databases/
    └── apclassstone.db  (SQLite database file)
```

### Tables

#### 1. `cached_responses` Table

Stores API responses for offline access and reduces redundant network calls.

**Purpose**: Cache GET responses to provide data when offline

**Schema**:
```sql
CREATE TABLE cached_responses(
  id TEXT PRIMARY KEY,
  endpoint TEXT NOT NULL,
  responseData TEXT,
  statusCode INTEGER NOT NULL,
  cachedAt TEXT NOT NULL,
  expiresAt TEXT,
  requestMethod TEXT NOT NULL,
  createdAt TEXT DEFAULT CURRENT_TIMESTAMP
)
```

**Column Descriptions**:

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | TEXT | No | Primary key, typically the endpoint URL |
| `endpoint` | TEXT | No | API endpoint path (e.g., `/api/users`) |
| `responseData` | TEXT | Yes | Full JSON response body (stored as string) |
| `statusCode` | INTEGER | No | HTTP status code (200, 201, etc.) |
| `cachedAt` | TEXT | No | Timestamp when response was cached (ISO 8601) |
| `expiresAt` | TEXT | Yes | Expiry timestamp (ISO 8601), null = no expiry |
| `requestMethod` | TEXT | No | HTTP method used (GET, POST, etc.) |
| `createdAt` | TEXT | No | Auto-generated timestamp |

**Indexes**:
```sql
CREATE INDEX idx_cache_endpoint ON cached_responses(endpoint)
CREATE INDEX idx_cache_expires ON cached_responses(expiresAt)
```

**Example Data**:
```json
{
  "id": "/api/users",
  "endpoint": "/api/users",
  "responseData": "[{\"id\":\"1\",\"name\":\"John\"},{\"id\":\"2\",\"name\":\"Jane\"}]",
  "statusCode": 200,
  "cachedAt": "2025-12-21T10:30:00.000Z",
  "expiresAt": "2025-12-21T11:00:00.000Z",
  "requestMethod": "GET",
  "createdAt": "2025-12-21T10:30:00.000Z"
}
```

---

#### 2. `queued_requests` Table

Stores failed API requests for retry when connectivity resumes.

**Purpose**: Queue POST/PUT/DELETE requests that failed due to no connectivity

**Schema**:
```sql
CREATE TABLE queued_requests(
  id TEXT PRIMARY KEY,
  endpoint TEXT NOT NULL,
  method TEXT NOT NULL,
  requestBody TEXT,
  headers TEXT,
  status TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  attemptedAt TEXT,
  retryCount INTEGER DEFAULT 0,
  maxRetries INTEGER DEFAULT 5,
  errorMessage TEXT,
  userId TEXT,
  metadata TEXT,
  createdAtLocal TEXT DEFAULT CURRENT_TIMESTAMP
)
```

**Column Descriptions**:

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | TEXT | No | Primary key, unique request ID (UUID) |
| `endpoint` | TEXT | No | API endpoint path |
| `method` | TEXT | No | HTTP method (GET, POST, PUT, DELETE, PATCH) |
| `requestBody` | TEXT | Yes | Request payload as JSON string |
| `headers` | TEXT | Yes | HTTP headers as JSON string (encoded) |
| `status` | TEXT | No | Current status: pending/inProgress/success/failed/retrying |
| `createdAt` | TEXT | No | When request was originally made (ISO 8601) |
| `attemptedAt` | TEXT | Yes | Last sync attempt timestamp (ISO 8601) |
| `retryCount` | INTEGER | No | Number of failed retry attempts |
| `maxRetries` | INTEGER | No | Maximum retry attempts allowed |
| `errorMessage` | TEXT | Yes | Last error message from failed attempt |
| `userId` | TEXT | Yes | User ID for audit/ownership tracking |
| `metadata` | TEXT | Yes | Additional context (encoded JSON) |
| `createdAtLocal` | TEXT | No | Auto-generated timestamp |

**Indexes**:
```sql
CREATE INDEX idx_queue_status ON queued_requests(status)
CREATE INDEX idx_queue_created ON queued_requests(createdAt)
```

**Status Values**:
- `pending` - Waiting for sync
- `inProgress` - Currently being synced
- `success` - Successfully synced
- `failed` - Max retries exceeded
- `retrying` - Retrying after failure

**Example Data**:
```json
{
  "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "endpoint": "/api/executive_history/punch-in",
  "method": "POST",
  "requestBody": "{\"timestamp\":\"2025-12-21T10:30:00Z\",\"location\":\"Office\"}",
  "headers": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "status": "pending",
  "createdAt": "2025-12-21T10:35:00.000Z",
  "attemptedAt": null,
  "retryCount": 0,
  "maxRetries": 5,
  "errorMessage": null,
  "userId": "user123",
  "metadata": "{\"punchType\":\"in\",\"device\":\"mobile\"}",
  "createdAtLocal": "2025-12-21T10:35:00.000Z"
}
```

---

## Data Lifecycle

### Cache Lifecycle

```
1. GET Request
   ↓
2. Check Cache
   ├→ Valid Cache Exists? → Return Cached Data (offline or online)
   └→ No/Expired Cache? → Make Network Request
   ↓
3. Network Response
   ├→ Success (200-299)? → Save to Cache + Return Data
   └→ Error/Offline? → Return Cache if Available
```

### Queue Lifecycle

```
1. POST/PUT/DELETE Request
   ↓
2. Try Network Request
   ├→ Online & Success? → Return Success
   ├→ Online & Failed? → Queue + Return 202
   └→ Offline? → Queue + Return 202
   ↓
3. Request in Queue
   ├→ Status: pending
   ├→ retryCount: 0
   └→ attemptedAt: null
   ↓
4. Connectivity Restored
   ├→ Fetch All Pending
   ├→ Retry Each Request
   │   ├→ Success? → Mark success
   │   └→ Failed? → Increment retry, Mark retrying
   ├→ Max Retries Exceeded? → Mark failed
   └→ Emit Sync Events
```

---

## Query Examples

### Cache Queries

**Get cached response**:
```sql
SELECT * FROM cached_responses 
WHERE endpoint = '/api/users' 
AND (expiresAt IS NULL OR expiresAt > datetime('now'))
LIMIT 1;
```

**Clear expired cache**:
```sql
DELETE FROM cached_responses 
WHERE expiresAt IS NOT NULL AND expiresAt < datetime('now');
```

**Update cache expiry**:
```sql
UPDATE cached_responses 
SET expiresAt = datetime('now', '+1 hour') 
WHERE endpoint = '/api/users';
```

---

### Queue Queries

**Get all pending requests**:
```sql
SELECT * FROM queued_requests 
WHERE status IN ('pending', 'retrying') 
ORDER BY createdAt ASC;
```

**Get failed requests**:
```sql
SELECT * FROM queued_requests 
WHERE status = 'failed' 
ORDER BY attemptedAt DESC;
```

**Queue statistics**:
```sql
SELECT 
  COUNT(*) as total,
  SUM(CASE WHEN status IN ('pending', 'retrying') THEN 1 ELSE 0 END) as pending,
  SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) as failed,
  SUM(CASE WHEN status = 'success' THEN 1 ELSE 0 END) as success
FROM queued_requests;
```

**Get user's queued requests**:
```sql
SELECT * FROM queued_requests 
WHERE userId = 'user123' 
ORDER BY createdAt DESC;
```

**Find requests older than 7 days**:
```sql
SELECT * FROM queued_requests 
WHERE createdAt < datetime('now', '-7 days');
```

---

## Data Size Estimation

### Cache Table

**Per entry**:
- Static fields: ~200 bytes
- Response data: Variable (typical 1-10 KB for JSON)
- **Total per entry**: ~2-15 KB

**Recommendation**:
- Cache 1-2 hours of data
- Auto-cleanup of expired entries
- Typical size: 10-50 MB

### Queue Table

**Per entry**:
- Static fields: ~300 bytes
- Request body: ~500 bytes - 5 KB
- Headers: ~200 bytes
- **Total per entry**: ~1-6 KB

**Typical scenarios**:
- Offline for 1 hour: 10-100 requests
- Database size: 50-600 KB
- Processing capacity: 1000+ requests

---

## Maintenance Operations

### Regular Cleanup

**Daily (automatic)**:
```dart
// Clear requests older than 30 days
await queueRepository.deleteOldRequests(30);

// Clear successful requests
await queueRepository.deleteProcessedRequests();

// Clear expired cache
await cacheRepository.deleteExpiredCache();
```

### On Logout

```dart
// Clear all user data
await DatabaseHelper.instance.clearAllData();
```

### Performance Optimization

**If database gets large**:
```sql
-- Vacuum database
VACUUM;

-- Reindex tables
REINDEX idx_cache_endpoint;
REINDEX idx_queue_status;
```

---

## Backup & Recovery

### Database Backup Location
```
iOS: /Library/Caches/<app-bundle-id>/databases/apclassstone.db
Android: /data/data/<app-package>/databases/apclassstone.db
```

### Recovery Procedure

1. **If database corrupted**:
   ```dart
   await DatabaseHelper.instance.close();
   await File(dbPath).delete();  // Delete corrupted file
   // Database will be recreated on next app launch
   ```

2. **If stuck in sync loop**:
   ```dart
   // Clear failed requests
   await queueRepository.deleteProcessedRequests();
   
   // Reset all to pending
   final requests = await queueRepository.getAllQueuedRequests();
   for (var req in requests) {
     await queueRepository.updateRequestStatus(
       req.id,
       QueueRequestStatus.pending,
     );
   }
   ```

---

## Monitoring

### Key Metrics

**Cache**:
- Hit ratio (requests served from cache vs network)
- Average response size
- Expiry frequency

**Queue**:
- Queue size (total, pending, failed)
- Sync success rate
- Average retry count
- Slowest endpoints

### Query for monitoring

```sql
-- Queue stats over time
SELECT 
  DATE(createdAt) as date,
  COUNT(*) as total,
  AVG(retryCount) as avg_retries,
  MAX(retryCount) as max_retries
FROM queued_requests
GROUP BY DATE(createdAt)
ORDER BY date DESC;

-- Most problematic endpoints
SELECT 
  endpoint,
  COUNT(*) as requests,
  SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) as failed,
  AVG(retryCount) as avg_retries
FROM queued_requests
GROUP BY endpoint
HAVING COUNT(*) > 5
ORDER BY failed DESC;
```

---

## Security Considerations

### Data Stored Locally

⚠️ **Sensitive Data**:
- Request bodies (may contain user input)
- API tokens in headers
- User IDs and metadata

### Security Measures

1. **Device-level encryption** (optional):
   ```dart
   // Can implement Encrypted Shared Preferences
   // for additional security
   ```

2. **Token refresh during sync**:
   - Ensure tokens are valid before sync
   - Handle token expiry gracefully
   - Clear queue on logout

3. **Clear cache on logout**:
   ```dart
   await DatabaseHelper.instance.clearAllData();
   ```

---

## Troubleshooting

### Database Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Database locked | Multiple access | Wait for operation to complete |
| Disk full | Large database | Clear old records, reduce cache time |
| Corrupted | Unexpected shutdown | Delete and recreate database |
| Slow queries | Missing indexes | Verify indexes exist |

### Monitor Database Health

```dart
// Check database exists and is valid
final dbPath = await getDatabasesPath();
final path = join(dbPath, 'apclassstone.db');
final exists = await File(path).exists();

// Check file size
final size = await File(path).length();
print('Database size: ${size / 1024 / 1024} MB');
```

---

## Version Control

**Current Schema Version**: 1

To add new columns in future:
1. Increment version number in `DatabaseHelper`
2. Add migration logic in `onUpgrade`
3. Handle backward compatibility

```dart
// Future migration example
Future<void> _upgradeTables(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    // Add new column for version 2
    await db.execute(
      'ALTER TABLE queued_requests ADD COLUMN priority INTEGER DEFAULT 0'
    );
  }
}
```

---

**Last Updated**: December 21, 2025
**Database Version**: 1.0
**Schema Format**: SQLite 3

