import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:apclassstone/core/constants/app_colors.dart';
import 'package:apclassstone/core/session/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../api/models/response/ExecutiveTrackingByDaysResponse.dart';
import '../../../bloc/attendance/attendance_bloc.dart';
import '../../../bloc/attendance/attendance_event.dart';
import '../../../bloc/attendance/attendance_state.dart';

class ExecutiveTracking extends StatefulWidget {
  final String userId;
  final String date;

  const ExecutiveTracking({
    super.key,
    required this.userId,
    required this.date,
  });

  @override
  State<ExecutiveTracking> createState() => _ExecutiveTrackingState();
}

class _ExecutiveTrackingState extends State<ExecutiveTracking> {
  static const int _arrowSize = 60; // unified size for all route arrows

  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  Timer? _pollTimer;

  bool _isMapReady = false;
  List<LocationStays>? _pendingStays;

  // keep last successful API response to avoid blank UI during interval loads
  ExecutiveTrackingByDaysResponse? _lastResponse;
  bool _hasLoadedOnce = false; // used to keep rendering map even if state not Loaded yet
  bool _hasFittedCameraOnce = false; // ensure _updateCamera runs only once, on first data load

  // Cache to prevent rebuilding route if data hasn't changed
  String? _lastStaysHash;
  List<LatLng>? _cachedRoadPoints;

  // cache for arrow bitmaps keyed by rounded angle
  final Map<int, BitmapDescriptor> _arrowBitmapCache = {};
  BitmapDescriptor? _pinBitmap;
  // 🇮🇳 India default
  static const LatLng indiaLatLng = LatLng(20.5937, 78.9629);

  @override
  void initState() {
    super.initState();
    // initial load with loader
    context.read<ExecutiveTrackingBloc>().add(
      FetchExecutiveTracking(
        date: widget.date,
        userId: widget.userId,
        showLoader: true,
      ),
    );

    // start polling every 1 minute, subsequent loads without loader
    _pollTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      context.read<ExecutiveTrackingBloc>().add(
        FetchExecutiveTracking(
          date: widget.date,
          userId: widget.userId,
          showLoader: false,
        ),
      );
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  // ================= MAP CREATED =================
  Future<void> _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    _isMapReady = true;
    await _loadPinBitmap();
    // If API already returned, plot now
    if (_pendingStays != null) {
      _setMarkers(_pendingStays);
    }
  }

  // 3) new helper to load asset into BitmapDescriptor
  Future<void> _loadPinBitmap() async {
    try {
      // choose a sensible size for the rasterized asset
      final config = createLocalImageConfiguration(context, size: const Size(24, 24));
      final bmp = await BitmapDescriptor.asset(config, 'assets/images/pin-map.png');
      setState(() {
        _pinBitmap = bmp;
      });
    } catch (e) {
      // silently fail and fallback to default marker; optionally log
      // debugPrint('Failed to load pin-map asset: $e');
    }
  }

  String _formatDateTimeToIST(String? value) {
    if (value == null || value.isEmpty) return '--';
    try {
      // parse ISO (assumed UTC), convert to IST (+5:30) and format
      final dtUtc = DateTime.parse(value).toUtc();
      final dtIst = dtUtc.add(const Duration(hours: 5, minutes: 30));
      return DateFormat('dd/MM/yy hh:mm a').format(dtIst);
    } catch (e) {
      // fallback to previous behavior
      final parts = value.split(' ');
      return parts.length >= 2 ? '${parts[0]}\n${parts[1]}' : value;
    }
  }
  // ================= MARKERS & POLYLINES =================

  // Decode Google's encoded polyline into List<LatLng>
  List<LatLng> _decodePolyline(String encoded) {
    int index = 0, lat = 0, lng = 0;
    final List<LatLng> polyline = [];

    while (index < encoded.length) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      polyline.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return polyline;
  }

