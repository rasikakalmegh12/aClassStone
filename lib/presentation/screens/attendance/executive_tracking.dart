import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:apclassstone/core/constants/app_colors.dart';
import 'package:apclassstone/core/session/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  Timer? _pollTimer;

  bool _isMapReady = false;
  List<LocationStays>? _pendingStays;

  // cache for arrow bitmaps keyed by rounded angle
  final Map<int, BitmapDescriptor> _arrowBitmapCache = {};

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
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _isMapReady = true;

    // If API already returned, plot now
    if (_pendingStays != null) {
      _setMarkers(_pendingStays);
    }
  }

  // ================= MARKERS & POLYLINES =================
  void _setMarkers(List<LocationStays>? stays) async {
    setState(() {
      _markers.clear();
      _polylines.clear();

      if (stays == null || stays.isEmpty) return;

    });

    // build points and markers outside setState for async arrow creation
    List<LatLng> points = [];
    final List<Marker> newMarkers = [];

    for (int i = 0; i < (stays ?? []).length; i++) {
      final stay = stays![i];
      if (stay.lat != null && stay.lng != null) {
        final pos = LatLng(stay.lat!, stay.lng!);
        points.add(pos);

        newMarkers.add(
          Marker(
            markerId: MarkerId('${stay.sessionId}_$i'),
            position: pos,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            infoWindow: InfoWindow(
              title: "Ping ${i + 1} • ${(stay.stayDurationSeconds ?? 0) ~/ 60} min",
            ),
          ),
        );
      }
    }

    // create polyline
    if (points.length >= 2) {
      final polyId = PolylineId('route');
      final polyline = Polyline(
        polylineId: polyId,
        points: points,
        color: const Color(0xFF4A6CF7),
        width: 5,
      );

      // create arrow markers asynchronously
      final arrows = await _createArrowMarkers(points);

      // create a center arrow to show overall direction
      final centerIndex = (points.length / 2).floor();
      LatLng centerPos;
      double centerRotation;
      if (points.length % 2 == 0 && centerIndex > 0) {
        // midpoint between centerIndex-1 and centerIndex
        final a = points[centerIndex - 1];
        final b = points[centerIndex];
        centerPos = LatLng((a.latitude + b.latitude) / 2, (a.longitude + b.longitude) / 2);
        centerRotation = _computeBearing(a, b);
      } else {
        // use exact center point
        centerPos = points[centerIndex];
        // compute bearing from previous point if available else from first->last
        if (centerIndex > 0) {
          centerRotation = _computeBearing(points[centerIndex - 1], points[centerIndex]);
        } else {
          centerRotation = _computeBearing(points.first, points.last);
        }
      }

      final centerBmp = await _createArrowBitmapDescriptor(centerRotation, size: 64);
      final centerArrow = Marker(
        markerId: const MarkerId('center_arrow'),
        position: centerPos,
        anchor: const Offset(0.5, 0.5),
        icon: centerBmp,
        infoWindow: InfoWindow.noText,
      );

      setState(() {
        _polylines.add(polyline);
        _markers.addAll(newMarkers);
        _markers.addAll(arrows);
        _markers.add(centerArrow);
      });
    } else {
      setState(() {
        _markers.addAll(newMarkers);
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCamera(stays);
    });
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
  Future<BitmapDescriptor> _createArrowBitmapDescriptor(double rotationDegrees, {int size = 48}) async {
    // round rotation to integer to reuse cache
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final paint = ui.Paint()..color = const ui.Color(0xFFEF4444);

    final center = size / 3;

    canvas.translate(center, center);
    canvas.rotate((rotationDegrees) * math.pi / 180);

    // draw a simple arrow (triangle) pointing up from center
    final path = ui.Path();
    path.moveTo(0, - (size * 0.18));
    path.lineTo(size * 0.12, size * 0.12);
    path.lineTo(-size * 0.12, size * 0.12);
    path.close();

    canvas.drawPath(path, paint);

    // optional shaft
    final shaftPaint = ui.Paint()
      ..color = const ui.Color(0xFFEF4444)
      ..strokeWidth = size * 0.05
      ..strokeCap = ui.StrokeCap.round;
    canvas.drawLine(ui.Offset(0, size * 0.12), ui.Offset(0, size * 0.28), shaftPaint);

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
      CameraUpdate.newLatLngBounds(bounds, 80),
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
            gradient:SessionManager.getUserRole().toString().toLowerCase() =="superadmin" ?AppColors.primaryGradient:  const LinearGradient(
              colors: [Color(0xFF4A6CF7), Color(0xFF6E8BFF)],
            ),
          ),
        ),
      ),
      body: BlocConsumer<ExecutiveTrackingBloc, ExecutiveTrackingState>(
        listener: (context, state) {
          if (state is ExecutiveTrackingLoaded) {
            _pendingStays = state.response?.data?.locationStays;

            if (_isMapReady) {
              _setMarkers(_pendingStays);
            }
          }
        },
        builder: (context, state) {
          if (state is ExecutiveTrackingLoading) {
            // show loader only on first load when showLoader true
            if (state.showLoader) {
              return const Center(child: CircularProgressIndicator());
            }
          }

          if (state is ExecutiveTrackingError) {
            return Center(child: Text(state.message));
          }

          if (state is ExecutiveTrackingLoaded) {
            final data = state.response?.data;

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
                                              ? AppColors.primaryGold
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

          return const SizedBox();
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
            Icon(icon, color: SessionManager.getUserRole().toString().toLowerCase() =="superadmin" ?AppColors.primaryGold: const Color(0xFF4A6CF7), size: 18),
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
