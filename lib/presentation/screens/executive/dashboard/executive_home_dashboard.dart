import 'dart:async';

import 'package:apclassstone/core/session/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:apclassstone/api/models/request/PunchInOutRequestBody.dart';
import 'package:apclassstone/core/services/repository_provider.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../bloc/attendance/attendance_bloc.dart';
import '../../../../bloc/attendance/attendance_event.dart';
import '../../../../bloc/attendance/attendance_state.dart';
import '../../../../core/constants/app_colors.dart';

import '../../auth/login_screen.dart';
import '../clients/clients_list_screen.dart';
import '../meetings/meetings_list_screen.dart';
import '../work_plans/work_plans_list_screen.dart';
import '../leads/leads_list_screen.dart';

class ExecutiveHomeDashboard extends StatefulWidget {
  final String user;

  const ExecutiveHomeDashboard({
    super.key,
    required this.user,
  });

  @override
  State<ExecutiveHomeDashboard> createState() => _ExecutiveHomeDashboardState();
}

class _ExecutiveHomeDashboardState extends State<ExecutiveHomeDashboard> {
  bool isLoading = false;
  bool isPunchedIn = false;
  String? punchInTime;
  bool isPunching = false; // new: disables repeated taps while processing
  Timer? _pingTimer; // periodic timer for location pings
  String currentCity = "Jaipur";
  int plannedVisits = 5;
  int meetingsLogged = 2;
  int leadsCreated = 1;
  int pendingMoms = 3;
  int followUpsDue = 4;
  int leadsClosingSoon = 2;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isPunchedIn = SessionManager.isPunchedInSync();

    final storedTime = SessionManager.getPunchInTimeSync();
    if (storedTime != null) {
      // punchInTime = DateTime.tryParse(storedTime);
      punchInTime = storedTime;
    }

