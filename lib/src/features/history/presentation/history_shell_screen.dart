import 'package:flutter/material.dart';

class HistoryShellScreen extends StatelessWidget {
  const HistoryShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat')),
      body: const Center(
        child: Text('Riwayat transaksi (Shell)'),
      ),
    );
  }
}
