import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';

import '../../api/integration/api_integration.dart';
import '../../api/models/request/PunchInOutRequestBody.dart';
import '../../core/session/session_manager.dart';

class LocationTaskHandler extends TaskHandler {
  // Helper: append a short log line to a file in app documents dir
  Future<void> _appendDeviceLog(String line) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final f = File('${dir.path}/location_ping_logs.txt');
      final ts = DateTime.now().toIso8601String();
      await f.writeAsString('[$ts] $line\n', mode: FileMode.append, flush: true);
    } catch (e) {
      if (kDebugMode) print('Error writing device log: $e');
    }
  }

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    if (kDebugMode) {
      print('🟢 Foreground service started at $timestamp');
    }

    // Ensure SharedPreferences is initialized in this isolate/background task
    try {
      await SessionManager.init();
      if (kDebugMode) {
        print('🔁 SessionManager initialized in background isolate');
      }
      // Persist that the foreground service is running
      await SessionManager.setForegroundServiceRunning(true);
      await _appendDeviceLog('FGS started in isolate');
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to initialize SessionManager in background: $e');
      }
      await _appendDeviceLog('FGS start error: $e');
    }
  }

  /// Called every interval (repeat event)
  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    // Ensure SessionManager initialized in case onStart didn't complete correctly
    try {
      await SessionManager.init();
    } catch (e) {
      if (kDebugMode) print('⚠️ SessionManager.init() failed in onRepeatEvent: $e');
      await _appendDeviceLog('SessionManager.init failed in onRepeatEvent: $e');
    }
    await _sendLocation();
  }

  Future<void> _sendLocation() async {
    try {
      final bool isPunchedIn = SessionManager.isPunchedIn();
      if (kDebugMode) {
        print('📍 Punch in status: $isPunchedIn');
      }
      await _appendDeviceLog('Punch in status: $isPunchedIn');

      if (!isPunchedIn) {
        if (kDebugMode) {
          print('⛔ Not punched in, skipping location ping');
        }
        await _appendDeviceLog('Skipped ping: not punched in');
        return;
      }

      // Check location permission before trying to get the position
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (kDebugMode) {
          print('⛔ Location permission not granted: $permission');
        }
        await _appendDeviceLog('Location permission not granted: $permission');
        // Don't request permission from a background isolate; app UI should request it.
        return;
      }

      Position? position = await Geolocator.getLastKnownPosition();
      position ??= await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      // currentPosition will be non-null if permission granted; proceed.

      if (kDebugMode) {
        print('📍 LAT=${position.latitude}, LNG=${position.longitude}');
      }
      await _appendDeviceLog('Got position: ${position.latitude},${position.longitude} acc=${position.accuracy}');

      final body = PunchInOutRequestBody(
        capturedAt: DateTime.now().toUtc().toIso8601String(),
        lat: position.latitude,
        lng: position.longitude,
        accuracyM: position.accuracy.toInt(),
        deviceId: '',
        deviceModel: '',
      );

      final response = await ApiIntegration.locationPing(body);
      if (kDebugMode) {
        print("response of location ping ${json.encode(response.message)}");
      }
      await _appendDeviceLog('Ping response: ${response.status} ${response.message}');

      if (kDebugMode) {
        print('✅ Location ping sent successfully');
      }
    } catch (e, s) {
      if (kDebugMode) {
        print('❌ Error sending location: $e');
        print(s);
      }
      await _appendDeviceLog('Error sending location: $e');
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    if (kDebugMode) {
      print('🔴 Foreground service destroyed at $timestamp');
    }
    try {
      await SessionManager.init();
      await SessionManager.setForegroundServiceRunning(false);
      await _appendDeviceLog('FGS destroyed in isolate');
    } catch (_) {
      // ignore
    }
  }
}