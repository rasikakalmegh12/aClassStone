import 'package:apclassstone/api/models/response/ExecutiveAttendanceMonthlyResponseBody.dart';
import 'package:apclassstone/bloc/attendance/attendance_bloc.dart';
import 'package:apclassstone/bloc/attendance/attendance_event.dart';
import 'package:apclassstone/bloc/attendance/attendance_state.dart';
import 'package:apclassstone/core/constants/app_colors.dart';
import 'package:apclassstone/core/session/session_manager.dart';
import 'package:apclassstone/presentation/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AttendanceMonthlyTracking extends StatefulWidget {
  final String userId;
  const AttendanceMonthlyTracking({super.key, required this.userId});

  @override
  State<AttendanceMonthlyTracking> createState() => _AttendanceMonthlyTrackingState();
}

class _AttendanceMonthlyTrackingState extends State<AttendanceMonthlyTracking> with SingleTickerProviderStateMixin {
  late DateTime _selectedMonth;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Default to current month
    _selectedMonth = DateTime.now();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Fetch data for current month
    _fetchMonthlyData();

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _fetchMonthlyData() {
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

    final fromDate = DateFormat('dd-MMM-yyyy').format(firstDay);
    final toDate = DateFormat('dd-MMM-yyyy').format(lastDay);

    context.read<AttendanceTrackingMonthlyBloc>().add(
      FetchAttendanceTrackingMonthly(
        userId: widget.userId,
        fromDate: fromDate,
        toDate: toDate,
        showLoader: true,
      ),
    );
  }

  void _showMonthPicker() async {
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (context) => _MonthPickerDialog(
        selectedMonth: _selectedMonth,
        primaryColor: SessionManager.getUserRole() == "superadmin"
            ? AppColors.superAdminPrimary
            : AppColors.adminPrimaryDark,
      ),
    );

    if (picked != null && picked != _selectedMonth) {
      setState(() {
        _selectedMonth = picked;
      });
      _fetchMonthlyData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: CoolAppCard(
          title: "Monthly Attendance",
          backgroundColor: SessionManager.getUserRole() == "superadmin"
              ? AppColors.superAdminPrimary
              : AppColors.adminPrimaryDark,
        ),
      ),
      body: BlocBuilder<AttendanceTrackingMonthlyBloc, AttendanceTrackingMonthlyState>(
        builder: (context, state) {
          if (state is AttendanceTrackingMonthlyLoading && state.showLoader) {
            return _buildLoadingState();
          } else if (state is AttendanceTrackingMonthlyLoaded) {
            return _buildLoadedState(state.response.data ?? []);
          } else if (state is AttendanceTrackingMonthlyError) {
            return _buildErrorState(state.message);
          }
          return _buildEmptyState();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: SessionManager.getUserRole() == "superadmin"
                ? AppColors.superAdminPrimary
                : AppColors.adminPrimaryDark,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading attendance data...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(List<Data> data) {
    final primaryColor = SessionManager.getUserRole() == "superadmin"
        ? AppColors.superAdminPrimary
        : AppColors.adminPrimaryDark;

    // Calculate totals
    final totalDays = data.length;
    final totalWorkMinutes = data.fold<int>(0, (sum, item) => sum + (item.totalWorkMinutes ?? 0));
    final totalHours = (totalWorkMinutes / 60).floor();
    final remainingMinutes = totalWorkMinutes % 60;
    final activeDays = data.where((d) => d.dayStatus == 'ACTIVE' || d.dayStatus == 'LOGGED_OUT').length;

    return RefreshIndicator(
      color: primaryColor,
      onRefresh: () async {
        _fetchMonthlyData();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month Selector Header
              _buildMonthSelector(primaryColor),

              // Summary Cards
              _buildSummaryCards(totalDays, activeDays, totalHours, remainingMinutes, primaryColor),

              // Attendance List Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month, color: primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Daily Attendance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$totalDays Days',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Daily Attendance List
              data.isEmpty
                  ? _buildEmptyDataState()
                  : _buildAttendanceList(data, primaryColor),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthSelector(Color primaryColor) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withAlpha(200)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withAlpha(30),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _showMonthPicker,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.date_range,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selected Month',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMMM yyyy').format(_selectedMonth),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(int totalDays, int activeDays, int totalHours, int remainingMinutes, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              icon: Icons.calendar_today,
              title: 'Total Days',
              value: '$totalDays',
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: _SummaryCard(
              icon: Icons.check_circle,
              title: 'Active Days',
              value: '$activeDays',
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: _SummaryCard(
              icon: Icons.access_time,
              title: 'Total Hours',
              value: '${totalHours}h ${remainingMinutes}m',
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceList(List<Data> data, Color primaryColor) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        return TweenAnimationBuilder(
          duration: Duration(milliseconds: 400 + (index * 30)),
          tween: Tween<double>(begin: 0.0, end: 1.0),
          builder: (context, double value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: _AttendanceCard(item: item, primaryColor: primaryColor),
        );
      },
    );
  }

  Widget _buildEmptyDataState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No attendance data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'No records found for this month',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error Loading Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[800]),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchMonthlyData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: SessionManager.getUserRole() == "superadmin"
                    ? AppColors.superAdminPrimary
                    : AppColors.adminPrimaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'Select a month to view attendance',
        style: TextStyle(color: Colors.grey[600]),
      ),
    );
  }
}

// Summary Card Widget
class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(30)),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 17),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),


        ],
      ),
    );
  }
}

