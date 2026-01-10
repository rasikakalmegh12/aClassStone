import 'package:apclassstone/presentation/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import '../../../../api/models/response/AllUsersResponseBody.dart';
import '../../../../bloc/dashboard/dashboard_bloc.dart';
import '../../../../bloc/dashboard/dashboard_event.dart';
import '../../../../bloc/dashboard/dashboard_state.dart';
import '../../../../bloc/user_management/user_management_bloc.dart';
import '../../../../bloc/user_management/user_management_event.dart';
import '../../../../bloc/user_management/user_management_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/session/session_manager.dart';

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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: CoolAppCard(title: "All Users",backgroundColor: SessionManager.getUserRole() =="superadmin"?AppColors.superAdminPrimary:SessionManager.getUserRole() =="admin"?
        AppColors.adminPrimaryDark :AppColors.primaryTealDark,)
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
                    onTap: () => _showUserProfileBottomSheet(context, user),
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

  /// Show User Profile Details Bottom Sheet
  void _showUserProfileBottomSheet(BuildContext listContext, Data user) {
    showModalBottomSheet(
      context: listContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return BlocProvider(
          create: (context) => UserManagementBloc()
            ..add(FetchUserProfileDetails(
              userId: user.id ?? '',
              showLoader: true,
            )),
          child: BlocConsumer<UserManagementBloc, UserManagementState>(
            listener: (context, state) {
              if (state is ChangeRoleSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.response.message ?? 'Role changed successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
                // Refresh user details
                context.read<UserManagementBloc>().add(
                  FetchUserProfileDetails(userId: user.id ?? '', showLoader: false),
                );
                // Refresh the main list
                this.context.read<AllUsersBloc>().add(GetAllUsers());
              } else if (state is ChangeRoleError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              } else if (state is ChangeStatusSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.response.message ?? 'Status changed successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
                // Refresh user details
                context.read<UserManagementBloc>().add(
                  FetchUserProfileDetails(userId: user.id ?? '', showLoader: false),
                );
                // Refresh the main list
                this.context.read<AllUsersBloc>().add(GetAllUsers());
              } else if (state is ChangeStatusError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            builder: (context, state) {
              return DraggableScrollableSheet(
                initialChildSize: 0.75,
                maxChildSize: 0.85,
                minChildSize: 0.5,
                builder: (context, scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      children: [
                        // Header
                        Container(
                          height: 60,
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: AppColors.superAdminPrimary,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.person, color: Colors.white, size: 24),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'User Profile Details',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.white),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ),
                        // Content
                        Expanded(
                          child: _buildBottomSheetContent(context, state, scrollController, user),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  /// Build bottom sheet content based on state
  Widget _buildBottomSheetContent(
    BuildContext context,
    UserManagementState state,
    ScrollController scrollController,
    Data initialUser,
  ) {
    if (state is UserProfileDetailsLoading && state.showLoader) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.superAdminPrimary),
      );
    }

    if (state is UserProfileDetailsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.error),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<UserManagementBloc>().add(
                  FetchUserProfileDetails(userId: initialUser.id ?? ''),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.superAdminPrimary,
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    // Use loaded data if available, otherwise use initial user data
    final userData = state is UserProfileDetailsLoaded
        ? state.response.data
        : null;

    final displayName = userData?.fullName ?? initialUser.fullName ?? 'Unknown';
    final displayEmail = userData?.email ?? initialUser.email ?? '-';
    final displayPhone = userData?.phone ?? '-'; // From UserProfileDetailsResponseBody
    final displayRole = userData?.roles?.first.role ??
                       (initialUser.roles?.isNotEmpty == true
                           ? initialUser.roles!.first.role
                           : '-') ?? '-';
    final displayIsActive = userData?.isActive ?? initialUser.isActive ?? false;
    final displayUserId = userData?.id ?? initialUser.id ?? '';

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        // Avatar Section
        Center(
          child: Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.superAdminPrimary,
                      AppColors.superAdminLight,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: displayIsActive ? AppColors.success : AppColors.error,
                    border: Border.all(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Name
        Center(
          child: Text(
            displayName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A202C),
            ),
          ),
        ),
        const SizedBox(height: 4),

        // Role Badge
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.superAdminPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.superAdminPrimary),
            ),
            child: Text(
              displayRole.toString().toUpperCase(),
              style: const TextStyle(
                color: AppColors.superAdminPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Contact Information Section
        _buildSectionTitle('Contact Information'),
        const SizedBox(height: 12),
        _buildInfoCard(Icons.email, 'Email', displayEmail),
        const SizedBox(height: 8),
        _buildInfoCard(Icons.phone, 'Phone', displayPhone),
        const SizedBox(height: 24),

        // Account Status Section
        _buildSectionTitle('Account Status'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    displayIsActive ? Icons.check_circle : Icons.cancel,
                    color: displayIsActive ? AppColors.success : AppColors.error,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        displayIsActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: displayIsActive ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Switch(
                value: displayIsActive,
                activeTrackColor: AppColors.success.withValues(alpha: 0.5),
                thumbColor: WidgetStateProperty.all(
                  displayIsActive ? AppColors.success : Colors.grey,
                ),
                onChanged: (value) {
                  context.read<UserManagementBloc>().add(
                    ChangeUserStatus(
                      userId: displayUserId,
                      isActive: value,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Change Role Section
        _buildSectionTitle('Change Role'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select New Role',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['EXECUTIVE', 'ADMIN', 'SUPERADMIN'].map((role) {
                  final isCurrentRole = role == displayRole.toString().toUpperCase();
                  return ChoiceChip(
                    label: Text(role),
                    selected: isCurrentRole,
                    selectedColor: AppColors.superAdminPrimary,
                    labelStyle: TextStyle(
                      color: isCurrentRole ? Colors.white : Colors.black87,
                      fontWeight: isCurrentRole ? FontWeight.w600 : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected && !isCurrentRole) {
                        // Confirm role change
                        showDialog(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Confirm Role Change'),
                            content: Text(
                              'Are you sure you want to change the role from $displayRole to $role?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                  context.read<UserManagementBloc>().add(
                                    ChangeUserRole(
                                      userId: displayUserId,
                                      role: role,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.superAdminPrimary,
                                ),
                                child: const Text('Confirm', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A202C),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.superAdminPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A202C),
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

class _UserCard extends StatelessWidget {
  final Data user;
  final int index;
  final bool isPending;
  final VoidCallback? onTap;

  const _UserCard({
    required this.user,
    required this.index,
    required this.isPending,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = user.isActive ?? false;
    final hasRoles = (user.roles ?? []).isNotEmpty;

    return InkWell(
      onTap: onTap,
      child: Container(
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
            ])
      )
      ) );

  }
}


