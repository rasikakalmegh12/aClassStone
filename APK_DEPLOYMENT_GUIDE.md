# APK Build & Deployment Guide

## ✅ Build Status: SUCCESS

The release APK has been successfully built at:
```
build/app/outputs/flutter-apk/app-release.apk (52.0MB)
```

## Installation Steps

### Option 1: Using ADB (Android Debug Bridge)

```bash
# Connect your Android device via USB and enable USB debugging
# Then run:
adb install build/app/outputs/flutter-apk/app-release.apk

# Or use flutter install
flutter install -v
```

### Option 2: Manual Installation
1. Connect your Android device to the computer via USB
2. Enable USB Debugging on your device (Settings > Developer Options)
3. Copy the APK to your device or use ADB to install

### Option 3: Share APK
- Locate the APK at: `build/app/outputs/flutter-apk/app-release.apk`
- Share via email, cloud storage, or directly transfer to device
- Install by opening the APK file on your device

## Pre-Deployment Checklist

- [x] INTERNET permission added to AndroidManifest.xml
- [x] ACCESS_NETWORK_STATE permission added
- [x] Network security configuration created for HTTP traffic
- [x] Error handling improved for timeout and network errors
- [x] API endpoint verified: http://64.227.134.138:5105/api/v1/auth/login
- [x] APK built successfully

## Testing Procedure

### 1. Install App
```bash
# Install the APK on your device
adb install -r build/app/outputs/flutter-apk/app-release.apk

# Or if using flutter directly
flutter install
```

### 2. Verify Permissions
On your Android device:
- Go to Settings > Apps > apclassstone > Permissions
- Verify that "Internet" permission is granted

### 3. Test Login
- Launch the app
- You should see the login screen with credential options
- Try logging in with one of the provided credentials:
  - **Super Admin**: superadmin@acls.local / password
  - **Admin**: admin@acls.local / password
  - **Executive**: executive@acls.local / password

### 4. Monitor Logs
In a terminal, run:
```bash
flutter logs
```

Look for these indicators of successful login:
- `✅ Login successful`
- `Access token stored in session`
- Navigation to dashboard

### 5. Troubleshoot if Needed

**If you see "Network error":**
1. Check that the device has internet access
2. Verify INTERNET permission is granted in app settings
3. Ensure the API server is running at http://64.227.134.138:5105
4. Check that you're not behind a firewall blocking this IP

**If you see "Request timeout":**
- The API server may be slow
- Try again after waiting
- Check if the server is responding: `curl http://64.227.134.138:5105/api/v1/auth/login -v`

**If login appears to succeed but dashboard doesn't load:**
- Check the logs for any provider errors
- Ensure SessionManager is properly initialized in main.dart
- Verify the user's role is being stored correctly

## Post-Login Navigation

After successful login, you should be redirected to the appropriate dashboard:
- **Super Admin** → Super Admin Dashboard
- **Admin** → Admin Dashboard  
- **Executive** → Executive Dashboard

## API Endpoint Verification

To verify the API is accessible before testing:

```bash
# Check if server is responding
curl -X POST http://64.227.134.138:5105/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"superadmin@acls.local","password":"password","appCode":"MARKETING"}'
```

Expected response:
```json
{
  "status": true,
  "message": "Login successful",
  "statusCode": 200,
  "data": {
    "accessToken": "...",
    "refreshToken": "...",
    ...
  }
}
```

## File Structure

Key files that were modified for network functionality:

```
android/
├── app/
│   └── src/
│       ├── main/
│       │   ├── AndroidManifest.xml (✅ Added permissions)
│       │   └── res/
│       │       └── xml/
│       │           └── network_security_config.xml (✅ Created)
│       ├── debug/
│       │   └── AndroidManifest.xml (Already has INTERNET)
│       └── profile/
│           └── AndroidManifest.xml (Already has INTERNET)

lib/
└── api/
    └── integration/
        └── api_integration.dart (✅ Improved error handling)
```

## Deployment Notes

- This is a **development build** configured to allow cleartext (HTTP) traffic for the staging API
- For production, ensure the API uses HTTPS and update the security configuration accordingly
- The network security configuration restricts cleartext to only the development server (64.227.134.138)
- All other domains require HTTPS for security

## Next Steps

1. ✅ Build APK (Completed)
2. → Install APK on device
3. → Test login functionality
4. → Verify dashboard loads correctly
5. → Test other features (registration, attendance, meetings)
6. → Prepare for production deployment

## Support & Debugging

If you encounter issues:

1. **Check logs**: `flutter logs`
2. **Verify permissions**: Check app settings
3. **Test API connectivity**: Use curl to test the endpoint
4. **Check internet connection**: Ensure device has active internet
5. **Review error messages**: They now provide more detailed information
6. **Rebuild if needed**: Run `flutter clean && flutter pub get && flutter build apk --release`

