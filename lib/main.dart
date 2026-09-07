import 'package:flutter/material.dart';

import 'screens/app_shell.dart';
import 'state/pos_state.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const KasirApp());
}

class KasirApp extends StatefulWidget {
  const KasirApp({super.key});

  @override
  State<KasirApp> createState() => _KasirAppState();
}

class _KasirAppState extends State<KasirApp> {
  final PosState posState = PosState.sample();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: posState,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Kasir',
        theme: AppTheme.light(),
        home: AppShell(state: posState),
      ),
    );
  }
}
