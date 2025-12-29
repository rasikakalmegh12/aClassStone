import 'package:apclassstone/presentation/widgets/app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../api/models/request/GetProfileRequestBody.dart';
import '../../../bloc/user_profile/user_profile_bloc.dart';
import '../../../bloc/user_profile/user_profile_event.dart';
import '../../../bloc/user_profile/user_profile_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/session/session_manager.dart';

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

class _UserProfileView extends StatefulWidget {
  const _UserProfileView();

  @override
  State<_UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<_UserProfileView> {
  Map<String, Color> _paletteForRole(String role) {
    // returns a small mapping of colors for header, lightBg and accent
    if (role == AppConstants.roleAdmin) {
      return {
        'header': AppColors.primaryGold,
        'light': AppColors.primaryGoldLight,
        'accent': AppColors.accentAmber,
      };
    }

    if (role == AppConstants.roleExecutive) {
      return {
        'header': AppColors.primaryTeal,
        'light': AppColors.primaryTealLight,
        'accent': AppColors.accentGreen,
      };
    }

    // default: superadmin
    return {
      'header': AppColors.superAdminPrimary,
      'light': AppColors.superAdminCard,
      'accent': AppColors.superAdminAccent,
    };
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("session role ${SessionManager.getUserRoleForPermissions()}");
    final role = SessionManager.getUserRoleForPermissions().toString().trim().toLowerCase();
   print("role (permissions): $role");

  }
  @override
  Widget build(BuildContext context) {
    // Use getUserRoleForPermissions() which returns a normalized role string
    // ('superadmin' | 'admin' | 'executive') — safer than raw stored value.
    final role = SessionManager.getUserRoleForPermissions().toString().trim().toLowerCase();
    if (kDebugMode) print("role (permissions): $role");

    final palette = _paletteForRole(role);
    final Color headerColor = palette['header']!;
    final Color headerLight = palette['light']!;
    final Color accentColor = palette['accent']!;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        // pass headerColor to the custom app bar
        child: CoolAppCard(title: "My Profile", backgroundColor: headerColor),
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
            return _ProfileContent(
              user: user,
              headerColor: headerColor,
              headerLight: headerLight,
              accentColor: accentColor,
            );
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

class _ProfileContent extends StatefulWidget {
  final dynamic user;
  final Color headerColor;
  final Color headerLight;
  final Color accentColor;

  const _ProfileContent({
    required this.user,
    required this.headerColor,
    required this.headerLight,
    required this.accentColor,
  });

  @override
  State<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<_ProfileContent> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late String _originalName;
  late String _originalPhone;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _originalName = widget.user.fullName ?? '';
    _originalPhone = widget.user.phone ?? '';
    _nameCtrl = TextEditingController(text: _originalName);
    _phoneCtrl = TextEditingController(text: _originalPhone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  void _cancelEditing() {
    setState(() {
      _nameCtrl.text = _originalName;
      _phoneCtrl.text = _originalPhone;
      _isEditing = false;
    });
  }

  void _saveChanges() {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    if (name.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name must be at least 3 characters')));
      return;
    }
    if (phone.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid phone number')));
      return;
    }

    final req = GetProfileRequestBody(fullName: name, phone: phone);
    context.read<UserProfileBloc>().add(UpdateUserProfileEvent(requestBody: req));

    // update local originals and exit edit mode
    setState(() {
      _originalName = name;
      _originalPhone = phone;
      _isEditing = false;
    });
  }

  String _getInitials(String? name) {
    final n = name ?? '';
    final parts = n.trim().split(' ').where((e) => e.isNotEmpty).toList(growable: false);
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final created = DateTime.tryParse(widget.user.createdAt ?? '') ?? DateTime.now();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    const animDuration = Duration(milliseconds: 300);

    // Modern, centered avatar with clean details card below
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Centered avatar with small edit overlay
          Center(
            child: AnimatedScale(
              scale: _isEditing ? 1.04 : 1.0,
              duration: animDuration,
              curve: Curves.easeOutBack,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: widget.headerColor,
                    child: Text(
                      _getInitials(_originalName),
                      style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Main details card (animated for subtle elevation change when editing)
          AnimatedContainer(
            duration: animDuration,
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: widget.headerLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: widget.headerColor.withAlpha((0.10 * 255).toInt())),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(_isEditing ? 18 : 10),
                  blurRadius: _isEditing ? 22 : 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row with title and edit toggle on the right
                Row(
                  children: [
                    Expanded(
                      child: Text('Profile', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _isEditing = !_isEditing),
                      icon: Icon(_isEditing ? Icons.close_rounded : Icons.edit_outlined, color: widget.headerColor),
                      tooltip: _isEditing ? 'Cancel edit' : 'Edit profile',
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Name
                const SizedBox(height: 4),
                Text('Name', style: theme.textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant)),
                const SizedBox(height: 6),
                AnimatedSwitcher(
                  duration: animDuration,
                  switchInCurve: Curves.easeOut, switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: SizeTransition(sizeFactor: anim, axis: Axis.vertical, child: child)),
                  child: _isEditing
                      ? SizedBox(
                          key: const ValueKey('name_edit'),
                          height: 48,
                          child: TextField(
                            controller: _nameCtrl,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withAlpha(10),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            ),
                          ),
                        )
                      : Padding(
                          key: const ValueKey('name_view'),
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(_originalName.isEmpty ? 'Unnamed user' : _originalName, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                        ),
                ),

                const SizedBox(height: 12),

                // Email (read-only)
                Text('Email', style: theme.textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant)),
                const SizedBox(height: 6),
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: animDuration,
                  child: Text(widget.user.email ?? '-', style: theme.textTheme.bodyMedium),
                ),

                const SizedBox(height: 12),

                // Phone
                Text('Phone', style: theme.textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant)),
                const SizedBox(height: 6),
                AnimatedSwitcher(
                  duration: animDuration,
                  transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: SizeTransition(sizeFactor: anim, axis: Axis.vertical, child: child)),
                  child: _isEditing
                      ? SizedBox(
                          key: const ValueKey('phone_edit'),
                          height: 48,
                          child: TextField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            decoration: InputDecoration(
                              counterText: "",
                              filled: true,
                              fillColor: Colors.white.withAlpha(10),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            ),
                          ),
                        )
                      : Padding(
                          key: const ValueKey('phone_view'),
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(widget.user.phone ?? '-', style: theme.textTheme.bodyMedium),
                        ),
                ),

                const SizedBox(height: 12),

                // Status and role
                Row(
                  children: [
                    _StatusBadge(isActive: widget.user.isActive == true, activeColor: widget.accentColor, inactiveColor: AppColors.error),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: widget.headerColor.withAlpha((0.12 * 255).toInt()),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        SessionManager.getUserRoleForPermissions().toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(color: widget.headerColor, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Secondary info card
          Card(
            elevation: 0,
            color: widget.headerLight,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Member since', style: theme.textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant)),
                      const SizedBox(height: 6),
                      Text('${created.day.toString().padLeft(2, '0')}/${created.month.toString().padLeft(2, '0')}/${created.year}', style: theme.textTheme.bodyMedium),
                    ],
                  ),

                ],
              ),
            ),
          ),

          const SizedBox(height: 22),

          // Actions
          Align(
            alignment: Alignment.centerRight,
            child: AnimatedSwitcher(
              duration: animDuration,
              transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: ScaleTransition(scale: anim, child: child)),
              child: _isEditing
                  ? Row(
                      key: const ValueKey('actions_edit'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton(onPressed: _cancelEditing, child: const Text('Cancel')),
                        const SizedBox(width: 10),
                        FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: widget.headerColor, foregroundColor: Colors.white),
                          onPressed: _saveChanges,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                            child: Text('Save'),
                          ),
                        ),
                      ],
                    )
                  : FilledButton.icon(
                      key: const ValueKey('actions_view'),
                      onPressed: _startEditing,
                      icon: const Icon(Icons.edit_outlined, color: Colors.white),
                      label: const Text('Edit details'),
                      style: FilledButton.styleFrom(backgroundColor: widget.headerColor, foregroundColor: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  final Color? activeColor;
  final Color? inactiveColor;

  const _StatusBadge({required this.isActive, this.activeColor, this.inactiveColor});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final Color active = activeColor ?? colors.primary;
    final Color inactive = inactiveColor ?? colors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? active.withAlpha((0.08 * 255).toInt())
            : inactive.withAlpha((0.08 * 255).toInt()),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'Active account' : 'Inactive',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: isActive ? active : inactive,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