  // 3) Build a full-day road-snapped route from your stays (OPTIMIZED - uses waypoints)
  Future<List<LatLng>> _buildRoadRouteFromStays(List<LocationStays> stays) async {
    final filtered = stays
        .where((s) => s.lat != null && s.lng != null)
        .toList();

    if (filtered.length < 2) {
      return filtered
          .map((s) => LatLng(s.lat!, s.lng!))
          .toList();
    }

    // For better performance, use waypoints API with all intermediate points
    // This makes ONE API call instead of N calls
    try {
      const apiKey = 'AIzaSyDEcU3c1B0K-hLPliKjwZnCKlTNDLVxv-0';

      final origin = LatLng(filtered.first.lat!, filtered.first.lng!);
      final destination = LatLng(filtered.last.lat!, filtered.last.lng!);

      // Build waypoints string for intermediate points (max 25 waypoints for free tier)
      final waypoints = <String>[];
      final maxWaypoints = filtered.length > 27 ? 25 : filtered.length - 2;

      if (filtered.length > 2) {
        // Sample waypoints evenly if we have too many
        final step = filtered.length > 27 ? (filtered.length - 2) / 25 : 1;
        for (int i = 1; i < filtered.length - 1; i++) {
          if (waypoints.length >= maxWaypoints) break;
          if (i % step.ceil() == 0 || step == 1) {
            waypoints.add('${filtered[i].lat},${filtered[i].lng}');
          }
        }
      }

      final waypointsParam = waypoints.isEmpty ? '' : '&waypoints=${waypoints.join('|')}';

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '$waypointsParam'
        '&mode=driving'
        '&key=$apiKey',
      );

      print('🗺️ Fetching optimized route with ${waypoints.length} waypoints...');

      final res = await http.get(url);
      if (res.statusCode != 200) {
        print('❌ API failed with status ${res.statusCode}');
        // Fallback to straight lines
        return filtered.map((s) => LatLng(s.lat!, s.lng!)).toList();
      }

      final data = jsonDecode(res.body);
      final routes = data['routes'] as List?;
      if (routes == null || routes.isEmpty) {
        print('❌ No routes found');
        return filtered.map((s) => LatLng(s.lat!, s.lng!)).toList();
      }

      final overview = routes[0]['overview_polyline']['points'] as String;
      final roadPoints = _decodePolyline(overview);

      print('✅ Road route loaded: ${roadPoints.length} points');
      return roadPoints;

    } catch (e) {
      print('❌ Error building road route: $e');
      // Fallback to straight lines between points
      return filtered.map((s) => LatLng(s.lat!, s.lng!)).toList();
    }
  }

  // 4) Updated _setMarkers with road-based routing and 5+ min filter for markers
  Future<void> _setMarkers(List<LocationStays>? stays) async {
    // If no stays, keep existing markers/polylines so map doesn't go blank
    if (stays == null || stays.isEmpty) {
      return;
    }

    // Create a simple hash to detect if data actually changed
    final currentHash = stays.map((s) => '${s.lat}_${s.lng}_${s.stayDurationSeconds}').join(',');

    // If data hasn't changed, don't rebuild (prevents flicker during interval updates)
    if (_lastStaysHash == currentHash && _markers.isNotEmpty) {
      print('📍 Data unchanged, skipping rebuild');
      return;
    }

    print('🔄 Data changed, rebuilding route...');
    _lastStaysHash = currentHash;

    // Create markers ONLY for stays with duration >= 5 minutes
    final List<Marker> newMarkers = [];
    for (int i = 0; i < stays.length; i++) {
      final stay = stays[i];
      if (stay.lat != null && stay.lng != null) {
        final durationMinutes = (stay.stayDurationSeconds ?? 0) ~/ 60;

        // Only show marker if stay duration is 5 minutes or more
        if (durationMinutes >= 5) {
          final pos = LatLng(stay.lat!, stay.lng!);
          newMarkers.add(
            Marker(
              markerId: MarkerId('${stay.sessionId}_$i'),
              position: pos,
              icon: _pinBitmap ?? BitmapDescriptor.defaultMarker,
              infoWindow: InfoWindow(
                title: "${_formatDateTimeToIST(stay.stayLastPingAt)} • $durationMinutes min",
              ),
            ),
          );
        }
      }
    }

    // Build road-based polyline points (uses cached route if available)
    final roadPoints = _cachedRoadPoints ?? await _buildRoadRouteFromStays(stays);
    _cachedRoadPoints = roadPoints; // cache for next time

    if (roadPoints.length >= 2) {
      final polyline = Polyline(
        polylineId: const PolylineId('route'),
        points: roadPoints, // follows roads now
        color: const Color(0xFF4A6CF7),
        width: 5,
      );

      // create arrow markers along the road-based route
      final arrows = await _createArrowMarkers(roadPoints);

      // create a center arrow to show overall direction
      final centerIndex = (roadPoints.length / 2).floor();
      LatLng centerPos;
      double centerRotation;
      if (roadPoints.length % 2 == 0 && centerIndex > 0) {
        final a = roadPoints[centerIndex - 1];
        final b = roadPoints[centerIndex];
        centerPos = LatLng(
          (a.latitude + b.latitude) / 2,
          (a.longitude + b.longitude) / 2,
        );
        centerRotation = _computeBearing(a, b);
      } else {
        centerPos = roadPoints[centerIndex];
        if (centerIndex > 0) {
          centerRotation = _computeBearing(
            roadPoints[centerIndex - 1],
            roadPoints[centerIndex],
          );
        } else {
          centerRotation = _computeBearing(
            roadPoints.first,
            roadPoints.last,
          );
        }
      }

      final centerBmp = await _createArrowBitmapDescriptor(centerRotation, size: _arrowSize);
      final centerArrow = Marker(
        markerId: const MarkerId('center_arrow'),
        position: centerPos,
        anchor: const Offset(0.5, 0.5),
        icon: centerBmp,
        infoWindow: InfoWindow.noText,
      );

      setState(() {
        _markers.clear();
        _polylines.clear();
        _polylines.add(polyline);
        _markers.addAll(newMarkers);
        _markers.addAll(arrows);
        _markers.add(centerArrow);
      });
    } else {
      setState(() {
        _markers.clear();
        _markers.addAll(newMarkers);
      });
    }

    // Only auto-fit camera once, on the very first successful data load
    if (_isMapReady && !_hasFittedCameraOnce) {
      _hasFittedCameraOnce = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print('map update called (first load)');
        _updateCamera(stays);
      });
    }
  }

  // create small rotated arrow markers along the path to show direction
  Future<Set<Marker>> _createArrowMarkers(List<LatLng> points) async {
    final Set<Marker> arrows = {};

    // Place arrows at midpoints of segments; to reduce clutter place every 2nd segment if many points
    final step = (points.length > 12) ? 2 : 1;

    for (int i = 0; i < points.length - 1; i += step) {
      final a = points[i];
      final b = points[i + 1];
      final midLat = (a.latitude + b.latitude) / 2;
      final midLng = (a.longitude + b.longitude) / 2;

      final rotation = _computeBearing(a, b);
      final int key = rotation.round();

      BitmapDescriptor? bmp = _arrowBitmapCache[key];
      if (bmp == null) {
        bmp = await _createArrowBitmapDescriptor(rotation);
        _arrowBitmapCache[key] = bmp;
      }

      arrows.add(Marker(
        markerId: MarkerId('arrow_$i'),
        position: LatLng(midLat, midLng),
        anchor: const Offset(0.5, 0.5),
        icon: bmp,
        infoWindow: InfoWindow.noText,
      ));
    }

    return arrows;
  }

  // draws a small arrow bitmap rotated by rotationDegrees and returns BitmapDescriptor
  Future<BitmapDescriptor> _createArrowBitmapDescriptor(double rotationDegrees, {int size = _arrowSize}) async {
    // round rotation to integer to reuse cache
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final paint = ui.Paint()..color = const ui.Color(0xFFEF4444);

    final center = size / 2;

    canvas.translate(center, center);
    canvas.rotate((rotationDegrees) * math.pi / 180);

    // draw a simple arrow (triangle) pointing up from center
    final path = ui.Path();
    // scale the arrow triangle relative to the requested size so
    // when we bump size up the arrow visibly grows
    path.moveTo(0, -(size * 0.22));
    path.lineTo(size * 0.14, size * 0.10);
    path.lineTo(-size * 0.14, size * 0.10);
    path.close();

    canvas.drawPath(path, paint);

    // optional shaft
    final shaftPaint = ui.Paint()
      ..color = const ui.Color(0xFFEF4444)
      ..strokeWidth = size * 0.06
      ..strokeCap = ui.StrokeCap.round;
    canvas.drawLine(ui.Offset(0, size * 0.12), ui.Offset(0, size * 0.30), shaftPaint);

    final picture = recorder.endRecording();
    final img = await picture.toImage(size, size);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();
    return BitmapDescriptor.fromBytes(bytes);

  }

  // compute bearing between two LatLng points (degrees)
  double _computeBearing(LatLng from, LatLng to) {
    final lat1 = _degToRad(from.latitude);
    final lon1 = _degToRad(from.longitude);
    final lat2 = _degToRad(to.latitude);
    final lon2 = _degToRad(to.longitude);

    final dLon = lon2 - lon1;
    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    final brng = math.atan2(y, x);
    var bearing = (_radToDeg(brng) + 360) % 360;
    return bearing;
  }

  double _degToRad(double deg) => deg * (math.pi / 180.0);
  double _radToDeg(double rad) => rad * (180.0 / math.pi);

  // ================= CAMERA =================
  void _updateCamera(List<LocationStays>? stays) {
    if (_mapController == null) return;

    // 🇮🇳 No data → India
    if (stays == null || stays.isEmpty) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          const CameraPosition(
            target: indiaLatLng,
            zoom: 5,
          ),
        ),
      );
      return;
    }

    // 📍 Single marker
    if (stays.length == 1 &&
        stays.first.lat != null &&
        stays.first.lng != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(stays.first.lat!, stays.first.lng!),
          16,
        ),
      );
      return;
    }

    // 📦 Multiple markers → bounds
    double minLat = stays.first.lat!;
    double maxLat = stays.first.lat!;
    double minLng = stays.first.lng!;
    double maxLng = stays.first.lng!;

    for (final s in stays) {
      if (s.lat == null || s.lng == null) continue;
      minLat = minLat < s.lat! ? minLat : s.lat!;
      maxLat = maxLat > s.lat! ? maxLat : s.lat!;
      minLng = minLng < s.lng! ? minLng : s.lng!;
      maxLng = maxLng > s.lng! ? maxLng : s.lng!;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 20),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Executive Tracking',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient:SessionManager.getUserRole().toString().toLowerCase() =="superadmin" ?AppColors.superAdminGradient:  const LinearGradient(
              colors: [Color(0xFF4A6CF7), Color(0xFF6E8BFF)],
            ),
          ),
        ),
      ),
      body: BlocConsumer<ExecutiveTrackingBloc, ExecutiveTrackingState>(
        listener: (context, state) {
          if (state is ExecutiveTrackingLoaded) {
            _lastResponse = state.response;
            _pendingStays = state.response.data?.locationStays;
            _hasLoadedOnce = true;

            if (_isMapReady) {
              _setMarkers(_pendingStays);
            }
          }
        },
        builder: (context, state) {
          // show loader only on first load when showLoader true; after we've
          // loaded once, keep showing existing UI even if a new interval load is running
          if (!_hasLoadedOnce && state is ExecutiveTrackingLoading && state.showLoader) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ExecutiveTrackingError) {
            return Center(child: Text(state.message));
          }

          // After first successful load, always render using _lastResponse to
          // avoid blank UI between interval states.
          if (_hasLoadedOnce && _lastResponse != null) {
            final data = _lastResponse!.data;

            return Column(
              children: [
                // ================= MAP =================
                SizedBox(
                  height: height * 0.65,
                  child: Stack(
                    children: [
                      GoogleMap(
                        mapToolbarEnabled: false,
                        onMapCreated: _onMapCreated,
                        compassEnabled: false,
                        myLocationEnabled: false,
                        markers: _markers,
                        polylines: _polylines,
                        initialCameraPosition: const CameraPosition(
                          target: indiaLatLng,
                          zoom: 5,
                        ),
                      ),

                      // ===== TOP SUMMARY =====
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _timeInfo(
                                'First Ping',
                                _formatDateTime(
                                    data?.firstPingAtDisplay),
                                Icons.play_arrow,
                              ),
                              _timeInfo(
                                'Last Ping',
                                _formatDateTime(
                                    data?.lastPingAtDisplay),
                                Icons.stop,
                              ),
                              _timeInfo(
                                'Pings',
                                '${data?.totalPingCount ?? 0}',
                                Icons.timeline,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ================= SESSIONS =================
            Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(top: 6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 10),
                      ],
                    ),
                    child: (data?.sessions?.isEmpty ?? true)
                        ? const Center(
                            child: Text(
                              "No Sessions To Show !",
                              style: TextStyle(color: AppColors.black),
                            ),
                          )
                        : Builder(
                            builder: (context) {
                              final sessions = data!.sessions!;
                              return ListView.builder(
                                itemCount: sessions.length,
                                itemBuilder: (context, index) {
                                  final session = sessions[index];
                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF7F9FC),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.work_outline,
                                          color: SessionManager.getUserRole().toString().toLowerCase() == "superadmin"
                                              ? AppColors.superAdminPrimary
                                              : const Color(0xFF4A6CF7),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Session ${session.sessionId?.substring(0, 6)}',
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              Text(
                                                'Work: ${session.workMinutes ?? 0} mins',
                                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              session.punchedInAtDisplay ?? '--',
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                            ),
                                            if (session.punchedOutAt != null)
                                              Text(
                                                session.punchedOutAtDisplay ?? '--',
                                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ),
              ],
            );
          }

          // Before first load completes, show nothing (or could show a small loader)
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ================= HELPERS =================
  String _formatDateTime(String? value) {
    if (value == null || value.isEmpty) return '--';
    final parts = value.split(' ');
    return parts.length >= 2 ? '${parts[0]}\n${parts[1]}' : value;
  }

  Widget _timeInfo(String title, String value, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: SessionManager.getUserRole().toString().toLowerCase() =="superadmin" ?AppColors.superAdminPrimary: const Color(0xFF4A6CF7), size: 18),
            const SizedBox(width: 4),
            Text(title,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style:
          const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }
}
