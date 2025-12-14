import 'package:flutter/material.dart';
import 'package:apclassstone/api/models/models.dart';
import './executive_dashboard.dart';

class ExecutiveDashboardScreen extends StatelessWidget {
  final String user;

  const ExecutiveDashboardScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return ExecutiveDashboard(user: user);
  }
}
