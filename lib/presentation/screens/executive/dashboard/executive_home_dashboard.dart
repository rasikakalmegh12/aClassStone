import 'dart:async';

import 'package:apclassstone/core/session/session_manager.dart';
import 'package:apclassstone/core/utils/battery_optimization_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:apclassstone/api/models/request/PunchInOutRequestBody.dart';
import 'package:apclassstone/core/services/repository_provider.dart';
import 'package:geolocator/geolocator.dart';


import '../../../../bloc/attendance/attendance_bloc.dart';
import '../../../../bloc/attendance/attendance_event.dart';
import '../../../../bloc/attendance/attendance_state.dart';
import '../../../../bloc/auth/auth_bloc.dart';
import '../../../../bloc/auth/auth_event.dart';
import '../../../../bloc/auth/auth_state.dart';
import '../../../../bloc/dashboard/dashboard_bloc.dart';
import '../../../../bloc/dashboard/dashboard_event.dart';
import '../../../../bloc/dashboard/dashboard_state.dart';
import '../../../../core/constants/app_colors.dart';

import '../../../../main.dart';
import '../../auth/login_screen.dart';
import '../../debug/log_viewer.dart';
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
  Timer? _autoPunchOutTimer; // Timer to check for auto punch-out at 11:30 PM

  String currentCity = "Jaipur";
  int plannedVisits = 5;
  int meetingsLogged = 2;
  int leadsCreated = 1;
  int pendingMoms = 3;
  int followUpsDue = 4;
  int leadsClosingSoon = 2;

  @override
  void initState() {
    super.initState();
    print("session refresh token ${SessionManager.getRefreshToken()}");

    // Call ActiveSessionBloc to check current session status
    context.read<ActiveSessionBloc>().add(FetchActiveSession());

    // Start timer to check for auto punch-out at 11:30 PM
    _startAutoPunchOutTimer();
  }

  Future<void> _startForegroundService() async {
    await FlutterForegroundTask.startService(
      notificationTitle: 'Attendance Tracking',
      notificationText: 'Location tracking active',
      callback: startCallback,
    );
  }

  void _startAutoPunchOutTimer() {
    // Cancel existing timer if any
    _autoPunchOutTimer?.cancel();

    // Check every minute if it's 11:30 PM
    _autoPunchOutTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final now = DateTime.now();

      // Check if it's 11:30 PM (23:30)
      if (now.hour == 23 && now.minute == 30 && isPunchedIn) {
        print('🕚 Auto punch-out triggered at 11:30 PM');
        await _performAutoPunchOut();
      }
    });

    print('✅ Auto punch-out timer started - will check every minute');
  }

  Future<void> _performAutoPunchOut() async {
    if (!isPunchedIn || isLoading) return;

    print('🔄 Performing auto punch-out...');

    double? lat;
    double? lng;
    int? accuracyM;

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever) {
        try {
          final pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            timeLimit: const Duration(seconds: 10),
          );
          lat = pos.latitude;
          lng = pos.longitude;
          accuracyM = pos.accuracy.toInt();
        } catch (e) {
          // Fallback to last known position
          final lastPos = await Geolocator.getLastKnownPosition();
          if (lastPos != null) {
            lat = lastPos.latitude;
            lng = lastPos.longitude;
            accuracyM = lastPos.accuracy.toInt();
          }
        }
      }
    } catch (e) {
      print('⚠️ Could not get location for auto punch-out: $e');
    }

    final userId = SessionManager.getUserId()?.toString() ?? '';
    final body = PunchInOutRequestBody(
      capturedAt: DateTime.now().toUtc().toIso8601String(),
      lat: lat,
      lng: lng,
      accuracyM: accuracyM,
      deviceId: '',
      deviceModel: '',
    );

    // Trigger punch out via Bloc
    context.read<PunchOutBloc>().add(
      FetchPunchOut(body: body, id: userId),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: MultiBlocListener(
        listeners: [
          BlocListener<ActiveSessionBloc, ActiveSessionState>(
            listener: (context, state) async {
              if (state is ActiveSessionLoaded) {
                // Check if there's an active session with PUNCHED_IN status
                if (state.response.data?.status == "PUNCHED_IN") {
                  await SessionManager.setPunchIn(true);
                  await SessionManager.setPunchInTime(
                    state.response.data?.punchedInAtDisplay ?? '',
                  );
                  setState(() {
                    isPunchedIn = true;
                    punchInTime = state.response.data?.punchedInAtDisplay ?? '';
                  });
                  print("Active session found - starting foreground service");
                  _startForegroundService();
                  _startAutoPunchOutTimer(); // Ensure timer is running
                } else {
                  // No active session or punched out
                  await SessionManager.setPunchIn(false);
                  setState(() {
                    isPunchedIn = false;
                    punchInTime = null;
                  });
                  print("No active session - punched out state");
                }
              } else if (state is ActiveSessionError) {
                // If error (e.g., no active session), set to punched out
                await SessionManager.setPunchIn(false);
                setState(() {
                  isPunchedIn = false;
                  punchInTime = null;
                });
                print("ActiveSession error: ${state.message} - setting to punched out");
              }
            },
          ),
          BlocListener<LocationPingBloc, LocationPingState>(
            listener: (context, state) {
              if (state is LocationPingLoaded) {
                _showSuccessMessage(state.response.message.toString());
                debugPrint('Location ping success');
              }

              if (state is LocationPingError) {
                _showSuccessMessage(state.message.toString());
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
                await SessionManager.setPunchIn(true);
                await SessionManager.setPunchInTime(state.response.data?.punchedInAtDisplay ?? '');
                setState(() {
                  isPunchedIn = true;
                  punchInTime = state.response.data?.punchedInAtDisplay ?? '';

                });
                await FlutterForegroundTask.startService(
                  notificationTitle: 'Attendance Tracking',
                  notificationText: 'Location tracking active',
                  callback: startCallback,
                );
                _startAutoPunchOutTimer(); // Start auto punch-out timer
                // _startPingTimer(SessionManager.getUserNameSync() ?? '');
                _showSuccessMessage('Punched in successfully');
              }

              if (state is PunchInError) {
                 print('PunchInError: ${state.message}');
                 if(state.message =="Already punched in"){
                   setState(() {
                     isPunchedIn = false;
                   });

                 }
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
                await SessionManager.setPunchIn(false,);
                setState(() {
                  isPunchedIn = false;
                  punchInTime = null;
                });
                await FlutterForegroundTask.stopService();
                _autoPunchOutTimer?.cancel(); // Cancel auto punch-out timer

                // _stopPingTimer();
                _showSuccessMessage('Punched out successfully');
              }

              if (state is PunchOutError) {
                if(state.message =="Not punched in"){
                  setState(() {
                    isPunchedIn = false;
                  });

                }
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
                      // const SizedBox(height: 16),
                      // _buildTodaySummaryCard(),
                      // const SizedBox(height: 16),
                      // _buildActionFeedCard(),
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
                              'Hello, ${SessionManager.getUserName()}',
                              style: const TextStyle(
                                fontSize: 18,
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
              const SizedBox(width: 5),
              Container(
                width: 37,
                height: 37,
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
                    size: 15,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LogViewerScreen()),
                  );
                },
                icon: const Icon(
                  Icons.bug_report,
                  color: Colors.white,
                  size: 16,
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
                  label: 'Catalogue',
                  icon: Icons.calendar_today_outlined,
                  onTap: () {
                    context.pushNamed("cataloguePage");
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => const WorkPlansListScreen()),
                    // );
                  },
                ),
              ),

              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  label: 'Log MOM',
                  icon: Icons.assignment_outlined,
                  onTap: () {
                    context.pushNamed("momDetailsScreen");
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => const MeetingsListScreen()),
                    // );
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
                    context.pushNamed("leadScreenList");
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => const LeadsListScreen()),
                    // );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  label: 'Clients',
                  icon: Icons.person_outline,
                  onTap: () {
                    context.pushNamed("clientsListScreen");
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => const ClientsListScreen()),
                    //   // MaterialPageRoute(builder: (context) => const TemporaryPlaceholderScreen(screenName: 'Clients')),
                    // );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  label: 'Work Plan',
                  icon: Icons.work_history_outlined,
                  onTap: () {
                    context.pushNamed("workPlanDetails");
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 3),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: AppColors.superAdminPrimary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.superAdminPrimaryDark,
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
              _buildNavItem('MOM', Icons.assignment_outlined, false),
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
        if (label == 'MOM') {
          context.pushNamed("momDetailsScreen");
        } else if (label == 'Leads') {
          context.pushNamed("leadScreenList");
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => const LeadsListScreen()),
          // );
        } else if (label == 'Clients') {
          context.pushNamed("clientsListScreen");
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

  void _handlePunchAction1() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    // 🔋 Request all permissions including battery optimization (only when punching IN)
    if (!isPunchedIn) {
      final permissionsGranted = await BatteryOptimizationHelper.requestAllPermissions();
      if (!permissionsGranted) {
        setState(() => isLoading = false);
        _showSuccessMessage(
            'Please grant all permissions for background location tracking');
        return;
      }
    }

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
            'Location permission denied - punch saved without location');
      } else {
        final pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best);
        lat = pos.latitude;
        lng = pos.longitude;
        accuracyM = pos.accuracy.toInt();
      }
    } catch (_) {
      _showSuccessMessage(
          'Could not get location - punch saved without location');
    }

    final userId = SessionManager.getUserId()?.toString() ?? '';

    final body = PunchInOutRequestBody(
      capturedAt: DateTime.now().toUtc().toIso8601String(),
      lat: lat,
      lng: lng,
      accuracyM: accuracyM,
      deviceId: '',
      deviceModel: '',
    );

    if (isPunchedIn) {
      context.read<PunchOutBloc>().add(
        FetchPunchOut(body: body, id: userId),
      );
    } else {
      context.read<PunchInBloc>().add(
        FetchPunchIn(body: body, id: userId),
      );
    }
  }

