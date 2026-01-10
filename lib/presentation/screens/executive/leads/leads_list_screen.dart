import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../../bloc/lead/lead_bloc.dart';
import '../../../../bloc/lead/lead_event.dart';
import '../../../../bloc/lead/lead_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/session/session_manager.dart';
import '../../../widgets/app_bar.dart';

class LeadsListScreen extends StatefulWidget {
  const LeadsListScreen({super.key});

  @override
  State<LeadsListScreen> createState() => _LeadsListScreenState();
}

class _LeadsListScreenState extends State<LeadsListScreen> {
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Active', 'Closed', 'Follow-up Due'];

  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    // Fetch leads on page load
    context.read<GetLeadListBloc>().add(
      FetchLeadList(
        page: _currentPage,
        pageSize: _pageSize,
        showLoader: true,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshLeads() {
    context.read<GetLeadListBloc>().add(
      FetchLeadList(
        page: _currentPage,
        pageSize: _pageSize,
        search: _searchController.text.isEmpty ? null : _searchController.text,
        showLoader: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: CoolAppCard(
          title: 'My Leads',
          backgroundColor: SessionManager.getUserRole() =="superadmin"?AppColors.superAdminPrimary:SessionManager.getUserRole() =="admin"?
          AppColors.adminPrimaryDark :AppColors.primaryTealDark,
          action: IconButton(
            onPressed: _showSortOptions,
            icon: const Icon(Icons.sort, color: AppColors.textSecondary),
          ),
        ),
      ),
      body: BlocConsumer<GetLeadListBloc, LeadState>(
        listener: (context, state) {
          if (state is GetLeadListError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              _buildSearchAndFilters(),
              Expanded(
                child: _buildLeadsList(state),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.pushNamed("newLeadScreen");
          if (result == true) {
            if (kDebugMode) {
              print("Lead added successfully");
            }
            _refreshLeads();
          }
        },
        backgroundColor: SessionManager.getUserRole() =="superadmin"?AppColors.superAdminPrimary:SessionManager.getUserRole() =="admin"?
        AppColors.adminPrimaryDark :AppColors.primaryTealDark,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
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
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search leads by client, product, or lead number',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: AppColors.textLight,
                ),
                prefixIcon: Icon(Icons.search, color: AppColors.textLight),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                // Debounce search
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (value == _searchController.text) {
                    _refreshLeads();
                  }
                });
              },
            ),
          ),
          // const SizedBox(height: 16),
          // // Filter Chips
          // SizedBox(
          //   height: 32,
          //   child: ListView.builder(
          //     scrollDirection: Axis.horizontal,
          //     itemCount: filters.length,
          //     itemBuilder: (context, index) {
          //       final filter = filters[index];
          //       final isSelected = filter == selectedFilter;
          //
          //       return Padding(
          //         padding: const EdgeInsets.only(right: 8),
          //         child: GestureDetector(
          //           onTap: () {
          //             setState(() {
          //               selectedFilter = filter;
          //             });
          //             // TODO: Filter implementation can be added here if backend supports it
          //           },
          //           child: Container(
          //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          //             decoration: BoxDecoration(
          //               color: isSelected ? AppColors.primaryTeal : AppColors.white,
          //               borderRadius: BorderRadius.circular(16),
          //               border: Border.all(
          //                 color: isSelected ? AppColors.primaryTeal : AppColors.grey300,
          //               ),
          //             ),
          //             child: Text(
          //               filter,
          //               style: TextStyle(
          //                 fontSize: 12,
          //                 fontWeight: FontWeight.w500,
          //                 color: isSelected ? AppColors.white : AppColors.textSecondary,
          //               ),
          //             ),
          //           ),
          //         ),
          //       );
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildLeadsList(LeadState state) {
    if (state is GetLeadListLoading && state.showLoader) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryTeal,
        ),
      );
    }

    if (state is GetLeadListError) {
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
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshLeads,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is GetLeadListLoaded) {
      final leads = state.response.data?.items ?? [];

      if (leads.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.business_center_outlined,
                size: 64,
                color: AppColors.grey300,
              ),
              SizedBox(height: 16),
              Text(
                'No leads found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Start by creating your first lead',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          _refreshLeads();
          await Future.delayed(const Duration(seconds: 1));
        },
        color: AppColors.primaryTeal,
        child: ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: leads.length,
          itemBuilder: (context, index) {
            final lead = leads[index];
            return _buildLeadCard(lead, index);
          },
        ),
      );
    }

    return const SizedBox();
  }

  Widget _buildLeadCard(dynamic lead, int index) {
    // Format currency
    final formattedValue = '₹${NumberFormat('#,##,###').format(lead.grandTotal ?? 0)}';

    // Format deadline date
    String formattedDeadline = '-';
    if (lead.deadlineDate != null) {
      try {
        final date = DateTime.parse(lead.deadlineDate!);
        formattedDeadline = DateFormat('dd MMM yyyy').format(date);
      } catch (e) {
        formattedDeadline = lead.deadlineDate!;
      }
    }

    // Determine status based on deadline
    String status = 'Active';
    Color statusColor = AppColors.success;

    final deadline = DateTime.tryParse(lead.deadlineDate ?? '');
    if (deadline != null) {
      final now = DateTime.now();
      final daysUntilDeadline = deadline.difference(now).inDays;

      if (daysUntilDeadline < 0) {
        status = 'Overdue';
        statusColor = AppColors.error;
      } else if (daysUntilDeadline <= 3) {
        status = 'Urgent';
        statusColor = AppColors.accentAmber;
      } else {
        status = 'Active';
        statusColor = AppColors.success;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
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
        children: [
          // Header with lead number
          Container(
            padding: const EdgeInsets.all(10),
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
                        lead.leadNo ?? '-',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: SessionManager.getUserRole() =="superadmin"?AppColors.superAdminPrimary:SessionManager.getUserRole() =="admin"?
                          AppColors.adminPrimaryDark :AppColors.primaryTealDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lead.clientName ?? 'Unknown Client',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Assigned to
                if (lead.assignedToName != null) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Assigned to: ',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        lead.assignedToName!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],

                // Value and deadline
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem('Value', formattedValue, Icons.currency_rupee),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        'Deadline',
                        formattedDeadline,
                        Icons.calendar_today_outlined,
                      ),
                    ),
                  ],
                ),

                // MOM indicator
                if (lead.isFromMom == true) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.assignment,
                          size: 16,
                          color: AppColors.primaryTeal,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Created from MOM',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryTeal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _viewDetails(lead),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: SessionManager.getUserRole() =="superadmin"?AppColors.superAdminPrimary:SessionManager.getUserRole() =="admin"?
                          AppColors.adminPrimaryDark :AppColors.primaryTealDark,
                          side: BorderSide(color:SessionManager.getUserRole() =="superadmin"?AppColors.superAdminPrimary:SessionManager.getUserRole() =="admin"?
                          AppColors.adminPrimaryDark :AppColors.primaryTealDark),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sorting by deadline'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('By Value'),
                leading: const Icon(Icons.currency_rupee),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sorting by value'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('By Created Date'),
                leading: const Icon(Icons.date_range),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sorting by created date'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _viewDetails(dynamic lead) {
    // Create a dedicated BLoC instance for this detail view
    final detailsBloc = GetLeadDetailsBloc();

    // Trigger the fetch
    detailsBloc.add(FetchLeadDetails(leadId: lead.id!, showLoader: true));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => BlocProvider<GetLeadDetailsBloc>.value(
        value: detailsBloc,
        child: BlocBuilder<GetLeadDetailsBloc, LeadState>(
          builder: (context, state) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              maxChildSize: 0.85,
              minChildSize: 0.5,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: _buildDetailsContent(state, scrollController, lead),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailsContent(LeadState state, ScrollController scrollController, dynamic leadSummary) {
    if (state is GetLeadDetailsLoading && state.showLoader) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryTeal),
      );
    }

    if (state is GetLeadDetailsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (state is GetLeadDetailsLoaded) {
      final data = state.response.data!;
      final formattedValue = '₹${NumberFormat('#,##,###').format(data.grandTotal ?? 0)}';
      final formattedMaterialsTotal = '₹${NumberFormat('#,##,###').format(data.materialsTotal ?? 0)}';
      final formattedTransport = '₹${NumberFormat('#,##,###').format(data.transportAmount ?? 0)}';
      final formattedOtherCharges = '₹${NumberFormat('#,##,###').format(data.otherChargesAmount ?? 0)}';
      final formattedTax = '₹${NumberFormat('#,##,###').format(data.taxAmount ?? 0)}';

      String formattedDeadline = '-';
      if (data.deadlineDate != null) {
        try {
          final date = DateTime.parse(data.deadlineDate!);
          formattedDeadline = DateFormat('dd MMM yyyy').format(date);
        } catch (e) {
          formattedDeadline = data.deadlineDate!;
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.leadNo ?? '-',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                    if (data.isFromMom == true)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'From MOM',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryTeal,
                          ),
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
          const Divider(),
          const SizedBox(height: 8),

          // Details
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lead Context
                  _buildSectionHeader('Lead Context'),
                  _buildDetailRow('Deadline', formattedDeadline),
                  if (data.notes != null && data.notes!.isNotEmpty)
                    _buildDetailRow('Notes', data.notes!),

                  const SizedBox(height: 16),

                  // Products
                  _buildSectionHeader('Products (${data.items?.length ?? 0})'),
                  const SizedBox(height: 8),
                  if (data.items != null && data.items!.isNotEmpty)
                    ...data.items!.map((item) => _buildProductCard(item)),

                  const SizedBox(height: 16),

                  // Pricing Summary
                  _buildSectionHeader('Pricing Summary'),
                  _buildPricingRow('Materials Total', formattedMaterialsTotal, isBold: true),
                  _buildPricingRow('Transport', formattedTransport),
                  _buildPricingRow('Other Charges', formattedOtherCharges),
                  _buildPricingRow('Tax', formattedTax),
                  const Divider(height: 24),
                  _buildPricingRow('Grand Total', formattedValue, isBold: true, isHighlight: true),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox();
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildProductCard(dynamic item) {
    final formattedLineTotal = '₹${NumberFormat('#,##,###').format(item.lineTotal ?? 0)}';
    final formattedRate = '₹${NumberFormat('#,##,###').format(item.selectedRatePerSqft ?? 0)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName ?? '-',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.productCode ?? '-',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                formattedLineTotal,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildProductDetail('Qty', '${item.qtySqft ?? 0} sqft'),
              _buildProductDetail('Thickness', '${item.thicknessMm ?? 0} mm'),
              _buildProductDetail('Rate', formattedRate),
              if (item.productProcess != null && item.productProcess!.isNotEmpty)
                _buildProductDetail('Process', item.productProcess!),
            ],
          ),
          if (item.productRemarks != null && item.productRemarks!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Remarks: ${item.productRemarks}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductDetail(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPricingRow(String label, String value, {bool isBold = false, bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 14 : 13,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
              color: isHighlight ? AppColors.primaryTeal : AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 15 : 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: isHighlight ? AppColors.primaryTeal : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
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
