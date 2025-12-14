import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import './new_mom_screen.dart';

class MeetingsListScreen extends StatefulWidget {
  const MeetingsListScreen({super.key});

  @override
  State<MeetingsListScreen> createState() => _MeetingsListScreenState();
}

class _MeetingsListScreenState extends State<MeetingsListScreen> {
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Today', 'This Week', 'Lead Created', 'No Lead'];

  final List<Map<String, dynamic>> meetings = [
    {
      'clientName': 'A Class Stone',
      'date': '11 Dec',
      'type': 'Negotiation',
      'contactPerson': 'Jitendra S.',
      'leadStatus': 'No Lead Created',
      'hasLead': false,
    },
    {
      'clientName': 'Patwari Marble',
      'date': '10 Dec',
      'type': 'First Introduction',
      'contactPerson': 'Rajk.',
      'leadStatus': 'Lead Created (#L-2025-014)',
      'hasLead': true,
      'leadNumber': 'L-2025-014',
    },
    {
      'clientName': 'Sangam Granites',
      'date': '09 Dec',
      'type': 'Follow-up',
      'contactPerson': 'Priya M.',
      'leadStatus': 'Lead Created (#L-2025-013)',
      'hasLead': true,
      'leadNumber': 'L-2025-013',
    },
  ];

  List<Map<String, dynamic>> get filteredMeetings {
    if (selectedFilter == 'All') return meetings;
    if (selectedFilter == 'Lead Created') {
      return meetings.where((m) => m['hasLead'] == true).toList();
    }
    if (selectedFilter == 'No Lead') {
      return meetings.where((m) => m['hasLead'] == false).toList();
    }
    return meetings; // For Today and This Week, we'd filter by date
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: _buildMeetingsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewMomScreen()),
          );
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
      title: Text(
        'My Meetings',
        style: GoogleFonts.lato(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _showFilterMenu,
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Filter',
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary, size: 18),
            ],
          ),
        ),
        const SizedBox(width: 8),
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
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search client / contact / type',
                hintStyle: GoogleFonts.lato(
                  fontSize: 14,
                  color: AppColors.textLight,
                ),
                prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        ],
      ),
    );
  }

  Widget _buildMeetingsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredMeetings.length,
      itemBuilder: (context, index) {
        final meeting = filteredMeetings[index];
        return _buildMeetingCard(meeting, index);
      },
    );
  }

  Widget _buildMeetingCard(Map<String, dynamic> meeting, int index) {
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
          Text(
            meeting['clientName'],
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${meeting['date']} · ${meeting['type']} · ${meeting['contactPerson']}',
                style: GoogleFonts.lato(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
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
              Text(
                meeting['leadStatus'],
                style: GoogleFonts.lato(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: meeting['hasLead'] ? AppColors.success : AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (meeting['hasLead'])
            OutlinedButton(
              onPressed: () {
                _viewLead(meeting['leadNumber']);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryTeal,
                side: const BorderSide(color: AppColors.primaryTeal),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                'View Lead',
                style: GoogleFonts.lato(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            OutlinedButton(
              onPressed: () {
                _convertToLead(meeting);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.warning,
                side: const BorderSide(color: AppColors.warning),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                'Convert to Lead',
                style: GoogleFonts.lato(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.3, end: 0);
  }

  void _showFilterMenu() {
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
              Text(
                'Filter Meetings',
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ...filters.map((filter) => ListTile(
                title: Text(
                  filter,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                trailing: selectedFilter == filter
                    ? const Icon(Icons.check, color: AppColors.primaryTeal)
                    : null,
                onTap: () {
                  setState(() {
                    selectedFilter = filter;
                  });
                  Navigator.pop(context);
                },
              )),
            ],
          ),
        );
      },
    );
  }

  void _viewLead(String leadNumber) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening lead $leadNumber'),
        backgroundColor: AppColors.primaryTeal,
      ),
    );
  }

  void _convertToLead(Map<String, dynamic> meeting) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Converting ${meeting['clientName']} meeting to lead'),
        backgroundColor: AppColors.warning,
      ),
    );
  }
}
