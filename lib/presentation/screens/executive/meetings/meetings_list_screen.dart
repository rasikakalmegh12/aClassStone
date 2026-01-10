import 'package:apclassstone/bloc/mom/mom_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';


import '../../../../api/models/response/GetMomResponseBody.dart';
import '../../../../bloc/mom/mom_event.dart';
import '../../../../bloc/mom/mom_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../widgets/app_bar.dart';
import './new_mom_screen.dart';
//
// class MeetingsListScreen extends StatefulWidget {
//   const MeetingsListScreen({super.key});
//
//   @override
//   State<MeetingsListScreen> createState() => _MeetingsListScreenState();
// }
//
// class _MeetingsListScreenState extends State<MeetingsListScreen> {
//   String selectedFilter = 'All';
//   final List<String> filters = ['All', 'Today', 'This Week', 'Lead Created', 'No Lead'];
//
//   final List<Map<String, dynamic>> meetings = [
//     {
//       'clientName': 'A Class Stone',
//       'date': '11 Dec',
//       'type': 'Negotiation',
//       'contactPerson': 'Jitendra S.',
//       'leadStatus': 'No Lead Created',
//       'hasLead': false,
//     },
//     {
//       'clientName': 'Patwari Marble',
//       'date': '10 Dec',
//       'type': 'First Introduction',
//       'contactPerson': 'Rajk.',
//       'leadStatus': 'Lead Created (#L-2025-014)',
//       'hasLead': true,
//       'leadNumber': 'L-2025-014',
//     },
//     {
//       'clientName': 'Sangam Granites',
//       'date': '09 Dec',
//       'type': 'Follow-up',
//       'contactPerson': 'Priya M.',
//       'leadStatus': 'Lead Created (#L-2025-013)',
//       'hasLead': true,
//       'leadNumber': 'L-2025-013',
//     },
//   ];
//
//   List<Map<String, dynamic>> get filteredMeetings {
//     if (selectedFilter == 'All') return meetings;
//     if (selectedFilter == 'Lead Created') {
//       return meetings.where((m) => m['hasLead'] == true).toList();
//     }
//     if (selectedFilter == 'No Lead') {
//       return meetings.where((m) => m['hasLead'] == false).toList();
//     }
//     return meetings; // For Today and This Week, we'd filter by date
//   }
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     context.read<GetMomListBloc>().add(
//       FetchMomList(
//         showLoader: true,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundLight,
//       appBar: _buildAppBar(),
//       body: Column(
//         children: [
//           _buildSearchAndFilters(),
//           Expanded(
//             child: _buildMeetingsList(),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           final result = await context.pushNamed("momScreen");
//           if (result == true) {
//             context.read<GetMomListBloc>().add(
//               FetchMomList(
//                 showLoader: false,
//               ),
//             );
//           }
//           // Navigator.push(
//           //   context,
//           //   MaterialPageRoute(builder: (context) => const NewMomScreen()),
//           // );
//         },
//         backgroundColor: AppColors.primaryTeal,
//         child: const Icon(Icons.add, color: AppColors.white),
//       ),
//     );
//   }
//
//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       backgroundColor: AppColors.white,
//       elevation: 1,
//       shadowColor: AppColors.grey200,
//       leading: IconButton(
//         onPressed: () => Navigator.pop(context),
//         icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
//       ),
//       title: Text(
//         'My Meetings',
//         style: TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.w600,
//           color: AppColors.textPrimary,
//         ),
//       ),
//       actions: [
//         IconButton(
//           onPressed: _showFilterMenu,
//           icon: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 'Filter',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: AppColors.textSecondary,
//                 ),
//               ),
//               const SizedBox(width: 4),
//               const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary, size: 18),
//             ],
//           ),
//         ),
//         const SizedBox(width: 8),
//       ],
//     );
//   }
//
//   Widget _buildSearchAndFilters() {
//     return Container(
//       color: AppColors.white,
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // Search Bar
//           Container(
//             decoration: BoxDecoration(
//               color: AppColors.grey50,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: AppColors.grey200),
//             ),
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: 'Search client / contact / type',
//                 hintStyle: TextStyle(
//                   fontSize: 14,
//                   color: AppColors.textLight,
//                 ),
//                 prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
//                 border: InputBorder.none,
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           // Filter Chips
//           SizedBox(
//             height: 32,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: filters.length,
//               itemBuilder: (context, index) {
//                 final filter = filters[index];
//                 final isSelected = filter == selectedFilter;
//
//                 return Padding(
//                   padding: const EdgeInsets.only(right: 8),
//                   child: GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         selectedFilter = filter;
//                       });
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//                       decoration: BoxDecoration(
//                         color: isSelected ? AppColors.primaryTeal : AppColors.white,
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(
//                           color: isSelected ? AppColors.primaryTeal : AppColors.grey300,
//                         ),
//                       ),
//                       child: Text(
//                         filter,
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w500,
//                           color: isSelected ? AppColors.white : AppColors.textSecondary,
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMeetingsList() {
//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: filteredMeetings.length,
//       itemBuilder: (context, index) {
//         final meeting = filteredMeetings[index];
//         return _buildMeetingCard(meeting, index);
//       },
//     );
//   }
//
//   Widget _buildMeetingCard(Map<String, dynamic> meeting, int index) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             meeting['clientName'],
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: AppColors.textPrimary,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               Text(
//                 '${meeting['date']} · ${meeting['type']} · ${meeting['contactPerson']}',
//                 style: TextStyle(
//                   fontSize: 13,
//                   color: AppColors.textSecondary,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Text(
//                 'Status: ',
//                 style: TextStyle(
//                   fontSize: 13,
//                   color: AppColors.textSecondary,
//                 ),
//               ),
//               Text(
//                 meeting['leadStatus'],
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w500,
//                   color: meeting['hasLead'] ? AppColors.success : AppColors.warning,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           if (meeting['hasLead'])
//             OutlinedButton(
//               onPressed: () {
//                 _viewLead(meeting['leadNumber']);
//               },
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: AppColors.primaryTeal,
//                 side: const BorderSide(color: AppColors.primaryTeal),
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//               ),
//               child: Text(
//                 'View Lead',
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             )
//           else
//             OutlinedButton(
//               onPressed: () {
//                 _convertToLead(meeting);
//               },
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: AppColors.warning,
//                 side: const BorderSide(color: AppColors.warning),
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//               ),
//               child: Text(
//                 'Convert to Lead',
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.3, end: 0);
//   }
//
//   void _showFilterMenu() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (context) {
//         return Container(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Filter Meetings',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                   color: AppColors.textPrimary,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               ...filters.map((filter) => ListTile(
//                 title: Text(
//                   filter,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: AppColors.textPrimary,
//                   ),
//                 ),
//                 trailing: selectedFilter == filter
//                     ? const Icon(Icons.check, color: AppColors.primaryTeal)
//                     : null,
//                 onTap: () {
//                   setState(() {
//                     selectedFilter = filter;
//                   });
//                   Navigator.pop(context);
//                 },
//               )),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   void _viewLead(String leadNumber) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Opening lead $leadNumber'),
//         backgroundColor: AppColors.primaryTeal,
//       ),
//     );
//   }
//
//   void _convertToLead(Map<String, dynamic> meeting) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Converting ${meeting['clientName']} meeting to lead'),
//         backgroundColor: AppColors.warning,
//       ),
//     );
//   }
// }

class MeetingsListScreen extends StatefulWidget {
  const MeetingsListScreen({super.key});

  @override
  State<MeetingsListScreen> createState() => _MeetingsListScreenState();
}

class _MeetingsListScreenState extends State<MeetingsListScreen> {
  String selectedFilter = 'All';
  final List<String> filters = [
    'All',
    'Lead Created',
    'No Lead',
  ];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {}); // Rebuild to show/hide clear button
    });
    _loadMomList(showLoader: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadMomList({bool showLoader = false}) {
    // Determine isConvertedToLead based on filter
    bool? isConvertedToLead;
    if (selectedFilter == 'Lead Created') {
      isConvertedToLead = true;
    } else if (selectedFilter == 'No Lead') {
      isConvertedToLead = false;
    }
    // If 'All' is selected, isConvertedToLead remains null

    context.read<GetMomListBloc>().add(
      FetchMomList(
        showLoader: showLoader,
        search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
        isConvertedToLead: isConvertedToLead,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: CoolAppCard(title: "MOM Details",)
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: BlocBuilder<GetMomListBloc, GetMomListState>(
              builder: (context, state) {
                if (state is GetMomListLoading && state.showLoader) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is GetMomListError) {
                  return Center(child: Text(state.message));
                }

                if (state is GetMomListSuccess) {
                  final items = state.response.data?.items ?? [];

                  if (items.isEmpty) {
                    return const Center(child: Text("No MOM's found"));
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      _loadMomList();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return _buildMeetingCard(items[index], index);
                      },
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryTeal,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await context.pushNamed("momScreen");
          if (result == true) {
            _loadMomList();
          }
        },
      ),
    );
  }

  // ================= UI METHODS =================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 1,
      title: const Text('My Meetings'),
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
              onChanged: (value) {
                // Debounce search - trigger after user stops typing
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_searchController.text == value) {
                    _loadMomList(showLoader: false);
                  }
                });
              },
              decoration: InputDecoration(
                hintText: 'Search client / contact / type',
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textLight,
                ),
                prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textLight),
                        onPressed: () {
                          _searchController.clear();
                          _loadMomList(showLoader: false);
                        },
                      )
                    : null,
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
                      // Trigger API call with new filter
                      _loadMomList(showLoader: false);
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

  Widget _buildMeetingCard(Items meeting, int index) {
    return InkWell(
      onTap: (){
        _openMomDetailsBottomSheet(meeting.id!);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              meeting.clientName ?? "NA",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    maxLines: 2,
                    '${meeting.meetingAtDisplay!} · ${meeting.meetingType} · ${meeting.contactName}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      overflow: TextOverflow.visible
                    ),
                    softWrap: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Status: ',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  meeting.isConvertedToLead == true ? 'Lead Created' : 'No Lead',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: meeting.isConvertedToLead! ? AppColors.success : AppColors.warning,
                  ),
                ),
              ],
            ),

          ],
        ),
      ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.3, end: 0),
    );
  }

  void _openMomDetailsBottomSheet(String momId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return BlocProvider(
          create: (_) => GetMomDetailsBloc()
            ..add(
              FetchMomDetails(
                momId: momId,
                showLoader: true,
              ),
            ),
          child: const _MomDetailsBottomSheet(),
        );
      },
    );
  }

