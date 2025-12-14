import 'package:apclassstone/bloc/registration/registration_bloc.dart';
import 'package:apclassstone/bloc/registration/registration_event.dart';
import 'package:apclassstone/bloc/registration/registration_state.dart';
import 'package:apclassstone/core/session/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../api/models/response/PendingRegistrationResponseBody.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/custom_button.dart';
import '../auth/login_screen.dart';

class SuperAdminDashboard extends StatefulWidget {
  final String user;

  const SuperAdminDashboard({
    super.key,
    required this.user,
  });

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  @override
  void initState() {
    super.initState();
    SessionManager.isLoggedIn().then((isLoggedIn) {
      print("login status: $isLoggedIn");
      print("access token: ${SessionManager.getAccessTokenSync()}");
    });
    // Load pending registrations and dashboard data
    context.read<PendingBloc>().add(GetPendingEvent());
    // context.read<DashboardBloc>().add(LoadSuperAdminDashboardEvent());
  }

  final List<Map<String, dynamic>> _dashboardStats = [
    {
      'title': 'Total Users',
      'value': '156',
      'icon': Icons.people,
      'color': AppColors.primaryGold,
      'change': '+12',
      'changeType': 'increase',
    },
    {
      'title': 'Pending Approvals',
      'value': '8',
      'icon': Icons.pending_actions,
      'color': AppColors.warning,
      'change': '+3',
      'changeType': 'increase',
    },
    {
      'title': 'Active Admins',
      'value': '5',
      'icon': Icons.admin_panel_settings,
      'color': AppColors.secondaryBlue,
      'change': '0',
      'changeType': 'neutral',
    },
    {
      'title': 'System Health',
      'value': '98%',
      'icon': Icons.health_and_safety,
      'color': AppColors.success,
      'change': '+2%',
      'changeType': 'increase',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildStatsGrid(),
                    const SizedBox(height: 24),
                    isMobile
                        ? Column(
                            children: [
                              _buildPendingRegistrations(),
                              const SizedBox(height: 16),
                              _buildSystemOverview(),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildPendingRegistrations(),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 1,
                                child: _buildSystemOverview(),
                              ),
                            ],
                          ),
                    const SizedBox(height: 24),
                    _buildQuickActions(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryGold,
            AppColors.primaryGoldDark,
            AppColors.accentOrange,
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.admin_panel_settings,
              color: AppColors.primaryGold,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Super Admin',
                  style: GoogleFonts.lato(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                Text(
                  'System Control Panel',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: AppColors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              _showLogoutDialog();
            },
            icon: const Icon(
              Icons.logout,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.5, end: 0);
  }

  Widget _buildStatsGrid() {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Overview',
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 2 : 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: _dashboardStats.length,
          itemBuilder: (context, index) {
            final stat = _dashboardStats[index];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: stat['color'].withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              stat['color'],
                              stat['color'].withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          stat['icon'],
                          color: AppColors.white,
                          size: 16,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getChangeColor(stat['changeType']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getChangeIcon(stat['changeType']),
                              size: 10,
                              color: _getChangeColor(stat['changeType']),
                            ),
                            const SizedBox(width: 1),
                            Text(
                              stat['change'],
                              style: GoogleFonts.lato(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: _getChangeColor(stat['changeType']),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stat['value'],
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stat['title'],
                    style: GoogleFonts.lato(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ).animate(delay: (index * 100).ms).fadeIn().slideY(begin: 0.3, end: 0);
          },
        ),
      ],
    );
  }

  Widget _buildPendingRegistrations() {
    return BlocBuilder<PendingBloc, PendingState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.pending_actions,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pending Registrations',
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        // context.read<RegistrationBloc>().add(
                        //       LoadPendingRegistrationsEvent(),
                        //     );
                      },
                      icon: const Icon(
                        Icons.refresh,
                        size: 20,
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.divider),
              if (state is PendingLoading)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGold,
                    ),
                  ),
                )
              else if (state is PendingLoaded)
                state.response.data!.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 48,
                                color: AppColors.success,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No pending registrations',
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        children: List.generate(
                          state.response.data!.length,
                          (index) => _buildRegistrationItem(state.response.data![index]),
                        ),
                      )
              else if (state is PendingError)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Failed to load registrations',
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const SizedBox(height: 100),
            ],
          ),
        ).animate(delay: 400.ms).fadeIn().slideX(begin: -0.3, end: 0);
      },
    );
  }

  Widget _buildRegistrationItem(Data registration) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryGold.withOpacity(0.1),
                child: Text(
                  '${registration.fullName?.substring(0, 1).toUpperCase()}',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${registration.fullName}',
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${registration.email}',
                      style: GoogleFonts.lato(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Approve',
                  onPressed: () {},
                  backgroundColor: AppColors.success,
                  height: 32,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomButton(
                  text: 'Reject',
                  onPressed: () {},
                  backgroundColor: AppColors.error,
                  height: 32,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSystemOverview() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'System Status',
              style: GoogleFonts.lato(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          _buildSystemStatusItem(
            'Database',
            'Online',
            AppColors.success,
            Icons.storage,
          ),
          _buildSystemStatusItem(
            'API Server',
            'Running',
            AppColors.success,
            Icons.cloud,
          ),
          _buildSystemStatusItem(
            'Background Jobs',
            'Active',
            AppColors.warning,
            Icons.schedule,
          ),
          _buildSystemStatusItem(
            'Security',
            'Protected',
            AppColors.success,
            Icons.security,
          ),
        ],
      ),
    ).animate(delay: 600.ms).fadeIn().slideX(begin: 0.3, end: 0);
  }

  Widget _buildSystemStatusItem(
    String title,
    String status,
    Color statusColor,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.grey500),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.lato(
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: GoogleFonts.lato(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Administrative Actions',
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isMobile ? 2 : 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: isMobile ? 1.1 : 1.0,
          children: [
            _buildActionCard(
              icon: Icons.people_alt,
              title: 'User\nManagement',
              color: AppColors.primaryGold,
              onTap: () {},
            ),
            _buildActionCard(
              icon: Icons.admin_panel_settings,
              title: 'Admin\nRoles',
              color: AppColors.secondaryBlue,
              onTap: () {},
            ),
            _buildActionCard(
              icon: Icons.analytics,
              title: 'System\nAnalytics',
              color: AppColors.accentPurple,
              onTap: () {},
            ),
            _buildActionCard(
              icon: Icons.settings,
              title: 'System\nSettings',
              color: AppColors.warning,
              onTap: () {},
            ),
          ],
        ),
      ],
    ).animate(delay: 800.ms).fadeIn().slideY(begin: 0.3, end: 0);
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppColors.white,
                size: 18,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Color _getChangeColor(String changeType) {
    switch (changeType) {
      case 'increase':
        return AppColors.success;
      case 'decrease':
        return AppColors.error;
      case 'neutral':
      default:
        return AppColors.grey500;
    }
  }

  IconData _getChangeIcon(String changeType) {
    switch (changeType) {
      case 'increase':
        return Icons.trending_up;
      case 'decrease':
        return Icons.trending_down;
      case 'neutral':
      default:
      return Icons.trending_flat;
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Logout',
            style: GoogleFonts.lato(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: GoogleFonts.lato(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.lato(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // context.read<AuthBloc>().add(LogoutEvent());
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: Text(
                'Logout',
                style: GoogleFonts.lato(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