    if (isPunchedIn) {
      _startPingTimer(SessionManager.getUserIdSync() ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: MultiBlocListener(
        listeners: [
          BlocListener<LocationPingBloc, LocationPingState>(
            listener: (context, state) {
              if (state is LocationPingLoaded) {
                debugPrint('Location ping success');
              }

              if (state is LocationPingError) {
                debugPrint('Location ping error: ${state.message}');
              }
            },
          ),

          BlocListener<PunchInBloc, PunchInState>(
            listener: (context, state) async {
              if(state is PunchInLoading){
                setState(() {
                  isLoading = true;
                });
              } else {
                setState(() {
                  isLoading = false;
                });
              }
              if (state is PunchInLoaded) {
                await SessionManager.setPunchIn(
                  isPunchedIn: true,
                  punchInTime: state.response.data?.punchedInAtDisplay ?? '',
                );
                setState(() {
                  isPunchedIn = true;
                  punchInTime = state.response.data?.punchedInAtDisplay ?? '';

                });
                _startPingTimer(SessionManager.getUserNameSync() ?? '');
                _showSuccessMessage('Punched in successfully');
              }

              if (state is PunchInError) {
                _showSuccessMessage(state.message);
              }
            },
          ),

          BlocListener<PunchOutBloc, PunchOutState>(
            listener: (context, state) async {
              if(state is PunchOutLoading){
                setState(() {
                  isLoading = true;
                });
              } else {
                setState(() {
                  isLoading = false;
                });
              }
              if (state is PunchOutLoaded) {
                await SessionManager.setPunchIn(
                  isPunchedIn: false,
                  punchInTime: state.response.data?.punchedOutAtDisplay ?? '',
                );
                setState(() {
                  isPunchedIn = false;
                  punchInTime = null;
                });
                _stopPingTimer();
                _showSuccessMessage('Punched out successfully');
              }

              if (state is PunchOutError) {
                _showSuccessMessage(state.message);
              }
            },
          ),

        ],
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildAttendanceCard(),
                      const SizedBox(height: 16),
                      _buildTodaySummaryCard(),
                      const SizedBox(height: 16),
                      _buildActionFeedCard(),
                      const SizedBox(height: 16),
                      _buildQuickActionsCard(),
                      const SizedBox(height: 80), // Space for bottom nav
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    final formattedDate = DateFormat('EEE, dd MMM yyyy').format(now);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryTeal,
            AppColors.primaryTeal.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.diamond_outlined,
                  color: AppColors.primaryTeal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: (){
                    context.pushNamed("profile");
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${SessionManager.getUserNameSync()}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                             Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.15 * 255).toInt()),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withAlpha((0.2 * 255).toInt()),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  onPressed: () => _showLogoutDialog(),
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),

        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.5, end: 0);
  }

  Widget _buildAttendanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ATTENDANCE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (isPunchedIn) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                isPunchedIn ? 'PUNCHED IN' : 'PUNCHED OUT',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isPunchedIn ? AppColors.success : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (isPunchedIn && punchInTime != null) ...[
            const SizedBox(height: 4),
            Text(
              // 'Tracking since ${_formatTime(punchInTime!)}',
              'Tracking since ${punchInTime!}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textLight,
              ),
            ),
          ],
          const SizedBox(height: 16),
    // BlocBuilder<PunchInBloc, PunchInState>(
    // builder: (context, punchInState) {
    // return BlocBuilder<PunchOutBloc, PunchOutState>(
    // builder: (context, punchOutState) {
    //
    // final bool isLoading =
    // punchInState is PunchInLoading ||
    // punchOutState is PunchOutLoading;
    //
    // return SizedBox(
    // width: double.infinity,
    // child: ElevatedButton(
    // onPressed: isLoading ? null : _handlePunchAction,
    // style: ElevatedButton.styleFrom(
    // backgroundColor: AppColors.primaryTeal,
    // foregroundColor: AppColors.white,
    // padding: const EdgeInsets.symmetric(vertical: 12),
    // shape: RoundedRectangleBorder(
    // borderRadius: BorderRadius.circular(8),
    // ),
    // ),
    // child: isLoading
    // ? const SizedBox(
    // height: 20,
    // width: 20,
    // child: CircularProgressIndicator(
    // strokeWidth: 2,
    // color: Colors.white,
    // ),
    // )
    //     : Text(
    // isPunchedIn ? 'Punch Out' : 'Punch In',
    // style: const TextStyle(
    // fontSize: 14,
    // fontWeight: FontWeight.w600,
    // ),
    // ),
    // ),
    // );
    // },
    // );
    // },
    // ),

    SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handlePunchAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: isLoading ?
              const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
                ),
                ):
              Text(
                isPunchedIn ? 'Punch Out' : 'Punch In',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (!isPunchedIn) ...[
            const SizedBox(height: 8),
            const Text(
              'Punch in to start tracking',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textLight,
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.3, end: 0);
  }

  Widget _buildTodaySummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TODAY SUMMARY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'City: $currentCity',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildSummaryItem('Planned visits', plannedVisits),
          _buildSummaryItem('Meetings logged', meetingsLogged),
          _buildSummaryItem('Leads created', leadsCreated),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WorkPlansListScreen()),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryTeal,
              side: const BorderSide(color: AppColors.primaryTeal),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View Work Plan',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, size: 12),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.3, end: 0);
  }

  Widget _buildSummaryItem(String label, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: $count',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionFeedCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ACTION FEED',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16),
          _buildActionFeedItem(
            title: 'Pending MOM submissions ($pendingMoms)',
            subtitle: 'Complete your pending MOMs',
            icon: Icons.assignment_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MeetingsListScreen()),
              );
            },
          ),
          _buildActionFeedItem(
            title: 'Work plan approval',
            subtitle: '15 Dec · Status: Pending',
            icon: Icons.schedule_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WorkPlansListScreen()),
              );
            },
          ),
          _buildActionFeedItem(
            title: 'Follow-ups due today ($followUpsDue)',
            subtitle: 'View follow-up meetings',
            icon: Icons.event_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MeetingsListScreen()),
              );
            },
          ),
          _buildActionFeedItem(
            title: 'Lead reminders',
            subtitle: '$leadsClosingSoon leads close in next 3 days',
            icon: Icons.notifications_outlined,
            isLast: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LeadsListScreen()),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildActionFeedItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: isLast ? null : const Border(
            bottom: BorderSide(
              color: AppColors.grey100,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: AppColors.primaryTeal,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: AppColors.grey400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'QUICK ACTIONS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  label: 'Log MOM',
                  icon: Icons.assignment_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MeetingsListScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  label: 'Work Plan',
                  icon: Icons.calendar_today_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const WorkPlansListScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  label: 'Leads',
                  icon: Icons.star_outline,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LeadsListScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  label: 'Clients',
                  icon: Icons.person_outline,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ClientsListScreen()),
                      // MaterialPageRoute(builder: (context) => const TemporaryPlaceholderScreen(screenName: 'Clients')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  label: 'More',
                  icon: Icons.more_horiz,
                  onTap: () {
                    // Show more options
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildQuickActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: AppColors.primaryTeal,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.grey200,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem('Home', Icons.home_outlined, true),
              _buildNavItem('Meetings', Icons.group_outlined, false),
              _buildNavItem('Leads', Icons.star_outline, false),
              _buildNavItem('Clients', Icons.person_outline, false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String label, IconData icon, bool isActive) {
    return GestureDetector(
      onTap: () {
        if (label == 'Meetings') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MeetingsListScreen()),
          );
        } else if (label == 'Leads') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LeadsListScreen()),
          );
        } else if (label == 'Clients') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ClientsListScreen()),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: isActive ? AppColors.primaryTeal : AppColors.grey400,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isActive ? AppColors.primaryTeal : AppColors.grey400,
            ),
          ),
        ],
      ),
    );
  }

  // void _handlePunchAction1() async {
  //   if (isPunching) return; // prevent re-entrancy
  //   setState(() {
  //     isPunching = true;
  //   });
  //
  //   double? lat;
  //   double? lng;
  //   int? accuracyM;
  //
  //   // Request permission and get location
  //   try {
  //     LocationPermission permission = await Geolocator.checkPermission();
  //     if (permission == LocationPermission.denied) {
  //       permission = await Geolocator.requestPermission();
  //     }
  //
  //     if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
  //       // Permission denied - we continue but without location
  //       _showSuccessMessage('Location permission denied - punch will be saved without location');
  //     } else {
  //       final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
  //       lat = pos.latitude;
  //       lng = pos.longitude;
  //       accuracyM = pos.accuracy.toInt();
  //     }
  //   } catch (e) {
  //     // Could not get location (service disabled or other). Continue without location but notify.
  //     _showSuccessMessage('Could not get location: ${e.toString()} - punch will be saved without location');
  //   }
  //
  //   try {
  //     final userId = SessionManager.getUserIdSync()?.toString() ?? '';
  //     final capturedAt = DateTime.now().toUtc().toIso8601String();
  //     final body = PunchInOutRequestBody(
  //       capturedAt: capturedAt,
  //       lat: lat,
  //       lng: lng,
  //       accuracyM: accuracyM,
  //       deviceId: '',
  //       deviceModel: '',
  //     );
  //
  //     if (isPunchedIn) {
  //
  //
  //
  //       // currently punched in -> punch out
  //       final record = await AppBlocProvider.punchRepository.punchOut(userId, body);
  //       // update UI regardless of online/offline — local record was created
  //       setState(() {
  //         isPunchedIn = false;
  //         punchInTime = null;
  //       });
  //
  //       if (record.status == 'success') {
  //         _showSuccessMessage('Punched out successfully!');
  //         _stopPingTimer(); // stop periodic pings when punched out
  //       } else if (record.status == 'failed') {
  //         _showSuccessMessage('Punch-out saved locally (failed to sync): ${record.errorMessage ?? ''}');
  //       } else {
  //         _showSuccessMessage('Punch-out queued (will sync when online)');
  //       }
  //     } else {
  //       // currently punched out -> punch in
  //       final record = await AppBlocProvider.punchRepository.punchIn(userId, body);
  //
  //       setState(() {
  //         isPunchedIn = true;
  //         try {
  //           punchInTime = DateTime.parse(record.capturedAt);
  //         } catch (_) {
  //           punchInTime = DateTime.now();
  //         }
  //       });
  //
  //       if (record.status == 'success') {
  //         _showSuccessMessage('Punched in successfully!');
  //         _startPingTimer(userId); // start location ping timer
  //       } else if (record.status == 'failed') {
  //         _showSuccessMessage('Punch-in saved locally (failed to sync): ${record.errorMessage ?? ''}');
  //       } else {
  //         _showSuccessMessage('Punch-in queued (will sync when online)');
  //       }
  //     }
  //   } catch (e) {
  //     // fallback: toggle state conservatively or keep previous state
  //     _showSuccessMessage('Failed to record punch: ${e.toString()}');
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         isPunching = false;
  //       });
  //     }
  //   }
  // }

  void _handlePunchAction() async {
    if (isPunching) return;

    setState(() => isPunching = true);

    double? lat;
    double? lng;
    int? accuracyM;

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showSuccessMessage(
            'Location permission denied - punch will be saved without location');
      } else {
        final pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best);
        lat = pos.latitude;
        lng = pos.longitude;
        accuracyM = pos.accuracy.toInt();
      }
    } catch (e) {
      _showSuccessMessage(
          'Could not get location - punch will be saved without location');
    }

    final userId = SessionManager.getUserIdSync()?.toString() ?? '';
    final body = PunchInOutRequestBody(
      capturedAt: DateTime.now().toUtc().toIso8601String(),
      lat: lat,
      lng: lng,
      accuracyM: accuracyM,
      deviceId: '',
      deviceModel: '',
    );

    if (isPunchedIn) {
      /// 👉 Punch OUT
      context.read<PunchOutBloc>().add(
        FetchPunchOut(body: body, id: userId),
      );
    } else {
      /// 👉 Punch IN
      context.read<PunchInBloc>().add(
        FetchPunchIn(body: body, id: userId),
      );
    }
  }


  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }


  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Confirm Logout',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1A365D),
            ),
          ),
          content: const Text(
            'Are you sure you want to logout from the admin portal?',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF718096),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF718096),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF56565), Color(0xFFE53E3E)],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: TextButton(
                onPressed: () {

                  // stop ongoing ping timer before logout/navigation
                  _stopPingTimer();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _pingTimer?.cancel();
    super.dispose();
  }

  void _startPingTimer1(String userId) {
    // cancel existing if any
    _pingTimer?.cancel();
    // every 3 minutes while punched in
    _pingTimer = Timer.periodic(const Duration(minutes: 3), (_) async {
      try {
        // capture current location
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        double? lat;
        double? lng;
        int? accuracyM;
        if (permission != LocationPermission.denied && permission != LocationPermission.deniedForever) {
          final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
          lat = pos.latitude;
          lng = pos.longitude;
          accuracyM = pos.accuracy.toInt();
        }

        final body = PunchInOutRequestBody(
          capturedAt: DateTime.now().toUtc().toIso8601String(),
          lat: lat,
          lng: lng,
          accuracyM: accuracyM,
        );

        // dispatch to LocationPingBloc to save locally
        // AppBlocProvider.locationPingBloc.add(PingLocation(userId: userId, body: body));
      } catch (e) {
        // ignore failures in timer ticks; they won't crash the app
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location ping failed: ${e.toString()}')),
          );
        }
      }
    });
  }


  void _startPingTimer(String userId) {
    // Cancel existing timer if any
    _pingTimer?.cancel();

    _pingTimer = Timer.periodic(
      const Duration(minutes: 1),
          (_) async {
        try {
          double? lat;
          double? lng;
          int? accuracyM;

          LocationPermission permission =
          await Geolocator.checkPermission();

          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }

          if (permission != LocationPermission.denied &&
              permission != LocationPermission.deniedForever) {
            final pos = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.best,
            );
            lat = pos.latitude;
            lng = pos.longitude;
            accuracyM = pos.accuracy.toInt();
          }

          final body = PunchInOutRequestBody(
            capturedAt: DateTime.now().toUtc().toIso8601String(),
            lat: lat,
            lng: lng,
            accuracyM: accuracyM,
            deviceId: '',
            deviceModel: '',
          );

          /// ✅ Dispatch Bloc event (THIS IS THE KEY CHANGE)
          context.read<LocationPingBloc>().add(
            FetchLocationPing(
              body: body,
              id: userId,
            ),
          );
        } catch (e) {
          // Silent failure: timer should never crash UI
          debugPrint('Location ping failed: $e');
        }
      },
    );
  }


  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }
}
