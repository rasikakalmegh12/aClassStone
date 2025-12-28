# 📍 Background Location Tracking Implementation Guide

## Overview
This guide explains the implementation of background location tracking that works even when the phone is **locked** and the app is in the **background**.

## 🔧 What Was Implemented

### 1. **Battery Optimization Helper** (`lib/core/utils/battery_optimization_helper.dart`)
A utility class that handles:
- ✅ Foreground location permissions
- ✅ Background location permissions (Android 10+)
- ✅ Notification permissions (Android 13+)
- ✅ Battery optimization exemption requests
- ✅ Permission status checking

### 2. **Native Android Battery Optimization** (`MainActivity.kt`)
Added native Android code to:
- Check if app is exempt from battery optimization
- Request battery optimization exemption from the user
- Uses `PowerManager` API for Android 6+

### 3. **Enhanced AndroidManifest.xml**
Added critical permissions:
```xml
<!-- Battery optimization exemption -->
<uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />

<!-- Notifications for Android 13+ -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

### 4. **Improved Location Handler** (`location_handler.dart`)
Enhanced error handling:
- Better null safety for `SessionManager`
- Timeout protection for location requests (30 seconds)
- Fallback to last known position if current position fails
- Detailed logging to device file for debugging

### 5. **Foreground Service Configuration** (`main.dart`)
Updated with:
- `allowWakeLock: true` - Keeps CPU awake even when screen is locked
- `allowWifiLock: true` - Keeps WiFi awake for network requests
- Proper notification icon configuration

### 6. **Executive Dashboard Updates**
Modified `_handlePunchAction()` to:
- Request all permissions before punching in
- Request battery optimization exemption
- Show user-friendly error messages

## 🚀 How It Works

### When User Punches In:
1. **Permission Request Flow:**
   ```
   Punch In → Request Foreground Location → Request Background Location 
   → Request Notifications → Request Battery Exemption
   ```

2. **Foreground Service Starts:**
   - Service acquires wake lock
   - Location updates every 60 seconds
   - Sends data to API even when screen is locked

3. **Background Isolate:**
   - Runs independently of main app
   - Initializes SessionManager in background
   - Checks punch-in status before each ping
   - Handles errors gracefully

### When Phone is Locked:
- Wake lock keeps CPU active
- WiFi lock maintains network connection
- Foreground service notification keeps Android from killing the process
- Battery optimization exemption prevents Doze mode restrictions

## 📱 Testing Instructions

### Before Testing:
1. **Install the app:**
   ```bash
   flutter build apk --release
   flutter install
   ```

2. **Grant all permissions manually (if needed):**
   - Go to: Settings → Apps → aClassStone → Permissions
   - Enable: Location → "Allow all the time"
   - Battery → "Unrestricted"

### Test Scenarios:

#### ✅ Test 1: Foreground Tracking
1. Open app and punch in
2. Grant all permissions when prompted
3. Keep app open
4. Check logs: `adb logcat | grep flutter`
5. Expected: Location ping every 60 seconds

#### ✅ Test 2: Background Tracking (Screen On)
1. Punch in
2. Press Home button (don't close app)
3. Wait 2-3 minutes
4. Check logs or API to verify pings received

#### ✅ Test 3: Locked Screen Tracking (CRITICAL)
1. Punch in
2. Lock the phone (press power button)
3. Wait 5-10 minutes
4. Unlock and check:
   - Log file: App documents directory → `location_ping_logs.txt`
   - API backend: Check if pings were received
   - Expected: Continuous pings every 60 seconds

#### ✅ Test 4: After Phone Reboot
1. Punch in
2. Note the time
3. Reboot phone
4. Open app again
5. Check if session persists (should still be punched in)
6. Verify tracking resumes

### Debugging Commands:

**Check if foreground service is running:**
```bash
adb shell dumpsys activity services | grep ForegroundService
```

**View location ping logs from device:**
```bash
adb shell run-as com.aclassstones.marketing cat /data/user/0/com.aclassstones.marketing/app_flutter/location_ping_logs.txt
```

**Check battery optimization status:**
```bash
adb shell dumpsys deviceidle whitelist | grep aclassstones
```

**Monitor location updates in real-time:**
```bash
adb logcat | grep -E "flutter|Location|ForegroundService"
```

## 🔍 Troubleshooting

### Issue: Location pings stop when screen is locked

**Solution:**
1. Check battery optimization is disabled:
   - Settings → Battery → Battery optimization
   - Find "aClassStone" → Select "Don't optimize"

2. Check background location permission:
   - Settings → Apps → aClassStone → Permissions → Location
   - Should be "Allow all the time"

3. Disable battery saver mode during testing

### Issue: Foreground service crashes on start

**Check:**
1. Notification permission granted (Android 13+)
2. Foreground service type is "location" in manifest
3. Location permission is granted before starting service

### Issue: "Null check operator used on a null value"

**Fix:**
- Ensure `SessionManager.init()` is called in background isolate
- Check `isPunchedIn()` method returns default false if null
- Verify SharedPreferences is accessible in background

### Issue: No location pings in APK but works in debug

**Reasons:**
1. ProGuard/R8 may be removing code → Already disabled in build.gradle
2. Missing runtime permissions in release build
3. Battery optimization enabled by default in release

**Solution:**
- Request battery exemption on first punch-in
- Add keep rules if enabling minification later

## 📊 Monitoring Location Pings

### View On-Device Logs:
Location pings are logged to a file you can access:

**Path:** `/data/data/com.aclassstones.marketing/app_flutter/location_ping_logs.txt`

**Access via ADB:**
```bash
adb shell run-as com.aclassstones.marketing cat app_flutter/location_ping_logs.txt
```

**Log Format:**
```
[2025-12-28T10:15:30.123Z] FGS started in isolate
[2025-12-28T10:16:30.456Z] Punch in status: true
[2025-12-28T10:16:31.789Z] Got position: 26.9124,75.7873 acc=12.5
[2025-12-28T10:16:32.012Z] Ping response: success message
```

## ⚙️ Configuration Options

### Adjust Ping Interval:
In `main.dart`:
```dart
ForegroundTaskOptions(
  eventAction: ForegroundTaskEventAction.repeat(60000), // milliseconds
  // 60000 = 1 minute
  // 120000 = 2 minutes
  // 300000 = 5 minutes
)
```

### Change Location Accuracy:
In `location_handler.dart`:
```dart
Geolocator.getCurrentPosition(
  desiredAccuracy: LocationAccuracy.medium, // or .high, .low, .best
  timeLimit: const Duration(seconds: 30),
)
```

## 🎯 Key Files Modified

| File | Purpose |
|------|---------|
| `lib/core/utils/battery_optimization_helper.dart` | Permission & battery management |
| `android/app/src/main/kotlin/.../MainActivity.kt` | Native battery optimization API |
| `android/app/src/main/AndroidManifest.xml` | Permissions & service config |
| `lib/main.dart` | Foreground service initialization |
| `lib/presentation/widgets/location_handler.dart` | Background location tracking logic |
| `lib/presentation/screens/executive/dashboard/executive_home_dashboard.dart` | Permission requests on punch-in |
| `pubspec.yaml` | Added `permission_handler` package |

## 📝 Important Notes

1. **Battery Impact**: Continuous location tracking drains battery. Inform users.

2. **Privacy Compliance**: 
   - Clearly explain why background location is needed
   - Show notification when tracking is active
   - Allow users to punch out to stop tracking

3. **Android Version Support**:
   - Android 6-9: Foreground + background location work with same permission
   - Android 10+: Requires separate background location permission
   - Android 12+: Need precise location permission
   - Android 13+: Need notification permission

4. **iOS Support**: 
   - Current implementation is Android-focused
   - For iOS, need to:
     - Enable "Background Modes" capability
     - Add location background mode
     - Update Info.plist with location usage descriptions

## 🔐 Security & Best Practices

✅ **Implemented:**
- Only track when user is punched in
- Stop tracking immediately on punch out
- User must explicitly grant permissions
- Clear notification shows tracking is active

✅ **Recommended:**
- Regularly audit location data collection
- Provide opt-out mechanism
- Delete old location data per company policy
- Encrypt location data in transit (HTTPS)

## 📞 Support

If location tracking still doesn't work after following this guide:

1. Check device logs for specific errors
2. Verify API endpoint is receiving requests
3. Test on different Android versions
4. Ensure device has GPS/location services enabled

---

**Last Updated:** December 28, 2025  
**Version:** 1.0.0

