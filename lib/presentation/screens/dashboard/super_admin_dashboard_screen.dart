import 'package:flutter/material.dart';
import '../../../api/models/models.dart';
import './super_admin_dashboard.dart';

class SuperAdminDashboardScreen extends StatelessWidget {
  final String user;

  const SuperAdminDashboardScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return SuperAdminDashboard(user: user);
  }
}
