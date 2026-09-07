import 'package:flutter/material.dart';

class SettingsShellScreen extends StatelessWidget {
  const SettingsShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: const Center(
        child: Text('Pengaturan sistem dan profil toko (Shell)'),
      ),
    );
  }
}
