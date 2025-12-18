import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../api/models/response/AllUsersResponseBody.dart';
import '../../../../bloc/registration/registration_bloc.dart';
import '../../../../bloc/registration/registration_event.dart';
import '../../../../bloc/registration/registration_state.dart';
import '../../../../bloc/dashboard/dashboard_bloc.dart';
import '../../../../bloc/dashboard/dashboard_event.dart';
import '../../../../bloc/dashboard/dashboard_state.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primaryTealDark,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.08 * 255).toInt()),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: true,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.13 * 255).toInt()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  onPressed: () {
                     context.pop();
                  },
                  tooltip: 'Back',
                ),
              ),
            ),
            title: const Text(
              'All Users',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: -0.5,
              ),
            ),
            centerTitle: true,
          ),
        ),
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
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final user = items[index];
                return _UserCard(
                  user: user,
                  index: index,
                  isPending: false,
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

class _UserCard extends StatelessWidget {
  final Data user;
  final int index;
  final bool isPending;
  const _UserCard({required this.user, required this.index, required this.isPending});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.white : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.04 * 255).toInt()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            child: Text(
              (user.fullName ?? '?').isNotEmpty ? user.fullName![0].toUpperCase() : '?',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName ?? '-',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email ?? '',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF718096)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
