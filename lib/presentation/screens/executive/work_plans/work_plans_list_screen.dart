import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import 'create_work_plan_screen.dart';

class WorkPlansListScreen extends StatefulWidget {
  const WorkPlansListScreen({super.key});

  @override
  State<WorkPlansListScreen> createState() => _WorkPlansListScreenState();
}

class _WorkPlansListScreenState extends State<WorkPlansListScreen> {
  String selectedFilter = 'Upcoming';
  final List<String> filters = ['Upcoming', 'Past', 'Pending', 'Rejected'];

  final List<Map<String, dynamic>> workPlans = [
    {
      'date': '15 Dec 2025',
      'city': 'Jaipur',
      'clients': ['A Class Stone', 'Sangam Granites'],
      'additionalCount': 2,
      'status': 'Pending Approval',
      'statusColor': AppColors.accentAmber,
      'type': 'single',
    },
    {
      'dateRange': '10–12 Dec 2025',
      'city': 'Udaipur',
      'clientCount': 3,
      'status': 'Approved',
      'statusColor': AppColors.success,
      'type': 'range',
    },
    {
      'date': '08 Dec 2025',
      'city': 'Jodhpur',
      'clients': ['Rajasthan Marbles'],
      'additionalCount': 0,
      'status': 'Completed',
      'statusColor': AppColors.textSecondary,
      'type': 'single',
    },
    {
      'date': '05 Dec 2025',
      'city': 'Ajmer',
      'clients': ['Desert Stones', 'Marble Palace'],
      'additionalCount': 1,
      'status': 'Rejected',
      'statusColor': AppColors.error,
      'type': 'single',
    },
  ];

  List<Map<String, dynamic>> get filteredWorkPlans {
    return workPlans.where((plan) {
      switch (selectedFilter) {
        case 'Pending':
          return plan['status'] == 'Pending Approval';
        case 'Rejected':
          return plan['status'] == 'Rejected';
        case 'Past':
          return plan['status'] == 'Completed' || plan['status'] == 'Approved';
        case 'Upcoming':
        default:
          return plan['status'] == 'Pending Approval' || plan['status'] == 'Approved';
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _buildWorkPlansList(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 1,
      shadowColor: AppColors.grey200,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
      ),
      title: Text(
        'Work Plans',
        style: GoogleFonts.lato(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateWorkPlanScreen()),
            );
          },
          icon: const Icon(Icons.add, color: AppColors.primaryTeal, size: 20),
          label: Text(
            'New',
            style: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryTeal,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildFilterChips() {
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
                    color: isSelected ? AppColors.primaryTeal : AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryTeal : AppColors.grey300,
                    ),
                  ),
                  child: Text(
                    filter,
                    style: GoogleFonts.lato(
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

  Widget _buildWorkPlansList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredWorkPlans.length,
      itemBuilder: (context, index) {
        final workPlan = filteredWorkPlans[index];
        return _buildWorkPlanCard(workPlan, index);
      },
    );
  }

  Widget _buildWorkPlanCard(Map<String, dynamic> workPlan, int index) {
    return Container(
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
          Row(
            children: [
              Expanded(
                child: Text(
                  workPlan['type'] == 'range'
                      ? '${workPlan['dateRange']} · ${workPlan['city']}'
                      : '${workPlan['date']} · ${workPlan['city']}',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (workPlan['type'] == 'range')
            Text(
              'Clients: ${workPlan['clientCount']}',
              style: GoogleFonts.lato(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Clients: ${workPlan['clients'].join(', ')}',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (workPlan['additionalCount'] > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '+${workPlan['additionalCount']} more',
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Status: ',
                style: GoogleFonts.lato(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: workPlan['statusColor'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  workPlan['status'],
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: workPlan['statusColor'],
                  ),
                ),
              ),
              const Spacer(),
              if (workPlan['status'] != 'Rejected' && workPlan['status'] != 'Completed')
                OutlinedButton(
                  onPressed: () {
                    _viewDetails(workPlan);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryTeal,
                    side: const BorderSide(color: AppColors.primaryTeal),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    minimumSize: const Size(0, 0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View Details',
                        style: GoogleFonts.lato(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios, size: 10),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.3, end: 0);
  }

  void _viewDetails(Map<String, dynamic> workPlan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Work Plan Details',
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Date', workPlan['type'] == 'range' ? workPlan['dateRange'] : workPlan['date']),
              _buildDetailRow('City', workPlan['city']),
              if (workPlan['type'] == 'range')
                _buildDetailRow('Clients', '${workPlan['clientCount']} clients')
              else ...[
                _buildDetailRow('Clients', workPlan['clients'].join(', ')),
                if (workPlan['additionalCount'] > 0)
                  _buildDetailRow('Additional', '+${workPlan['additionalCount']} more'),
              ],
              _buildDetailRow('Status', workPlan['status']),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (workPlan['status'] == 'Pending Approval') ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _editWorkPlan(workPlan);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryTeal,
                          side: const BorderSide(color: AppColors.primaryTeal),
                        ),
                        child: Text(
                          'Edit Plan',
                          style: GoogleFonts.lato(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (workPlan['status'] == 'Approved') {
                          _executeWorkPlan(workPlan);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: workPlan['status'] == 'Approved'
                            ? AppColors.success
                            : AppColors.primaryTeal,
                        foregroundColor: AppColors.white,
                      ),
                      child: Text(
                        workPlan['status'] == 'Approved' ? 'Execute Plan' : 'View Status',
                        style: GoogleFonts.lato(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.lato(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editWorkPlan(Map<String, dynamic> workPlan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateWorkPlanScreen(workPlan: workPlan),
      ),
    );
  }

  void _executeWorkPlan(Map<String, dynamic> workPlan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Executing work plan for ${workPlan['city']}'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
