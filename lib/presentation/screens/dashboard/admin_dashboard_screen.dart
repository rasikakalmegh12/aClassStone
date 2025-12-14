import 'package:flutter/material.dart';

import './admin_dashboard.dart';

class AdminDashboardScreen extends StatelessWidget {
  final String user;

  const AdminDashboardScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return AdminDashboard(user: user);
  }
}
