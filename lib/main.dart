import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/settings_repository.dart';
import 'screens/app_shell.dart';
import 'state/pos_state.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SettingsRepository? settingsRepository;
  try {
    final prefs = await SharedPreferences.getInstance();
    settingsRepository = SettingsRepository(prefs);
  } catch (_) {
    // Keep in-memory defaults if SharedPreferences is unavailable in the environment.
  }
  runApp(KasirApp(settingsRepository: settingsRepository));
}

class KasirApp extends StatefulWidget {
  final SettingsRepository? settingsRepository;
  final PosState? initialState;

  const KasirApp({
    super.key,
    this.settingsRepository,
    this.initialState,
  });

  @override
  State<KasirApp> createState() => _KasirAppState();
}

class _KasirAppState extends State<KasirApp> {
  late final PosState posState;

  @override
  void initState() {
    super.initState();
    final providedState = widget.initialState;
    if (providedState != null) {
      posState = providedState;
    } else {
      final repo = widget.settingsRepository;
      posState = repo != null ? createPosState(repo) : PosState.sample();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kasir',
      theme: AppTheme.light(),
      home: AppShell(state: posState),
    );
  }
}