// Attendance Card Widget
class _AttendanceCard extends StatelessWidget {
  final Data item;
  final Color primaryColor;

  const _AttendanceCard({
    required this.item,
    required this.primaryColor,
  });

  Color get _statusColor {
    switch (item.dayStatus) {
      case 'ACTIVE':
        return Colors.green;
      case 'LOGGED_OUT':
        return Colors.orange;
      case 'NOT_LOGGED_IN':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String get _statusLabel {
    switch (item.dayStatus) {
      case 'ACTIVE':
        return 'Active';
      case 'LOGGED_OUT':
        return 'Logged Out';
      case 'NOT_LOGGED_IN':
        return 'Not Logged In';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final workMinutes = item.totalWorkMinutes ?? 0;
    final hours = (workMinutes / 60).floor();
    final minutes = workMinutes % 60;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _statusColor.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with Date and Status
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _statusColor.withAlpha(15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.calendar_today, color: primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child:  Text(
                    item.dateDisplay ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Work Hours Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${hours}h ${minutes}m',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailRow(
                  Icons.login,
                  'Punch In',
                  item.firstPunchInAtDisplay ?? 'N/A',
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.logout,
                  'Punch Out',
                  item.lastPunchOutAtDisplay ?? 'N/A',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoChip(
                        Icons.repeat,
                        'Sessions',
                        '${item.sessionCount ?? 0}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoChip(
                        Icons.location_on,
                        'Pings',
                        '${item.totalPingCount ?? 0}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: primaryColor),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
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

// Month Picker Dialog
class _MonthPickerDialog extends StatefulWidget {
  final DateTime selectedMonth;
  final Color primaryColor;

  const _MonthPickerDialog({
    required this.selectedMonth,
    required this.primaryColor,
  });

  @override
  State<_MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<_MonthPickerDialog> {
  late int selectedYear;
  late int selectedMonth;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.selectedMonth.year;
    selectedMonth = widget.selectedMonth.month;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Year Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => setState(() => selectedYear--),
                ),
                Text(
                  '$selectedYear',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: widget.primaryColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => setState(() => selectedYear++),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Month Grid
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final month = index + 1;
                final isSelected = month == selectedMonth && selectedYear == widget.selectedMonth.year;

                return InkWell(
                  onTap: () {
                    Navigator.pop(context, DateTime(selectedYear, month));
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? widget.primaryColor : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        DateFormat('MMM').format(DateTime(2000, month)),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[800],
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Cancel Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
