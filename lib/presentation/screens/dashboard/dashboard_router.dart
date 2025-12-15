import 'package:apclassstone/presentation/screens/super_admin/screens/super_admin_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import 'executive_dashboard.dart';

class DashboardRouter extends StatelessWidget {
  final String user;

  const DashboardRouter({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    switch (user) {
      case AppConstants.roleExecutive:
        return ExecutiveDashboard(user: user);

      case AppConstants.roleAdmin:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.goNamed('admin-dashboard', extra: user);
        });
        return const SizedBox.shrink();

      case AppConstants.roleSuperAdmin:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.goNamed('superadmin-dashboard', extra: user);
        });
        return const SizedBox.shrink();

      default:
        return ExecutiveDashboard(user: user);
    }
  }
}
