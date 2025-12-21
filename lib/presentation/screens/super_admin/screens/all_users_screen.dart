import 'package:apclassstone/presentation/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import '../../../../api/models/response/AllUsersResponseBody.dart';
import '../../../../bloc/dashboard/dashboard_bloc.dart';
import '../../../../bloc/dashboard/dashboard_event.dart';

import '../../../../bloc/dashboard/dashboard_state.dart';

class AllUsersScreen extends StatefulWidget {
  const AllUsersScreen({Key? key}) : super(key: key);

  @override
  State<AllUsersScreen> createState() => _AllUsersScreenState();
}

class _AllUsersScreenState extends State<AllUsersScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<AllUsersBloc>().add(GetAllUsers());
  }

  // Refresh handler used by RefreshIndicator. Dispatches GetAllUsers and waits
  // until the bloc finishes the loading cycle (or times out).
  Future<void> _refresh() async {
    final bloc = context.read<AllUsersBloc>();
    final completer = Completer<void>();
    bool sawLoading = false;
    final sub = bloc.stream.listen((state) {
      // Detect that a loading cycle started, then complete when it finishes
      if (state is AllUsersLoading) {
        sawLoading = true;
      } else if (sawLoading) {
        if (!completer.isCompleted) completer.complete();
      }
    });

    bloc.add(GetAllUsers());

    try {
      // Wait for the loading cycle to finish, but don't hang forever
      await completer.future.timeout(const Duration(seconds: 8));
    } catch (_) {
      // timeout or other error - just continue
    }

    await sub.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: CoolAppCard(title: "All Users")
      ),
      body: BlocBuilder<AllUsersBloc, AllUsersState>(
        builder: (context, state) {
          if (state is AllUsersLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AllUsersLoaded) {
            final items = state.response.data ?? [];
            if (items.isEmpty) {
              return const Center(child: Text('No users found'));
            }
            return RefreshIndicator(
              onRefresh: _refresh,
              // Using ListView.builder as the child of RefreshIndicator so
              // pull-to-refresh works.
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final user = items[index];
                  return _UserCard(
                    user: user,
                    index: index,
                    isPending: user.isActive ?? false,
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final Data user;
  final int index;
  final bool isPending;
  const _UserCard({required this.user, required this.index, required this.isPending});

  @override
  Widget build(BuildContext context) {
    final isActive = user.isActive ?? false;
    final hasRoles = (user.roles ?? []).isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? const Color(0xFFE2E8F0) : const Color(0xFFFFE6E6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            // Header with avatar and info
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar with status indicator
                      Stack(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  isActive ? const Color(0xFF6366F1) : const Color(0xFF94A3B8),
                                  isActive ? const Color(0xFF8B5CF6) : const Color(0xFF64748B),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                (user.fullName ?? '?').isNotEmpty
                                    ? user.fullName![0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          // Status indicator
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                border: Border.all(color: Colors.white, width: 2),
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      // User info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    user.fullName ?? '-',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1A202C),
                                      letterSpacing: -0.3,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Status badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isActive ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isActive ? 'Active' : 'Inactive',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isActive ? const Color(0xFF065F46) : const Color(0xFF7F1D1D),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Roles section
                  if (hasRoles)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Assigned Roles',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: (user.roles ?? []).map((role) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0E7FF),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  '${role.appCode ?? 'APP'} - ${role.role ?? 'UNKNOWN'}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF3730A3),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    )

                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'No roles assigned',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF92400E),
                          letterSpacing: 0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
            // Divider
            Divider(
              height: 1,
              color: const Color(0xFFE2E8F0),

            ),
            // Metadata section
            ])));

  }
}