// dart
  void _handlePunchAction() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    // If currently punched in, confirm punch-out first
    if (isPunchedIn) {
      final confirm = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text('Confirm Punch Out'),
            content: const Text('Are you sure you want to punch out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Punch Out'),
              ),
            ],
          );
        },
      );

      if (confirm != true) {
        // user cancelled
        setState(() => isLoading = false);
        return;
      }
      // proceed to gather location and call PunchOutBloc below
    } else {
      // 🔋 Request all permissions including battery optimization (only when punching IN)
      final permissionsGranted = await BatteryOptimizationHelper.requestAllPermissions();
      if (!permissionsGranted) {
        setState(() => isLoading = false);
        _showSuccessMessage(
            'Please grant all permissions for background location tracking');
        return;
      }
    }

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
            'Location permission denied - punch saved without location');
      } else {
        final pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best);
        lat = pos.latitude;
        lng = pos.longitude;
        accuracyM = pos.accuracy.toInt();
      }
    } catch (_) {
      _showSuccessMessage(
          'Could not get location - punch saved without location');
    }

    final userId = SessionManager.getUserId()?.toString() ?? '';

    final body = PunchInOutRequestBody(
      capturedAt: DateTime.now().toUtc().toIso8601String(),
      lat: lat,
      lng: lng,
      accuracyM: accuracyM,
      deviceId: '',
      deviceModel: '',
    );

    if (isPunchedIn) {
      // Dispatch punch out only after confirmation
      context.read<PunchOutBloc>().add(
        FetchPunchOut(body: body, id: userId),
      );
    } else {
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
            // Container(
            //   decoration: BoxDecoration(
            //     gradient: const LinearGradient(
            //       colors: [Color(0xFFF56565), Color(0xFFE53E3E)],
            //     ),
            //     borderRadius: BorderRadius.circular(6),
            //   ),
            //   child: TextButton(
            //     onPressed: () {
            //
            //       context.read<LogoutBloc>().add(FetchLogout(refreshToken: SessionManager.getRefreshTokenSync().toString()));
            //       Navigator.of(context).pop();
            //     },
            //     child: const Text(
            //       'Logout',
            //       style: TextStyle(
            //         color: Colors.white,
            //         fontWeight: FontWeight.w600,
            //         fontSize: 14,
            //       ),
            //     ),
            //   ),
            // ),

            BlocProvider(
              create: (context) => LogoutBloc(),
              child: BlocConsumer<LogoutBloc, LogoutState>(
                listener: (context, state) {
                  if (state is LogoutLoaded) {
                    // Logout successful - clear session and navigate
                    SessionManager.logout();
                    context.goNamed("login");
                  } else if (state is LogoutError) {
                    // Show error snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                builder: (context, state) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF56565), Color(0xFFE53E3E)],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: state is LogoutLoading
                        ? const SizedBox(
                      height: 44,
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ),
                    )
                        : TextButton(
                      onPressed: () {
                        context.read<LogoutBloc>().add(
                            FetchLogout(refreshToken: SessionManager.getRefreshToken().toString())
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
                  );
                },
              ),
            ),

          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _autoPunchOutTimer?.cancel();
    // _pingTimer?.cancel();
    super.dispose();
  }
  //
  // void _startPingTimer(String userId) async {
  //   // Cancel existing timers/tasks
  //   _pingTimer?.cancel();
  //   await Workmanager().cancelByUniqueName('location_ping_$userId');
  //
  //   // ✅ FOREGROUND: 1min Timer (when app visible)
  //   _pingTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
  //     if (!mounted || !SessionManager.isPunchedInSync()) {
  //       _pingTimer?.cancel();
  //       return;
  //     }
  //
  //     await _sendLocationPing(userId);
  //   });
  //
  //   // ✅ BACKGROUND: Workmanager 1min (when app closed/killed)
  //   await Workmanager().registerPeriodicTask(
  //     'location_ping_$userId',  // Unique name
  //     'locationPingTask',
  //     frequency: const Duration(minutes: 1),
  //     inputData: {'userId': userId},
  //     constraints: Constraints(networkType: NetworkType.connected),
  //   );
  //
  //   debugPrint('✅ Timer(1min) + Workmanager(1min) started for $userId');
  // }
  //
  // void _stopPingTimer() async {
  //   final userId = SessionManager.getUserIdSync() ?? '';
  //
  //   // Stop both
  //   _pingTimer?.cancel();
  //   _pingTimer = null;
  //   await Workmanager().cancelByUniqueName('location_ping_$userId');
  //
  //   debugPrint('❌ Timer + Workmanager stopped for $userId');
  // }

// Extract ping logic (shared)
  Future<void> _sendLocationPing(String userId) async {
    try {
      double? lat, lng;
      int? accuracyM;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever) {
        try {
          final pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 20),
          );
          lat = pos.latitude;
          lng = pos.longitude;
          accuracyM = pos.accuracy.toInt();
        } catch (e) {
          // fallback to last known position
          try {
            final lk = await Geolocator.getLastKnownPosition();
            if (lk != null) {
              lat = lk.latitude;
              lng = lk.longitude;
              accuracyM = lk.accuracy.toInt();
            }
          } catch (e2) {
            debugPrint('Failed to get last known position fallback: $e2');
          }
        }
      }

      final body = PunchInOutRequestBody(
        capturedAt: DateTime.now().toUtc().toIso8601String(),
        lat: lat, lng: lng, accuracyM: accuracyM,
        deviceId: '', deviceModel: '',
      );

      if (mounted) {
        context.read<LocationPingBloc>().add(
          FetchLocationPing(body: body, id: userId),
        );
      }
    } catch (e) {
      debugPrint('Location ping failed: $e');
    }
  }


  //
  // void _startPingTimer(String userId) {
  //   // Cancel existing timer if any
  //   _pingTimer?.cancel();
  //
  //   _pingTimer = Timer.periodic(
  //     const Duration(minutes: 1),
  //         (_) async {
  //       try {
  //         double? lat;
  //         double? lng;
  //         int? accuracyM;
  //
  //         LocationPermission permission =
  //         await Geolocator.checkPermission();
  //
  //         if (permission == LocationPermission.denied) {
  //           permission = await Geolocator.requestPermission();
  //         }
  //
  //         if (permission != LocationPermission.denied &&
  //             permission != LocationPermission.deniedForever) {
  //           final pos = await Geolocator.getCurrentPosition(
  //             desiredAccuracy: LocationAccuracy.best,
  //           );
  //           lat = pos.latitude;
  //           lng = pos.longitude;
  //           accuracyM = pos.accuracy.toInt();
  //         }
  //
  //         final body = PunchInOutRequestBody(
  //           capturedAt: DateTime.now().toUtc().toIso8601String(),
  //           lat: lat,
  //           lng: lng,
  //           accuracyM: accuracyM,
  //           deviceId: '',
  //           deviceModel: '',
  //         );
  //
  //         /// ✅ Dispatch Bloc event (THIS IS THE KEY CHANGE)
  //         context.read<LocationPingBloc>().add(
  //           FetchLocationPing(
  //             body: body,
  //             id: userId,
  //           ),
  //         );
  //       } catch (e) {
  //         // Silent failure: timer should never crash UI
  //         debugPrint('Location ping failed: $e');
  //       }
  //     },
  //   );
  // }
  //
  //
  // void _stopPingTimer() {
  //   _pingTimer?.cancel();
  //   _pingTimer = null;
  // }
}
