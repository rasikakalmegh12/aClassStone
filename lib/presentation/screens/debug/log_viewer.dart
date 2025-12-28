import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class LogViewerScreen extends StatefulWidget {
  const LogViewerScreen({super.key});

  @override
  State<LogViewerScreen> createState() => _LogViewerScreenState();
}

class _LogViewerScreenState extends State<LogViewerScreen> {
  Future<String> _readLog() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final f = File('${dir.path}/location_ping_logs.txt');
      if (!await f.exists()) return 'No logs found.';
      final content = await f.readAsString();
      return content;
    } catch (e) {
      return 'Error reading logs: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Location Logs'),
      ),
      body: FutureBuilder<String>(
        future: _readLog(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final text = snapshot.data ?? 'No logs';
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: SelectableText(
              text,
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          );
        },
      ),
    );
  }
}