//
  // Widget _buildMeetingCard(dynamic meeting, int index) {
  //   final hasLead = meeting.isConvertedToLead == true;
  //
  //   return GestureDetector(
  //     onTap: () {
  //       context.pushNamed(
  //         "momDetails",
  //         extra: meeting.id, // 👈 PASS MOM ID
  //       );
  //     },
  //     child: Container(
  //       margin: const EdgeInsets.only(bottom: 12),
  //       padding: const EdgeInsets.all(16),
  //       decoration: BoxDecoration(
  //         color: AppColors.white,
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             meeting.clientName ?? '',
  //             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  //           ),
  //           const SizedBox(height: 6),
  //           Text(
  //             '${meeting.meetingAtDisplay} · ${meeting.meetingType} · ${meeting.contactName}',
  //             style: const TextStyle(fontSize: 13),
  //           ),
  //           const SizedBox(height: 8),
  //           Text(
  //             hasLead ? 'Lead Created' : 'No Lead',
  //             style: TextStyle(
  //               color: hasLead ? Colors.green : Colors.orange,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ).animate().fadeIn(delay: (index * 80).ms),
  //   );
  // }
}
class _MomDetailsBottomSheet extends StatefulWidget {
  const _MomDetailsBottomSheet();

  @override
  State<_MomDetailsBottomSheet> createState() => _MomDetailsBottomSheetState();
}

