import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';


import '../../../../api/models/response/GetWorkPlanDetailsResponseBody.dart' as WorkPlan show Days;
import '../../../../bloc/work_plan/work_plan_bloc.dart';
import '../../../../bloc/work_plan/work_plan_event.dart';
import '../../../../bloc/work_plan/work_plan_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/session/session_manager.dart';
import 'create_work_plan_screen.dart';

class WorkPlansListScreen extends StatefulWidget {
  const WorkPlansListScreen({super.key});

  @override
  State<WorkPlansListScreen> createState() => _WorkPlansListScreenState();
}

class _WorkPlansListScreenState extends State<WorkPlansListScreen> {
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'DRAFT', 'SUBMITTED', 'APPROVED', 'REJECTED'];

  @override
  void initState() {
    super.initState();
    _fetchWorkPlans();
  }

  void _fetchWorkPlans() {
    context.read<GetWorkPlanListBloc>().add(
      FetchWorkPlanList(showLoader: true),
    );
  }

  Color _getRoleColor() {
    final role = SessionManager.getUserRole();
    if (role == "superadmin") {
      return AppColors.superAdminPrimary;
    } else if (role == "admin") {
      return AppColors.adminPrimary;
    } else {
      return AppColors.primaryTealDark;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'SUBMITTED':
        return AppColors.accentAmber;
      case 'APPROVED':
        return AppColors.success;
      case 'REJECTED':
        return AppColors.error;
      case 'DRAFT':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleColor = _getRoleColor();
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(),
      body: BlocConsumer<GetWorkPlanListBloc, GetWorkPlanListState>(
        listener: (context, state) {
          if (state is GetWorkPlanListError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is GetWorkPlanListLoading && state.showLoader) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is GetWorkPlanListSuccess) {
            final workPlans = state.response.data?.items ?? [];

            // Filter based on selected status
            final filteredPlans = selectedFilter == 'All'
                ? workPlans
                : workPlans.where((plan) => plan.status == selectedFilter).toList();

            if (filteredPlans.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 64,
                      color: AppColors.grey400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No work plans found',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                _buildFilterChips(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      _fetchWorkPlans();
                    },
                    color: roleColor,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredPlans.length,
                      itemBuilder: (context, index) {
                        final plan = filteredPlans[index];
                        return _buildWorkPlanCard(plan);
                      },
                    ),
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              _buildFilterChips(),
              const Expanded(
                child: Center(
                  child: Text(
                    'Pull to refresh',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final roleColor = _getRoleColor();
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 1,
      shadowColor: AppColors.grey200,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
      ),
      title: const Text(
        'Work Plans',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () async {
            final result = await context.pushNamed("createWorkPlan");
            if (result == true) {
              _fetchWorkPlans();
            }
          },
          icon: Icon(Icons.add, color: roleColor, size: 20),
          label: Text(
            'New',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: roleColor,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildFilterChips() {
    final roleColor = _getRoleColor();
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 32,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          itemBuilder: (context, index) {
            final filter = filters[index];
            final isSelected = filter == selectedFilter;

            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedFilter = filter;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? roleColor : AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? roleColor : AppColors.grey300,
                    ),
                  ),
                  child: Text(
                    filter,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? AppColors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWorkPlanCard(dynamic workPlan) {
    final roleColor = _getRoleColor();
    final statusColor = _getStatusColor(workPlan.status);

    return GestureDetector(
      onTap: () => _showWorkPlanDetails(workPlan.id ?? ''),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
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
            // Header row with date and status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: roleColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateRange(workPlan.fromDate, workPlan.toDate),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: roleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    workPlan.status?.toUpperCase() ?? 'UNKNOWN',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Executive name
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  workPlan.executiveName ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Stats row
            Row(
              children: [
                _buildStatChip(
                  icon: Icons.event_note,
                  label: '${workPlan.totalDays ?? 0} ${(workPlan.totalDays ?? 0) == 1 ? 'Day' : 'Days'}',
                  color: roleColor,
                ),
                const SizedBox(width: 8),
                _buildStatChip(
                  icon: Icons.business_center,
                  label: '${workPlan.totalClients ?? 0} Clients',
                  color: AppColors.primaryTeal,
                ),
                const SizedBox(width: 8),
                _buildStatChip(
                  icon: Icons.group_add,
                  label: '${workPlan.totalProspects ?? 0} Prospects',
                  color: AppColors.accentAmber,
                ),
              ],
            ),

            // Submitted date
            if (workPlan.submittedAt != null) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Submitted: ${_formatDateTime(workPlan.submittedAt)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(
        begin: 0.1,
        end: 0,
        duration: 300.ms,
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateRange(String? fromDate, String? toDate) {
    if (fromDate == null || toDate == null) return 'N/A';

    try {
      final from = DateTime.parse(fromDate);
      final to = DateTime.parse(toDate);

      if (from.year == to.year && from.month == to.month && from.day == to.day) {
        return DateFormat('dd MMM yyyy').format(from);
      } else {
        return '${DateFormat('dd MMM').format(from)} - ${DateFormat('dd MMM yyyy').format(to)}';
      }
    } catch (e) {
      return 'Invalid Date';
    }
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null) return 'N/A';

    try {
      final dt = DateTime.parse(dateTime);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  void _showWorkPlanDetails(String workPlanId) {
    final roleColor = _getRoleColor();

    context.read<GetWorkPlanDetailsBloc>().add(
      FetchWorkPlanDetails(
        workPlanId: workPlanId,
        showLoader: true,
      ),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => BlocProvider.value(
        value: context.read<GetWorkPlanDetailsBloc>(),
        child: DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: BlocBuilder<GetWorkPlanDetailsBloc, GetWorkPlanDetailsState>(
                builder: (context, state) {
                  if (state is GetWorkPlanDetailsLoading && state.showLoader) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is GetWorkPlanDetailsError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is GetWorkPlanDetailsSuccess) {
                    final data = state.response.data;
                    if (data == null) {
                      return const Center(
                        child: Text('No details available'),
                      );
                    }

                    return ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: roleColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.assignment,
                                color: roleColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Work Plan Details',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    _formatDateRange(data.fromDate, data.toDate),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _getStatusColor(data.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getStatusColor(data.status).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getStatusIcon(data.status),
                                size: 16,
                                color: _getStatusColor(data.status),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                data.status?.toUpperCase() ?? 'UNKNOWN',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _getStatusColor(data.status),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Executive Info
                        if(SessionManager.getUserRole() =="superadmin" || SessionManager.getUserRole()=="admin")
                        _buildDetailSection(
                          title: 'Executive',
                          icon: Icons.person,
                          color: roleColor,
                          child: Text(
                            data.executiveName ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),

                        // Executive Note
                        if (data.executiveNote != null && data.executiveNote!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildDetailSection(
                            title: 'Executive Note',
                            icon: Icons.note,
                            color: AppColors.primaryTeal,
                            child: Text(
                              data.executiveNote!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Days Section
                        if (data.days != null && data.days!.isNotEmpty) ...[
                          const Text(
                            'Daily Plan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...data.days!.map((day) {
                            return _buildDayCard(day, roleColor);
                          }),
                        ],

                        const SizedBox(height: 20),
                      ],
                    );
                  }

                  return const SizedBox();
                },
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toUpperCase()) {
      case 'SUBMITTED':
        return Icons.send;
      case 'APPROVED':
        return Icons.check_circle;
      case 'REJECTED':
        return Icons.cancel;
      case 'DRAFT':
        return Icons.edit;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildDetailSection({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildDayCard(WorkPlan.Days day, Color roleColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.grey200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: roleColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  DateFormat('dd MMM yyyy').format(DateTime.parse(day.planDate ?? '')),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          // Day note
          if (day.dayNote != null && day.dayNote!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              day.dayNote!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],

          // Clients
          if (day.clients != null && day.clients!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.business_center,
                  size: 14,
                  color: roleColor,
                ),
                const SizedBox(width: 6),
                Text(
                  'Clients (${day.clients!.length})',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: roleColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...day.clients!.map<Widget>((client) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const SizedBox(width: 20),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: roleColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        client.clientName ?? 'Unnamed Client',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

          // Prospects
          if (day.prospects != null && day.prospects!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.group_add,
                  size: 14,
                  color: AppColors.accentAmber,
                ),
                const SizedBox(width: 6),
                Text(
                  'Prospects (${day.prospects!.length})',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentAmber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...day.prospects!.map<Widget>((prospect) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Container(
                  margin: const EdgeInsets.only(left: 20),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accentAmber.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.accentAmber.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prospect.prospectName ?? 'Unnamed Prospect',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (prospect.locationText != null && prospect.locationText!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 12,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                prospect.locationText!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (prospect.contactText != null && prospect.contactText!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.phone,
                              size: 12,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              prospect.contactText!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (prospect.note != null && prospect.note!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          prospect.note!,
                          style: TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
