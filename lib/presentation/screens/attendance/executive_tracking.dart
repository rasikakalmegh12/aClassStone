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

  bool _isMapReady = false;
  List<LocationStays>? _pendingStays;

  // 🇮🇳 India default
  static const LatLng indiaLatLng = LatLng(20.5937, 78.9629);

  @override
  void initState() {
    super.initState();
    context.read<ExecutiveTrackingBloc>().add(
      FetchExecutiveTracking(
        date: widget.date,
        userId: widget.userId,
      ),
    );
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

  // ================= MARKERS =================
  void _setMarkers(List<LocationStays>? stays) {
    setState(() {
      _markers.clear();

      if (stays == null || stays.isEmpty) return;

      for (int i = 0; i < stays.length; i++) {
        final stay = stays[i];

        if (stay.lat != null && stay.lng != null) {
          _markers.add(
            Marker(
              markerId: MarkerId(
                '${stay.sessionId}_$i', // ✅ UNIQUE ID
              ),
              position: LatLng(stay.lat!, stay.lng!),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure,
              ),
              infoWindow: InfoWindow(
                title:
                "Ping ${i + 1} • ${(stay.stayDurationSeconds ?? 0) ~/ 60} min",
              ),
            ),
          );
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCamera(stays);
    });
  }

  // void _setMarkers(List<LocationStays>? stays) {
  //   setState(() {
  //     _markers.clear();
  //
  //     if (stays == null || stays.isEmpty) return;
  //
  //     for (var stay in stays) {
  //       if (stay.lat != null && stay.lng != null) {
  //         _markers.add(
  //           Marker(
  //             markerId: MarkerId(
  //               stay.sessionId ?? '${stay.lat}-${stay.lng}',
  //             ),
  //             position: LatLng(stay.lat!, stay.lng!),
  //             icon: BitmapDescriptor.defaultMarkerWithHue(
  //               BitmapDescriptor.hueAzure,
  //             ),
  //             infoWindow: InfoWindow(
  //               title:
  //               "Work Time: ${(stay.stayDurationSeconds ?? 0) ~/ 60} min",
  //             ),
  //           ),
  //         );
  //       }
  //     }
  //   });
  //
  //   // Zoom AFTER markers render
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     _updateCamera(stays);
  //   });
  // }

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
            return const Center(child: CircularProgressIndicator());
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
