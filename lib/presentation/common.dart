import 'package:apclassstone/presentation/widgets/app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../api/models/request/GetProfileRequestBody.dart';
import '../bloc/user_profile/user_profile_bloc.dart';
import '../bloc/user_profile/user_profile_event.dart';
import '../bloc/user_profile/user_profile_state.dart';
import '../core/constants/app_colors.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserProfileBloc()..add(LoadUserProfileEvent()),
      child: const _UserProfileView(),
    );
  }
}

class _UserProfileView extends StatelessWidget {
  const _UserProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: CoolAppCard(title: "My Profile",backgroundColor: AppColors.primaryGold)
      ),
      body: BlocConsumer<UserProfileBloc, UserProfileState>(
        listener: (context, state) {
          if (state is UserProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
          if (state is UserProfileUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully')),
            );
          }
        },
        builder: (context, state) {
          if (state is UserProfileLoading || state is UserProfileInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UserProfileLoaded || state is UserProfileUpdated) {
            final user = (state as dynamic).user.data; // GetProfileResponseBody.data
            return _ProfileContent(user: user);
          }

          if (state is UserProfileError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 8),
                  Text(state.error),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context
                        .read<UserProfileBloc>()
                        .add(LoadUserProfileEvent()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
class _ProfileContent extends StatelessWidget {
  final dynamic user;

  const _ProfileContent({required this.user});

  @override
  Widget build(BuildContext context) {
    final created = DateTime.tryParse(user.createdAt ?? '') ?? DateTime.now();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: colors.surfaceVariant,
                  child: Text(
                    _getInitials(user.fullName),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName ?? '',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _StatusBadge(isActive: user.isActive == true),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _openEditSheet(context, user),
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit profile',
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: colors.outlineVariant),
            ),
            child: Column(
              children: [
                _InfoTile(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: user.phone ?? '-',
                ),
                const Divider(height: 0),
                _InfoTile(
                  icon: Icons.calendar_today_outlined,
                  label: 'Member since',
                  value:
                  '${created.day.toString().padLeft(2, '0')}/'
                      '${created.month.toString().padLeft(2, '0')}/'
                      '${created.year}',
                ),
                const Divider(height: 0),
                _InfoTile(
                  icon: Icons.vpn_key_outlined,
                  label: 'User ID',
                  value: user.id ?? '',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () => _openEditSheet(context, user),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit details'),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String? name) {
    final n = name ?? '';
    final parts =
    n.trim().split(' ').where((e) => e.isNotEmpty).toList(growable: false);
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Future<void> _openEditSheet(BuildContext context, dynamic user) async {
    final result = await showModalBottomSheet<GetProfileRequestBody>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => EditProfileSheet(
        initialFullName: user.fullName,
        initialPhone: user.phone,
      ),
    );

    if (result != null && context.mounted) {
      context
          .read<UserProfileBloc>()
          .add(UpdateUserProfileEvent(requestBody: result));
    }
  }
}



class EditProfileSheet extends StatefulWidget {
  final String? initialFullName;
  final String? initialPhone;

  const EditProfileSheet({
    super.key,
    this.initialFullName,
    this.initialPhone,
  });

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.initialFullName ?? '');
    _phoneController =
        TextEditingController(text: widget.initialPhone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(
      context,
      GetProfileRequestBody(
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 20, bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Edit profile',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full name',
                    ),
                    validator: (v) =>
                    v == null || v.trim().length < 3
                        ? 'Enter a valid name'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone number',
                    ),
                    validator: (v) =>
                    v == null || v.trim().length < 8
                        ? 'Enter a valid phone'
                        : null,
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _submit,
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(label),
      subtitle: Text(
        value,
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}


class _StatusBadge extends StatelessWidget {
  final bool isActive;

  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? colors.primary.withOpacity(.08)
            : colors.error.withOpacity(.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'Active account' : 'Inactive',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: isActive ? colors.primary : colors.error,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}


