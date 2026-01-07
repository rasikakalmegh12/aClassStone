import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MeetingDetailScreen extends StatelessWidget {
  final String meetingId;

  const MeetingDetailScreen({
    super.key,
    required this.meetingId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Details'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.meeting_room,
              size: 100,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Meeting Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Meeting ID: $meetingId',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Meeting details will be displayed here',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
