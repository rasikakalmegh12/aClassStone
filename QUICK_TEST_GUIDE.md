# 🚀 Quick Start: Testing Background Location Tracking

## 1️⃣ Build & Install (2 mins)
```bash
cd "/Users/rasikakalmegh/Desktop/rasika's workspace/marketing/aClassStone"
flutter clean
flutter pub get
flutter build apk --release
flutter install
```

## 2️⃣ Test on Device (5 mins)

### Step 1: Initial Setup
1. Open the app
2. Login as Executive
3. Go to Dashboard
4. Tap "Punch In"
5. **Grant ALL permissions when prompted:**
   - ✅ Location (Allow all the time)
   - ✅ Notifications
   - ✅ Battery optimization exemption

### Step 2: Verify Foreground Tracking
1. Keep app open
2. Wait 2 minutes
3. Check if notification shows "Attendance Tracking"
4. Expected: Location ping every 60 seconds

### Step 3: Test Background (Screen On)
1. Press Home button
2. Wait 3 minutes
3. Check backend API for location pings
4. Expected: Pings continue every 60 seconds

### Step 4: Test Locked Screen ⭐ CRITICAL
1. Lock the phone (press power button)
2. Wait 5 minutes
3. Unlock phone
4. Check: Settings → Apps → aClassStone → Battery
   - Should show high battery usage (this is normal)
5. Verify pings were sent during locked period

## 3️⃣ View Logs (Debug Mode)

### Real-time logs via USB:
```bash
adb logcat | grep -E "flutter|Location|Foreground"
```

### On-device log file:
```bash
adb shell run-as com.aclassstones.marketing cat app_flutter/location_ping_logs.txt
```

## 4️⃣ Common Issues & Quick Fixes

| Issue | Quick Fix |
|-------|-----------|
| Pings stop when locked | Settings → Battery → aClassStone → Unrestricted |
| Permission denied | Settings → Apps → aClassStone → Permissions → Location → Allow all the time |
| No notification | Settings → Apps → aClassStone → Notifications → Enable |
| Service crashes | Check Android version is 6.0+ |

## 5️⃣ Success Criteria ✅

- [ ] Location pings every 60 seconds when app open
- [ ] Location pings continue when app in background
- [ ] Location pings continue when screen is locked
- [ ] Notification shows "Attendance Tracking"
- [ ] Pings stop immediately after "Punch Out"
- [ ] Session persists after app restart

## 6️⃣ Test Devices

**Minimum Requirements:**
- Android 6.0 (API 23) or higher
- GPS/Location services enabled
- Internet connection (WiFi or Mobile data)

**Recommended Test Devices:**
- Android 10+ (for background location permission)
- Android 13+ (for notification permission)

## 🔍 Debugging Commands

```bash
# Check service is running
adb shell dumpsys activity services | grep Foreground

# Check battery whitelist
adb shell dumpsys deviceidle whitelist | grep aclassstones

# Force stop app
adb shell am force-stop com.aclassstones.marketing

# Clear app data (reset)
adb shell pm clear com.aclassstones.marketing
```

## 📊 Expected Behavior Timeline

| Time | Screen State | Expected Behavior |
|------|--------------|-------------------|
| 0:00 | Punch In | Service starts, notification appears |
| 1:00 | Open | 1st location ping sent |
| 2:00 | Open | 2nd location ping sent |
| 3:00 | Background | 3rd location ping sent |
| 4:00 | Locked | 4th location ping sent ⭐ |
| 5:00 | Locked | 5th location ping sent ⭐ |
| 10:00 | Locked | 10th location ping sent ⭐ |

## ⚠️ Important Notes

1. **First-time users**: Must grant battery exemption when prompted
2. **Battery Saver Mode**: May restrict background location - disable during testing
3. **Doze Mode**: Phone enters Doze after ~30 mins idle - app should still work due to foreground service
4. **OEM Restrictions**: Some manufacturers (Xiaomi, Huawei) have aggressive battery management - may need manual whitelist

## 🎯 What Changed from Previous Version

**Before:**
- ❌ Worked only when connected via USB debugging
- ❌ Stopped when screen locked
- ❌ Killed by Doze mode

**After:**
- ✅ Works standalone (no USB needed)
- ✅ Continues when screen locked
- ✅ Survives Doze mode via foreground service
- ✅ Requests battery optimization exemption
- ✅ Proper wake locks for CPU and WiFi

---

**Ready to test?** Start with Step 1 above! 🚀
