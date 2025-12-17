# Network Error Fix Guide

## Issues Fixed

### 1. **Missing Internet Permissions** ✅
- **Problem**: Android app couldn't make network requests
- **Solution**: Added `INTERNET` and `ACCESS_NETWORK_STATE` permissions to `AndroidManifest.xml`
- **File**: `android/app/src/main/AndroidManifest.xml`

### 2. **Cleartext Traffic Blocked on Android 9+** ✅
- **Problem**: HTTP requests (not HTTPS) are blocked by default on Android 9 and higher
- **Solution**: Created network security configuration to allow cleartext traffic for the development API
- **Files**: 
  - Created: `android/app/src/main/res/xml/network_security_config.xml`
  - Updated: `android/app/src/main/AndroidManifest.xml` to reference the security config

### 3. **Improved Error Handling** ✅
- **Problem**: TimeoutException wasn't being caught, making debugging harder
- **Solution**: Added comprehensive error handling in login method
- **File**: `lib/api/integration/api_integration.dart`
- **Changes**:
  - Added `import 'dart:async'` for TimeoutException
  - Added TimeoutException handler with user-friendly message
  - Improved ClientException handler with more details
  - Better error logging for debugging

## Steps to Rebuild and Test

### 1. Clean Build
```bash
cd /Users/rasikakalmegh/Desktop/rasika\'s\ workspace/apclassstone
flutter clean
```

### 2. Get Dependencies
```bash
flutter pub get
```

### 3. Build APK for Release
```bash
flutter build apk --release
```

### 4. Install APK
```bash
flutter install
```

### 5. Run the App
```bash
flutter run
```

### 6. Test Login
- Use the Super Admin credentials (shown in login screen)
- Monitor logs with: `flutter logs`

## Debugging Tips

### View Logs
```bash
flutter logs
```

### Check Network Connectivity
- Ensure device/emulator has internet access
- Try pinging the server: `ping 64.227.134.138`
- Check if the API endpoint is accessible

### Verify Permissions
On Android device:
- Go to Settings > Apps > apclassstone > Permissions
- Ensure INTERNET permission is granted

### Check API Configuration
- Endpoint: `http://64.227.134.138:5105/api/v1/auth/login`
- Method: POST
- Headers: `Content-Type: application/json`
- Body: `{"email": "...", "password": "...", "appCode": "MARKETING"}`

## Error Messages and Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| "Network error: Unable to reach the server" | No INTERNET permission or API unreachable | Check permissions, verify API is running |
| "Request timeout" | API too slow or not responding | Check API server, increase timeout if needed |
| "Server error: 500" | API error | Check API logs and debug server-side |
| "Login failed. Status: Invalid credentials" | Wrong email/password | Verify credentials |

## Files Modified

1. ✅ `android/app/src/main/AndroidManifest.xml` - Added permissions and security config
2. ✅ `android/app/src/main/res/xml/network_security_config.xml` - Created new file
3. ✅ `lib/api/integration/api_integration.dart` - Improved error handling

