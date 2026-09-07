import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_router.dart';

class KasirApp extends StatelessWidget {
  const KasirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kasir New',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
    );
  }
}