class _MomDetailsBottomSheetState extends State<_MomDetailsBottomSheet> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: BlocBuilder<GetMomDetailsBloc, GetMomDetailsState>(
            builder: (context, state) {
              if (state is GetMomDetailsLoading && state.showLoader) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is GetMomDetailsError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              if (state is GetMomDetailsSuccess) {
                final data = state.response.data!;

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<GetMomDetailsBloc>().add(
                      FetchMomDetails(
                        momId: data.id!,
                        showLoader: false,
                      ),
                    );
                  },
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.zero,
                    children: [
                      // Header with close button
                      _buildHeader(context, data.momId!),

                      // Image carousel (if available)
                      if (data.photos?.isNotEmpty == true)
                        _buildImageCarousel(data.photos!),

                      // Content section
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Client & Contact Info Card
                            _buildInfoCard(
                              icon: Icons.business_rounded,
                              title: 'Client Details',
                              items: [
                                _InfoItem(label: 'Client', value: data.clientName),
                                _InfoItem(label: 'Contact Person', value: data.contactName),
                                _InfoItem(label: 'Phone', value: data.contactPhone),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Meeting Info Card
                            _buildInfoCard(
                              icon: Icons.event_rounded,
                              title: 'Meeting Details',
                              items: [
                                _InfoItem(
                                  label: 'Type',
                                  value: _formatMeetingType(data.meetingType),
                                ),
                                _InfoItem(
                                  label: 'Date & Time',
                                  value: data.meetingAtDisplay ?? '-',
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Notes Section
                            if (data.detailedNotes != null && data.detailedNotes!.isNotEmpty)
                              _buildNotesSection(data.detailedNotes!),

                            if (data.detailedNotes != null && data.detailedNotes!.isNotEmpty)
                              const SizedBox(height: 16),

                            // Checklist Section
                            if (data.checklistItems?.isNotEmpty == true)
                              _buildChecklistSection(data.checklistItems!),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox();
            },
          ),
        );
      },
    );
  }

  // ================= UI SECTIONS =================

  Widget _buildHeader(BuildContext context, String momId) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  momId,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Meeting Minutes',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.close_rounded, size: 24),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(List photos) {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Stack(
        children: [
          PageView.builder(
            itemCount: photos.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // Optional: Open full screen image viewer
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      photos[index].url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image_rounded, size: 64, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Image not available', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),

          // Image counter indicator
          if (photos.length > 1)
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.image_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '${_currentImageIndex + 1}/${photos.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Page indicator dots
          if (photos.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      photos.length,
                      (index) => Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentImageIndex == index
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required List<_InfoItem> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryTeal.withValues(alpha: 0.05),
            AppColors.primaryTeal.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryTeal.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primaryTeal, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.value ?? '-',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(String notes) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.description_rounded, color: Colors.amber, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Meeting Notes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              notes,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistSection(List items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.withValues(alpha: 0.05),
            Colors.green.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.checklist_rounded, color: Colors.green, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Discussion Checklist',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map(
            (e) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.green.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.green,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatChecklistKey(e.itemKey),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (e.notes != null && e.notes!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            e.notes!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatMeetingType(String? type) {
    if (type == null) return '-';
    return type
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  String _formatChecklistKey(String? key) {
    if (key == null) return '-';
    return key
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}

class _InfoItem {
  final String label;
  final String? value;

  _InfoItem({required this.label, this.value});
}
