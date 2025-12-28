import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';


/// Helper class to handle battery optimization and location permissions
/// for background location tracking even when phone is locked
class BatteryOptimizationHelper {
  static const MethodChannel _channel = MethodChannel('com.aclassstones.marketing/battery');

  /// Request all necessary permissions for background location tracking
  static Future<bool> requestAllPermissions() async {
    if (!Platform.isAndroid) return true;

    try {
      // 1. Request location permissions
      final locationStatus = await _requestLocationPermissions();
      if (!locationStatus) {
        if (kDebugMode) print('❌ Location permissions denied');
        return false;
      }

      // 2. Request notification permission (Android 13+)
      if (Platform.isAndroid) {
        final notificationStatus = await Permission.notification.request();
        if (kDebugMode) print('📲 Notification permission: $notificationStatus');
      }

      // 3. Request battery optimization exemption
      await requestBatteryOptimizationExemption();

      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error requesting permissions: $e');
      return false;
    }
  }

  /// Request location permissions (foreground and background)
  static Future<bool> _requestLocationPermissions() async {
    try {
      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (kDebugMode) print('⚠️ Location services are disabled');
        return false;
      }

      // Request foreground location permission first
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (kDebugMode) print('❌ Foreground location permission denied');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (kDebugMode) print('❌ Location permission permanently denied');
        return false;
      }

      // For Android 10+ (API 29+), request background location separately
      if (Platform.isAndroid) {
        final bgLocationStatus = await Permission.locationAlways.request();
        if (kDebugMode) print('📍 Background location permission: $bgLocationStatus');

        if (!bgLocationStatus.isGranted) {
          if (kDebugMode) print('⚠️ Background location not granted, but continuing...');
        }
      }

      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error requesting location permissions: $e');
      return false;
    }
  }

  /// Request battery optimization exemption to prevent Android from killing the service
  static Future<void> requestBatteryOptimizationExemption() async {
    if (!Platform.isAndroid) return;

    try {
      final bool? isIgnoringBatteryOptimizations =
          await _channel.invokeMethod('isIgnoringBatteryOptimizations');

      if (kDebugMode) {
        print('🔋 Battery optimization status: ${isIgnoringBatteryOptimizations == true ? "Exempt" : "Not exempt"}');
      }

      if (isIgnoringBatteryOptimizations != true) {
        // Show dialog to user explaining why this is needed
        final bool? requested = await _channel.invokeMethod('requestBatteryOptimizationExemption');
        if (kDebugMode) {
          print('🔋 Battery optimization exemption requested: ${requested == true ? "Yes" : "No"}');
        }
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error with battery optimization: $e');
    }
  }

  /// Check if battery optimization is ignored (exempted)
  static Future<bool> isIgnoringBatteryOptimizations() async {
    if (!Platform.isAndroid) return true;

    try {
      final bool? result = await _channel.invokeMethod('isIgnoringBatteryOptimizations');
      return result ?? false;
    } catch (e) {
      if (kDebugMode) print('❌ Error checking battery optimization: $e');
      return false;
    }
  }

  /// Check if all permissions are granted
  static Future<bool> areAllPermissionsGranted() async {
    if (!Platform.isAndroid) return true;

    try {
      // Check location permission
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return false;
      }

      // Check background location (Android 10+)
      final bgLocation = await Permission.locationAlways.status;
      if (!bgLocation.isGranted) {
        if (kDebugMode) print('⚠️ Background location not granted');
      }

      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error checking permissions: $e');
      return false;
    }
  }
}

