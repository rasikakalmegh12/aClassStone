import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../api/models/response/PendingRegistrationResponseBody.dart';
import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/auth/auth_event.dart';
import '../../../bloc/auth/auth_state.dart';
import '../../../bloc/bloc.dart';
import '../../../bloc/registration/registration_bloc.dart';
import '../../../bloc/registration/registration_event.dart';
import '../../../bloc/registration/registration_state.dart';
import '../../../bloc/user_management/user_management_bloc.dart';
import '../../../bloc/user_management/user_management_event.dart';
import '../../../bloc/user_management/user_management_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/session/session_manager.dart';
import '../../../../api/models/response/AllUsersResponseBody.dart' as AllUser;
import '../super_admin/screens/all_users_screen.dart';

class AdminDashboard extends StatefulWidget {
  final String user;

  const AdminDashboard({
    super.key,
    required this.user,
  });

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _showPending = true;
  bool _isOnline = true;
  late ConnectivityService _connectivityService;

  @override
  void initState() {
    super.initState();

    // Ensure status bar icons are readable on dark gradient
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
    ));

    // Initialize connectivity monitoring
    _connectivityService = ConnectivityService.instance;
    _isOnline = _connectivityService.isOnline;

    // Listen to connectivity changes
    _connectivityService.statusStream.listen((status) {
      setState(() {
        _isOnline = status == ConnectivityStatus.online;
      });

      // Refresh data when connectivity is restored
      if (_isOnline) {
        _refreshData();
      }
    });

    // Load all users data
    _refreshData();
  }

  void _refreshData() {
    context.read<PendingBloc>().add(GetPendingEvent());
    context.read<AllUsersBloc>().add(GetAllUsers());
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient2,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // Color the status bar (time/notification) area so it matches the header
              if (topPadding > 0)
                Container(
                  height: topPadding,
                  decoration: const BoxDecoration(
                    gradient: AppColors.adminGradient,
                  ),
                ),
              // Render the actual header under the status area
              _buildHeader(),
              // Connectivity Status Bar
              if (!_isOnline)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    border: Border(
                      bottom: BorderSide(color: Colors.orange.shade300, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.cloud_off_rounded, color: Colors.orange.shade700, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No internet connectivity - Showing cached data',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildStatsGrid(),
                      const SizedBox(height: 10),
                      _buildPendingRegistrations(),
                      const SizedBox(height: 10),
                      _buildQuickActionsCard(),
                      const SizedBox(height: 40), // Extra padding at bottom
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: AppColors.adminGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.adminPrimary.withAlpha((0.12 * 255).toInt()),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          context.pushNamed("profile");
        },
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.adminAccent, AppColors.primaryGold],
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGold.withAlpha((0.25 * 255).toInt()),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.admin_panel_settings_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Admin Portal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Team Management Dashboard',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.white.withAlpha((0.85 * 255).toInt()),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.12 * 255).toInt()),
                borderRadius: BorderRadius.circular(19),
                border: Border.all(
                  color: Colors.white.withAlpha((0.14 * 255).toInt()),
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
      ),
    ).animate().fadeIn(duration: 700.ms).slideY(begin: -0.5, end: 0);
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: BlocBuilder<AllUsersBloc, AllUsersState>(
            builder: (context, allUsersState) {
              int totalUsers = 0;
              bool isLoading = false;
              if (allUsersState is AllUsersLoaded) {
                totalUsers = allUsersState.response.data?.length ?? 0;
              } else if (allUsersState is AllUsersLoading) {
                isLoading = true;
              }
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _showPending = false; // show ALL users
                  });
                },
                child: _statCard(
                  // Use admin-friendly gradient
                  color1: AppColors.adminPrimary,
                  color2: AppColors.adminLight,
                  icon: Icons.people_alt_rounded,
                  label: 'Total Users',
                  value: totalUsers,
                  isLoading: isLoading,
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: BlocBuilder<PendingBloc, PendingState>(
            builder: (context, pendingState) {
              int pending = 0;
              bool isLoading = false;
              if (pendingState is PendingLoaded) {
                pending = pendingState.response.data?.length ?? 0;
              } else if (pendingState is PendingLoading) {
                isLoading = true;
              }
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _showPending = true; // show PENDING users
                  });
                },
                child: _statCard(
                  // Use a warm gold gradient that complements the superadmin header accent
                  color1: AppColors.superAdminAccent,
                  color2: AppColors.primaryGoldLight,
                  icon: Icons.hourglass_top_rounded,
                  label: 'Pending Users',
                  value: pending,
                  isLoading: isLoading,
                ),
              );
            },
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _statCard({
    required Color color1,
    required Color color2,
    required IconData icon,
    required String label,
    required int value,
    bool isLoading = false,
  }) {
    return Container(
      // height: 65,
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color1.withAlpha((0.92 * 255).toInt()), color2.withAlpha((0.92 * 255).toInt())],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color1.withAlpha((0.10 * 255).toInt()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          '$value',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildPendingRegistrations() {
    // same outer container design as now – only body logic changed
    return BlocBuilder<PendingBloc, PendingState>(
      builder: (context, pendingState) {
        return BlocBuilder<AllUsersBloc, AllUsersState>(
          builder: (context, allUsersState) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.grey.shade50,
                    Colors.white,
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.04 * 255).toInt()),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                    spreadRadius: -5,
                  ),
                  BoxShadow(
                    color: Colors.blue.withAlpha((0.05 * 255).toInt()),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                    spreadRadius: -8,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER – keep almost same, only title dynamic
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            Color(0xFFF8FAFC),
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: _showPending
                                    ? const [Color(0xFFF59E0B), Color(0xFFEF4444)]
                                    : const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFF59E0B).withAlpha((0.3 * 255).toInt()),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.schedule_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _showPending
                                          ? 'Pending Registrations'
                                          : 'All Users',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _showPending
                                      ? 'Review new registrations'
                                      : 'View all registered users',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              if (_showPending) {
                                context.read<PendingBloc>().add(GetPendingEvent());
                              } else {
                                context.read<AllUsersBloc>().add(GetAllUsers());
                              }
                            },
                            icon: const Icon(
                              Icons.refresh_rounded,
                              size: 16,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // separator line
                    Container(
                      height: 1,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Color(0xFFE2E8F0),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    // FIXED HEIGHT LIST AREA
                    SizedBox(
                      height: 250, // same height to keep layout stable
                      child: _showPending
                          ? _buildPendingBody(pendingState)
                          : _buildAllUsersBody(allUsersState),
                    ),
                  ],
                ),
              ),
            ) ;


          },
        );
      },
    );
  }

  Widget _buildPendingBody(PendingState state) {
    if (state is PendingLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
        ),
      );
    } else if (state is PendingLoaded) {
      final items = state.response.data ?? [];
      if (items.isEmpty) {
        // keep your existing “All caught up” UI
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ... existing success icon / text
                Text(
                  'All caught up!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A365D),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'No pending registrations to review',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final showViewAll = items.length > 2;
      final visibleItems = showViewAll ? items.take(2).toList() : items;

      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: visibleItems.length,
              itemBuilder: (context, index) {
                final registration = visibleItems[index];
                return _buildRegistrationItem(registration, index);
              },
            ),
          ),
          if (showViewAll)
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () {

                  // Navigator.push(context, MaterialPageRoute(builder: (context) => const PendingUsersScreen()));
                  context.pushNamed('pendingUsersScreen',
                    pathParameters: {},
                  );
                },
                child: const Text('View all'),
              ),
            ),
        ],
      );
    } else if (state is PendingError) {
      // keep your existing error UI
      return const Center(
        child: Text(
          'Unable to load data',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A365D),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }


  Widget _buildAllUsersBody(AllUsersState state) {
    if (state is AllUsersLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
        ),
      );
    } else if (state is AllUsersLoaded) {
      final items = state.response.data ?? [];
      if (items.isEmpty) {
        return const Center(
          child: Text(
            'No users found',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF718096),
            ),
          ),
        );
      }

      final showViewAll = items.length > 3;
      final visibleItems = showViewAll ? items.take(3).toList() : items;

      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: visibleItems.length,
              itemBuilder: (context, index) {
                final user = visibleItems[index];
                // You can reuse same layout as registration item or create a simpler one
                return InkWell(
                  onTap: () => _showUserProfileBottomSheet(context, user),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        (user.fullName ?? '?').isNotEmpty
                            ? user.fullName![0].toUpperCase()
                            : '?',
                      ),
                    ),
                    title: Text(
                      user.fullName ?? '-',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A365D),
                      ),
                    ),
                    subtitle: Text(
                      user.email ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF718096),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (showViewAll)
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AllUsersScreen()));
                  // context.pushNamed('allUsersScreen',
                  //   pathParameters: {},
                  // );
                },
                child: const Text('View all'),
              ),
            ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildRegistrationItem(Data registration, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.white : const Color(0xFFF8FAFC),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    '${registration.fullName?.substring(0, 1).toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${registration.fullName}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A365D),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${registration.email}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF718096),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFFBF0), Color(0xFFFFF5E6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFF6AD55).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Text(
                  'Pending',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFED8936),
                  ),
                ),
              ),
            ],
          ),

        ],
      ),
    ).animate(delay: (index * 100).ms).fadeIn().slideX(begin: 0.3, end: 0);
  }

  Widget _buildQuickActionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.adminCard,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
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
              color: AppColors.adminPrimaryDark,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    label: 'Executive Tracking',
                    icon: Icons.route,
                    onTap: () {
                      context.pushNamed("executiveHistoryTracking");
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    label: 'Catalogues',
                    icon: Icons.calendar_today_outlined,
                    onTap: () {
                      context.pushNamed("cataloguePage");
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    label: 'Work-Plan',
                    icon: Icons.work_history_outlined,
                    onTap: () {
                      context.pushNamed("workPlanDetails");
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    label: 'Attendance',
                    icon: Icons.assignment_outlined,
                    onTap: () {
                      context.pushNamed("attendanceTracking");
                      // Show more options
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    label: 'Leads',
                    icon: Icons.star_outline,
                    onTap: () {
                      context.pushNamed("leadScreenList");
                      // Navigate to leads
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    label: 'Clients',
                    icon: Icons.person_outline,
                    onTap: () {
                      // Navigate to clients
                      context.pushNamed("clientsListScreen");
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    label: 'MOM',
                    icon: Icons.list_alt_rounded,
                    onTap: () {
                      context.pushNamed("momDetailsScreen");
                    },
                  ),
                ),
              ],
            ),
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
                        colors: [AppColors.adminPrimary, AppColors.adminLight],
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
                                    FetchLogout(refreshToken: SessionManager.getRefreshToken().toString()),
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



  /// Show User Profile Details Bottom Sheet
  void _showUserProfileBottomSheet(BuildContext listContext, AllUser.Data user) {
    showModalBottomSheet(
      context: listContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
      ),
      builder: (bottomSheetContext) {
        return BlocProvider(
          create: (context) => UserManagementBloc()
            ..add(FetchUserProfileDetails(
              userId: user.id ?? '',
              showLoader: true,
            )),
          child: BlocConsumer<UserManagementBloc, UserManagementState>(
            listener: (context, state) {
              if (state is ChangeRoleSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.response.message ?? 'Role changed successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
                // Refresh user details
                context.read<UserManagementBloc>().add(
                  FetchUserProfileDetails(userId: user.id ?? '', showLoader: false),
                );
                // Refresh the main list
                this.context.read<AllUsersBloc>().add(GetAllUsers());
              } else if (state is ChangeRoleError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              } else if (state is ChangeStatusSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.response.message ?? 'Status changed successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
                // Refresh user details
                context.read<UserManagementBloc>().add(
                  FetchUserProfileDetails(userId: user.id ?? '', showLoader: false),
                );
                // Refresh the main list
                this.context.read<AllUsersBloc>().add(GetAllUsers());
              } else if (state is ChangeStatusError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            builder: (context, state) {
              return DraggableScrollableSheet(
                initialChildSize: 0.75,
                maxChildSize: 0.85,
                minChildSize: 0.5,
                builder: (context, scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      children: [
                        // Header
                        Container(
                          height: 60,
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: AppColors.superAdminPrimary,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.person, color: Colors.white, size: 24),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'User Profile Details',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.white),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ),
                        // Content
                        Expanded(
                          child: _buildBottomSheetContent(context, state, scrollController, user),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  /// Build bottom sheet content based on state
  Widget _buildBottomSheetContent(
      BuildContext context,
      UserManagementState state,
      ScrollController scrollController,
      AllUser.Data initialUser,)
  {
    if (state is UserProfileDetailsLoading && state.showLoader) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.superAdminPrimary),
      );
    }

    if (state is UserProfileDetailsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.error),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<UserManagementBloc>().add(
                  FetchUserProfileDetails(userId: initialUser.id ?? ''),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.superAdminPrimary,
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    // Use loaded data if available, otherwise use initial user data
    final userData = state is UserProfileDetailsLoaded
        ? state.response.data
        : null;

    final displayName = userData?.fullName ?? initialUser.fullName ?? 'Unknown';
    final displayEmail = userData?.email ?? initialUser.email ?? '-';
    final displayPhone = userData?.phone ?? '-'; // From UserProfileDetailsResponseBody
    final displayRole = userData?.roles?.first.role ??
        (initialUser.roles?.isNotEmpty == true
            ? initialUser.roles!.first.role
            : '-') ?? '-';
    final displayIsActive = userData?.isActive ?? initialUser.isActive ?? false;
    final displayUserId = userData?.id ?? initialUser.id ?? '';

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        // Avatar Section
        Center(
          child: Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.superAdminPrimary,
                      AppColors.superAdminLight,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: displayIsActive ? AppColors.success : AppColors.error,
                    border: Border.all(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Name
        Center(
          child: Text(
            displayName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A202C),
            ),
          ),
        ),
        const SizedBox(height: 4),

        // Role Badge
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.superAdminPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.superAdminPrimary),
            ),
            child: Text(
              displayRole.toString().toUpperCase(),
              style: const TextStyle(
                color: AppColors.superAdminPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Contact Information Section
        _buildSectionTitle('Contact Information'),
        const SizedBox(height: 12),
        _buildInfoCard(Icons.email, 'Email', displayEmail),
        const SizedBox(height: 8),
        _buildInfoCard(Icons.phone, 'Phone', displayPhone),
        const SizedBox(height: 24),

        // Account Status Section
        _buildSectionTitle('Account Status'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    displayIsActive ? Icons.check_circle : Icons.cancel,
                    color: displayIsActive ? AppColors.success : AppColors.error,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        displayIsActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: displayIsActive ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Switch(
                value: displayIsActive,
                activeTrackColor: AppColors.success.withValues(alpha: 0.5),
                thumbColor: WidgetStateProperty.all(
                  displayIsActive ? AppColors.success : Colors.grey,
                ),
                onChanged: (value) {
                  context.read<UserManagementBloc>().add(
                    ChangeUserStatus(
                      userId: displayUserId,
                      isActive: value,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Change Role Section
        _buildSectionTitle('Change Role'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select New Role',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
              children: [
                for (final role in [
                  'EXECUTIVE',
                  'ADMIN',
                  if (SessionManager.getUserRole() == "superadmin") 'SUPERADMIN',
                ])
                  ChoiceChip(
                    label: Text(role),
                    selected: role == displayRole.toString().toUpperCase(),
                    selectedColor: AppColors.superAdminPrimary,
                    labelStyle: TextStyle(
                      color: role == displayRole.toString().toUpperCase() ? Colors.white : Colors.black87,
                      fontWeight: role == displayRole.toString().toUpperCase() ? FontWeight.w600 : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      final isCurrentRole = role == displayRole.toString().toUpperCase();
                      if (selected && !isCurrentRole) {
                        showDialog(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Confirm Role Change'),
                            content: Text('Are you sure you want to change the role from $displayRole to $role?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                  context.read<UserManagementBloc>().add(
                                    ChangeUserRole(
                                      userId: displayUserId,
                                      role: role,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.superAdminPrimary,
                                ),
                                child: const Text('Confirm', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
              ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A202C),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.superAdminPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A202C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
