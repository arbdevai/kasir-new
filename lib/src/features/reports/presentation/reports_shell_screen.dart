import 'package:flutter/material.dart';

class ReportsShellScreen extends StatelessWidget {
  const ReportsShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laporan')),
      body: const Center(
        child: Text('Laporan dan analitik (Shell)'),
      ),
    );
  }
}
