import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:apclassstone/api/models/models.dart';
import '../../../bloc/bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

import '../../widgets/custom_button.dart';
import '../auth/login_screen.dart';
import '../executive/dashboard/executive_home_dashboard.dart';

class ExecutiveDashboard extends StatelessWidget {
  final String user;

  const ExecutiveDashboard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    // Redirect to the new professional dashboard
    return ExecutiveHomeDashboard(user: user);
  }
}
