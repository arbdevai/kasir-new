import 'package:flutter/material.dart';

class PosShellScreen extends StatelessWidget {
  const PosShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kasir POS')),
      body: const Center(
        child: Text('Modul POS & Katalog (Shell)'),
      ),
    );
  }
}
