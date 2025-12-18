import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../api/models/request/ApproveRequestBody.dart';
import '../../../../bloc/dashboard/dashboard_bloc.dart';
import '../../../../bloc/dashboard/dashboard_event.dart';
import '../../../../bloc/registration/registration_bloc.dart';
import '../../../../bloc/registration/registration_event.dart';
import '../../../../bloc/registration/registration_state.dart';
import '../../../../api/models/response/PendingRegistrationResponseBody.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class PendingUsersScreen extends StatefulWidget {
  const PendingUsersScreen({Key? key}) : super(key: key);

  @override
  State<PendingUsersScreen> createState() => _PendingUsersScreenState();
}

class _PendingUsersScreenState extends State<PendingUsersScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<PendingBloc>().add(GetPendingEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Users'),
        backgroundColor: AppColors.primaryTealDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<PendingBloc, PendingState>(
        builder: (context, state) {
          if (state is PendingLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PendingLoaded) {
            final items = state.response.data ?? [];
            if (items.isEmpty) {
              return const Center(child: Text('No pending users found'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final user = items[index];
                return _PendingUserCard(
                  user: user,
                  index: index,
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _PendingUserCard extends StatefulWidget {
  final Data user;
  final int index;
  const _PendingUserCard({required this.user, required this.index});

  @override
  State<_PendingUserCard> createState() => _PendingUserCardState();
}

class _PendingUserCardState extends State<_PendingUserCard> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ApproveRegistrationBloc, ApproveRegistrationState>(
          listener: (context, state) {
            if (state is ApproveRegistrationLoaded) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User approved successfully!')),
              );
              // Optionally refresh pending list
              context.read<PendingBloc>().add(GetPendingEvent());
              context.read<AllUsersBloc>().add(GetAllUsers());
            } else if (state is ApproveRegistrationError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message ?? 'Failed to approve user')),
              );
            }
          },
        ),
        BlocListener<RejectRegistrationBloc, RejectRegistrationState>(
          listener: (context, state) {
            if (state is RejectRegistrationLoaded) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User rejected successfully!')),
              );
              // Optionally refresh pending list
              context.read<PendingBloc>().add(GetPendingEvent());
            } else if (state is RejectRegistrationError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message ?? 'Failed to reject user')),
              );
            }
          },
        ),
      ],
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: widget.index % 2 == 0 ? Colors.white : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.04 * 255).toInt()),
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
                CircleAvatar(
                  child: Text(
                    (widget.user.fullName ?? '?').isNotEmpty ? widget.user.fullName![0].toUpperCase() : '?',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user.fullName ?? '-',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.user.email ?? '',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF718096)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF5E6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Pending',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFED8936),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _showApproveDialog(context, widget.user);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF38A169),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Approve', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _showRejectDialog(context, widget.user);
                      // TODO: Show reject dialog and handle reject
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Reject', style: TextStyle(color: Color(0xFFE53E3E))),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  final List<Map<String, String>> _roles = [
    {'value': AppConstants.roleExecutive.toUpperCase(), 'label': 'EXECUTIVE'},
    {'value': AppConstants.roleAdmin.toUpperCase(), 'label': 'ADMIN'},
  ];

  void _showApproveDialog(BuildContext context, Data registration) {
    String selectedRole = _roles.first['value']!;
    // Save the parent context for Bloc access
    final rootContext = context;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Approve Registration'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Select role for this user:'),
                  const SizedBox(height: 12),
                  DropdownButton<String>(
                    value: selectedRole,
                    isExpanded: true,
                    items: _roles.map((role) {
                      return DropdownMenuItem<String>(
                        value: role['value'],
                        child: Text(role['label']!),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedRole = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF48BB78), Color(0xFF38A169)]),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: TextButton(
                    onPressed: () {
                      // Use rootContext for Bloc access
                      rootContext.read<ApproveRegistrationBloc>().add(FetchApproveRegistration(
                        body: ApproveRequestBody(
                            role: selectedRole,
                            appCode: AppConstants.appCode
                        ),
                        id: registration.id!,
                      ));
                      Navigator.of(context).pop();
                      // Remove mock snackbar, real feedback is handled by BlocListener
                    },
                    child: const Text('Approve', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showRejectDialog(BuildContext context, Data registration) {
    final TextEditingController reasonController = TextEditingController();
    // Save the parent context for Bloc access
    final rootContext = context;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Reject Registration'),
          content:  const Text('Are you sure you want to reject this registration?',style: TextStyle(fontSize: 15,fontStyle: FontStyle.italic),),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFF56565), Color(0xFFE53E3E)]),
                borderRadius: BorderRadius.circular(6),
              ),
              child: TextButton(
                onPressed: () {
                  // Use rootContext for Bloc access
                  rootContext.read<RejectRegistrationBloc>().add(FetchRejectRegistration(id: registration.id!));
                  Navigator.of(context).pop();
                  // Remove mock snackbar, real feedback is handled by BlocListener
                },
                child: const Text('Reject', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        );
      },
    );
  }
}

