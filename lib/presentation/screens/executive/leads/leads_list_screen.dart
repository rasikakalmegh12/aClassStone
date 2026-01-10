import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../widgets/app_bar.dart';
import 'new_lead_screen.dart';

class LeadsListScreen extends StatefulWidget {
  const LeadsListScreen({super.key});

  @override
  State<LeadsListScreen> createState() => _LeadsListScreenState();
}

class _LeadsListScreenState extends State<LeadsListScreen> {
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Active', 'Closed', 'Follow-up Due'];

  final List<Map<String, dynamic>> leads = [
    {
      'leadNumber': 'L-2025-021',
      'clientName': 'A Class Stone',
      'products': ['Polished 18mm Slab', 'Raw Block 50+MT'],
      'value': '₹12,50,000',
      'deadline': '20 Dec 2025',
      'status': 'Active',
      'statusColor': AppColors.success,
      'priority': 'High',
      'priorityColor': AppColors.error,
      'followUpDate': '15 Dec 2025',
    },
    {
      'leadNumber': 'L-2025-020',
      'clientName': 'Patwari Marble',
      'products': ['Customized Tile 10mm'],
      'value': '₹8,75,000',
      'deadline': '18 Dec 2025',
      'status': 'Follow-up Due',
      'statusColor': AppColors.accentAmber,
      'priority': 'Medium',
      'priorityColor': AppColors.accentAmber,
      'followUpDate': '12 Dec 2025',
    },
    {
      'leadNumber': 'L-2025-019',
      'clientName': 'Sangam Granites',
      'products': ['Polished Slab', 'Raw Material'],
      'value': '₹15,25,000',
      'deadline': '25 Dec 2025',
      'status': 'Closed',
      'statusColor': AppColors.textSecondary,
      'priority': 'Low',
      'priorityColor': AppColors.success,
      'closedDate': '10 Dec 2025',
    },
  ];

  List<Map<String, dynamic>> get filteredLeads {
    if (selectedFilter == 'All') return leads;
    return leads.where((lead) => lead['status'] == selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        // pass headerColor to the custom app bar
        child: CoolAppCard(title: 'My Leads',  action:
          IconButton(
            onPressed: _showSortOptions,
            icon: const Icon(Icons.sort, color: AppColors.textSecondary),
          ),
        ),
      ),
      // appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: _buildLeadsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
         final result= await context.pushNamed("newLeadScreen");
         if (result== true){
if (kDebugMode) {
  print(" lead added successfully");
}
         }
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => const NewLeadScreen()),
          // );
        },
        backgroundColor: AppColors.primaryTeal,
        child: const Icon(Icons.add, color: AppColors.white),
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
      title: const Text(
       'My Leads',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _showSortOptions,
          icon: const Icon(Icons.sort, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.grey200),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search leads by client, product, or lead number',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: AppColors.textLight,
                ),
                prefixIcon: Icon(Icons.search, color: AppColors.textLight),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Filter Chips
          SizedBox(
            height: 32,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final filter = filters[index];
                final isSelected = filter == selectedFilter;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
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
        ],
      ),
    );
  }

  Widget _buildLeadsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredLeads.length,
      itemBuilder: (context, index) {
        final lead = filteredLeads[index];
        return _buildLeadCard(lead, index);
      },
    );
  }

  Widget _buildLeadCard(Map<String, dynamic> lead, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        children: [
          // Header with lead number and priority
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.grey100),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lead['leadNumber'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lead['clientName'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: lead['priorityColor'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        lead['priority'],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: lead['priorityColor'],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: lead['statusColor'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        lead['status'],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: lead['statusColor'],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Products
                const Text(
                  'Products:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: lead['products'].map<Widget>((product) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // Value and deadline
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem('Value', lead['value'], Icons.currency_rupee),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        'Deadline',
                        lead['deadline'],
                        Icons.calendar_today_outlined,
                      ),
                    ),
                  ],
                ),

                if (lead['status'] == 'Follow-up Due') ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accentAmber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 16,
                          color: AppColors.accentAmber,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Follow-up due: ${lead['followUpDate']}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.accentAmber,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (lead['status'] == 'Closed') ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Closed on: ${lead['closedDate']}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    if (lead['status'] == 'Active' || lead['status'] == 'Follow-up Due') ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _updateLead(lead),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryTeal,
                            side: const BorderSide(color: AppColors.primaryTeal),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            'Update',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _viewDetails(lead),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryTeal,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'View Details',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _viewDetails(lead),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: const BorderSide(color: AppColors.grey300),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            'View Details',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.3, end: 0);
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
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
              const Text(
                'Sort Leads',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('By Deadline'),
                leading: const Icon(Icons.calendar_today_outlined),
                onTap: () {
                  Navigator.pop(context);
                  _sortByDeadline();
                },
              ),
              ListTile(
                title: Text('By Value'),
                leading: const Icon(Icons.currency_rupee),
                onTap: () {
                  Navigator.pop(context);
                  _sortByValue();
                },
              ),
              ListTile(
                title: Text('By Priority'),
                leading: const Icon(Icons.priority_high),
                onTap: () {
                  Navigator.pop(context);
                  _sortByPriority();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _sortByDeadline() {
    setState(() {
      leads.sort((a, b) => a['deadline'].compareTo(b['deadline']));
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sorted by deadline'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _sortByValue() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sorted by value'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _sortByPriority() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sorted by priority'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _updateLead(Map<String, dynamic> lead) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewLeadScreen(existingLead: lead),
      ),
    );
  }

  void _viewDetails(Map<String, dynamic> lead) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Lead Details',
                          style: TextStyle(
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
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Lead Number', lead['leadNumber']),
                          _buildDetailRow('Client', lead['clientName']),
                          _buildDetailRow('Products', lead['products'].join(', ')),
                          _buildDetailRow('Value', lead['value']),
                          _buildDetailRow('Deadline', lead['deadline']),
                          _buildDetailRow('Status', lead['status']),
                          _buildDetailRow('Priority', lead['priority']),
                          if (lead['followUpDate'] != null)
                            _buildDetailRow('Follow-up Date', lead['followUpDate']),
                          if (lead['closedDate'] != null)
                            _buildDetailRow('Closed Date', lead['closedDate']),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 1,
            color: AppColors.grey100,
          ),
        ],
      ),
    );
  }
}
