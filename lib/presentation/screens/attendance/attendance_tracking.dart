
import 'package:apclassstone/core/session/session_manager.dart';
import 'package:apclassstone/presentation/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../bloc/attendance/attendance_bloc.dart';
import '../../../bloc/attendance/attendance_event.dart';
import '../../../bloc/attendance/attendance_state.dart';
import '../../../core/constants/app_colors.dart';
import '../executive_history/executive_history_tracking_screen.dart';

class AttendanceTracking extends StatefulWidget {
  const AttendanceTracking({super.key});

  @override
  State<AttendanceTracking> createState() => _AttendanceTrackingState();
}

class _AttendanceTrackingState extends State<AttendanceTracking> with SingleTickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late DateTime _selectedDate;

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    // Initialize header animation
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );
    _selectedDate = DateTime.now();
    _fetchAttendance();
    // Start animation
    _headerAnimationController.forward();

    // Search listener
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      // Filtering will be done in build method
    });
  }

  void _fetchAttendance() {
    context.read<ExecutiveAttendanceBloc>().add(
      FetchExecutiveAttendance(
        date: DateFormat('dd-MMM-yyyy').format(_selectedDate),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: CoolAppCard(
            title: "Attendance Tracking",
            backgroundColor: SessionManager.getUserRole() == "superadmin"
                ? AppColors.superAdminPrimary
                : AppColors.adminPrimaryDark,
          ),
        ),
        body: BlocBuilder<ExecutiveAttendanceBloc, ExecutiveAttendanceState>(
          builder: (context, state) {
            if (state is ExecutiveAttendanceLoading) {
              return const LoadingAttendance();
            } else if (state is ExecutiveAttendanceLoaded) {
              return RefreshIndicator(
                color: SessionManager.getUserRole() == "superadmin"
                    ? AppColors.superAdminPrimary
                    : AppColors.adminPrimaryDark,
                onRefresh: () async {
                  final bloc = context.read<ExecutiveAttendanceBloc>();
                  bloc.add(FetchExecutiveAttendance(
                    date: DateFormat('dd-MMM-yyyy').format(DateTime.now()),
                  ));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Animated Header with Date
                      // FadeTransition(
                      //   opacity: _headerFadeAnimation,
                      //   child: SlideTransition(
                      //     position: _headerSlideAnimation,
                      //     child: _buildDateHeader(),
                      //   ),
                      // ),
                      //
                      // // Stats Cards with staggered animation
                      //
                      //
                      // const SizedBox(height: 8),

                      // Search Bar
                      FadeTransition(
                        opacity: _headerFadeAnimation,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(10),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search by name or phone...',
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: SessionManager.getUserRole() == "superadmin"
                                      ? AppColors.superAdminPrimary
                                      : AppColors.adminPrimaryDark,
                                ),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.clear,
                                          color: Colors.grey[400],
                                        ),
                                        onPressed: () {
                                          _searchController.clear();
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ),

                      // Executives List Header
                      FadeTransition(
                        opacity: _headerFadeAnimation,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Builder(
                            builder: (context) {
                              // Filter items based on search
                              final allItems = state.response.data!.items ?? [];
                              final searchQuery = _searchController.text.toLowerCase();
                              final filteredItems = searchQuery.isEmpty
                                  ? allItems
                                  : allItems.where((item) {
                                      final name = (item.executiveName ?? '').toLowerCase();
                                      final phone = (item.phone ?? '').toLowerCase();
                                      return name.contains(searchQuery) || phone.contains(searchQuery);
                                    }).toList();

                              return Row(
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    color: SessionManager.getUserRole() == "superadmin"
                                        ? AppColors.superAdminPrimary
                                        : AppColors.adminPrimaryDark,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Executives List',
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
                                      color: (SessionManager.getUserRole() == "superadmin"
                                              ? AppColors.superAdminPrimary
                                              : AppColors.adminPrimaryDark)
                                          .withAlpha(20),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      searchQuery.isEmpty
                                          ? '${allItems.length} Total'
                                          : '${filteredItems.length}/${allItems.length}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: SessionManager.getUserRole() == "superadmin"
                                            ? AppColors.superAdminPrimary
                                            : AppColors.adminPrimaryDark,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),

                      // Executives List
                      Builder(
                        builder: (context) {
                          // Filter items based on search
                          final allItems = state.response.data!.items ?? [];
                          final searchQuery = _searchController.text.toLowerCase();
                          final filteredItems = searchQuery.isEmpty
                              ? allItems
                              : allItems.where((item) {
                                  final name = (item.executiveName ?? '').toLowerCase();
                                  final phone = (item.phone ?? '').toLowerCase();
                                  return name.contains(searchQuery) || phone.contains(searchQuery);
                                }).toList();

                          return _buildExecutivesList(filteredItems);
                        },
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            } else if (state is ExecutiveAttendanceError) {
              return ErrorAttendance(message: state.message);
            }
            return const EmptyAttendance();
          },
        ),
      ),
    );
  }

  Widget _buildDateHeader() {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, MMMM dd, yyyy').format(now);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: SessionManager.getUserRole() == "superadmin"
              ? [
                  AppColors.superAdminPrimary,
                  AppColors.superAdminPrimaryDark,
                ]
              : [
                  AppColors.adminPrimaryDark,
                  AppColors.adminPrimaryDark.withAlpha(200),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (SessionManager.getUserRole() == "superadmin"
                    ? AppColors.superAdminPrimary
                    : AppColors.adminPrimaryDark)
                .withAlpha(50),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
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
                  'Today\'s Attendance',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutivesList(List<dynamic> items) {
    final isSearching = _searchController.text.isNotEmpty;

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSearching ? Icons.search_off : Icons.people_outline,
                size: 80,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                isSearching ? 'No results found' : 'No executives found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isSearching
                    ? 'Try searching with a different keyword'
                    : 'Check back later for attendance data',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return TweenAnimationBuilder(
          duration: Duration(milliseconds: 400 + (index * 50)),
          tween: Tween<double>(begin: 0.0, end: 1.0),
          builder: (context, double value, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (SessionManager.getUserRole() == "superadmin"
                          ? AppColors.superAdminPrimary
                          : AppColors.adminPrimaryDark)
                      .withAlpha(15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  context.pushNamed(
                    'attendanceMonthlyTracking',
                    extra: item.executiveUserId.toString(),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              (SessionManager.getUserRole() == "superadmin"
                                      ? AppColors.superAdminPrimary
                                      : AppColors.adminPrimaryDark)
                                  .withAlpha(200),
                              SessionManager.getUserRole() == "superadmin"
                                  ? AppColors.superAdminPrimary
                                  : AppColors.adminPrimaryDark,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            (item.executiveName ?? 'N')
                                .substring(0, 1)
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Executive Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.executiveName ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.phone_outlined,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  item.phone ?? 'N/A',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Arrow Icon
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 18,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
