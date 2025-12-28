import 'package:apclassstone/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../api/models/response/ExecutiveAttendanceResponseBody.dart';
import '../../../bloc/attendance/attendance_bloc.dart';
import '../../../bloc/attendance/attendance_event.dart';
import '../../../bloc/attendance/attendance_state.dart';

import '../../../core/session/session_manager.dart';
import '../../widgets/app_bar.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExecutiveAttendanceBloc()..add(FetchExecutiveAttendance(
          date: DateFormat('dd-MMM-yyyy').format(DateTime.now())
      )),
      child: const AttendanceHistoryView(),
    );
  }
}

class AttendanceHistoryView extends StatefulWidget {
  const AttendanceHistoryView({super.key});

  @override
  State<AttendanceHistoryView> createState() => _AttendanceHistoryViewState();
}

class _AttendanceHistoryViewState extends State<AttendanceHistoryView> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _fetchAttendance(); // 👈 initial API call
  }

  void _fetchAttendance() {
    context.read<ExecutiveAttendanceBloc>().add(
      FetchExecutiveAttendance(
        date: DateFormat('dd-MMM-yyyy').format(_selectedDate),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now.subtract(const Duration(days: 6)), // 👈 last 7 days incl today
      lastDate: now,
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _fetchAttendance(); // 🔥 API re-call
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: CoolAppCard(
          title: "Attendance History",
          backgroundColor: SessionManager.getUserRole().toString().toLowerCase() =="superadmin" ?AppColors.primaryGold: AppColors.primaryTealDark,
          action: IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.white, size: 20),

            onPressed: () {
              _pickDate();
              // Calendar logic
            },
          ),
        ),
      ),
      body: BlocBuilder<ExecutiveAttendanceBloc, ExecutiveAttendanceState>(
        builder: (context, state) {
          if (state is ExecutiveAttendanceLoading) {
            return const LoadingAttendance();
          } else if (state is ExecutiveAttendanceLoaded) {
            return AttendanceContent(data: state.response.data!, date: DateFormat('dd-MMM-yyyy').format(_selectedDate),);
          } else if (state is ExecutiveAttendanceError) {
            return ErrorAttendance(message: state.message);
          }
          return const EmptyAttendance();
        },
      ),
    );
  }
}

class AttendanceContent extends StatelessWidget {
  final Data data;
  final String date;
  const AttendanceContent({super.key, required this.data, required this.date});





  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        final bloc = context.read<ExecutiveAttendanceBloc>();
        bloc.add(FetchExecutiveAttendance(
            date: DateFormat('dd-MMM-yyyy').format(DateTime.now())
        ));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Animated Stats Cards
            StatsCards(data: data),
            const SizedBox(height: 5),
            // Executives List
            ExecutivesList(items: data.items, selectedDate: date,),
          ],
        ),
      ),
    );
  }
}

class StatsCards extends StatelessWidget {
  final Data data;
  const StatsCards({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(child: StatCard(
            title: 'Total',
            value: data.totalExecutives.toString(),
            color: Colors.blue,
            icon: Icons.people_outline,
          )),
          const SizedBox(width: 12),
          Expanded(child: StatCard(
            title: 'Active',
            value: data.activeExecutives.toString(),
            color: Colors.green,
            icon: Icons.check_circle_outline,
          )),
          const SizedBox(width: 12),
          Expanded(child: StatCard(
            title: 'Logged In',
            value: data.loggedInExecutives.toString(),
            color: Colors.orange,
            icon: Icons.login_outlined,
          )),
        ],
      ),
    );
  }
}


class StatCard extends StatefulWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;
  final int? index;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    this.index,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    final delay = (widget.index ?? 0) * 100;

    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: const Duration(milliseconds: 350),
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.06),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
        child: _card(),
      ),
    );
  }

  Widget _card() {
    return Container(
      // height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.color.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: widget.color.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: widget.color,
            ),
          ),
          const SizedBox(height: 4),
          _titleRow(),


        ],
      ),
    );
  }

  Widget _titleRow() {
    return Row(
      mainAxisSize: MainAxisSize.min, // 👈 key point
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          widget.icon,
          size: 14,
          color: widget.color,
        ),
        const SizedBox(width: 4),
        Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.black.withOpacity(0.65),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

}




class ExecutivesList extends StatelessWidget {
  final List<Items>? items;
  const ExecutivesList({super.key, required this.items, required this.selectedDate});
  final String selectedDate;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(10),
      itemCount: items?.length ??0,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items?[index];
        return AnimatedExecutiveCard(item: item!,index: index, date: selectedDate,);
      },
    );
  }
}


class AnimatedExecutiveCard extends StatelessWidget {
  final Items item;
  final int index; // 👈 ADD THIS
  final String date;

  const AnimatedExecutiveCard({
    super.key,
    required this.item,
    required this.index, required this.date, // 👈 ADD THIS
  });

  Color get statusColor {
    switch (item.dayStatus) {
      case 'ACTIVE':
        return Colors.green;
      case 'NOT_LOGGED_IN':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 600 + index * 100), // ✅ No .toInt() needed
      tween: Tween(begin: const Offset(0, 50), end: Offset.zero),
      builder: (context, Offset value, child) {
        return Transform.translate(
          offset: value,
          child: Opacity(
            opacity: 1.0 - (value.dy / 50).clamp(0.0, 1.0),
            child: ExecutiveCard(item: item, statusColor: statusColor, date: date,),
          ),
        );
      },
    );
  }
}

class ExecutiveCard extends StatelessWidget {
  final Items? item;
  final Color statusColor;
  final String date;

  const ExecutiveCard({
    super.key,
    required this.item,
    required this.statusColor, required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        context.pushNamed(
          'executiveTracking',
          extra: {
            'userId': item?.executiveUserId.toString(),
            'date': date,
          },
        );

      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.2),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// 🔵 Status Avatar
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    statusColor.withOpacity(0.9),
                    statusColor.withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 22,
              ),
            ),

            const SizedBox(width: 14),

            /// 👤 Executive Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item?.executiveName ?? "NA",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.call, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        item?.phone ?? "NA",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// 🟢 Status + Time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    item?.dayStatus
                        ?.replaceAll('_', ' ')
                        .toUpperCase() ??
                        "NA",
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                if (item?.activeSessionPunchInAtDisplay != null)
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 13, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        item?.activeSessionPunchInAtDisplay ?? "",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


// Empty & Error States
class EmptyAttendance extends StatelessWidget {
  const EmptyAttendance({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.schedule_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('No attendance data', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text('Pull to refresh', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class LoadingAttendance extends StatelessWidget {
  const LoadingAttendance({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading attendance...', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class ErrorAttendance extends StatelessWidget {
  final String message;
  const ErrorAttendance({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final bloc = context.read<ExecutiveAttendanceBloc>();
              bloc.add(FetchExecutiveAttendance(
                  date: DateFormat('dd-MMM-yyyy').format(DateTime.now())
              ));
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
