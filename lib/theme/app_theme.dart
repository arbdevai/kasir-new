import 'package:flutter/material.dart';

class AppColors {
  // Brand Orange Accent (Hermès / iOS Sunset Orange)
  static const Color primary = Color(0xFFFF6B00);
  static const Color primaryDark = Color(0xFFE05600);
  static const Color primarySubtle = Color(0xFFFFF0E6);
  static const Color primaryGlow = Color(0x29FF6B00);

  // Backgrounds & Surfaces (iOS Light Ceramic)
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF1F3F5);
  static const Color surfaceGlass = Color(0xEBFFFFFF);

  // Borders & Dividers
  static const Color border = Color(0xFFE9ECEF);
  static const Color borderLight = Color(0x1A000000);
  static const Color divider = Color(0xFFEDF0F2);

  // Text Hierarchy
  static const Color textPrimary = Color(0xFF1A1C1E);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textMuted = Color(0xFF9EA3A8);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Status & Semantic Tokens (iOS Standard)
  static const Color success = Color(0xFF34C759);
  static const Color successSubtle = Color(0xFFE8F9ED);
  static const Color warning = Color(0xFFFF9500);
  static const Color warningSubtle = Color(0xFFFFF4E5);
  static const Color danger = Color(0xFFFF3B30);
  static const Color dangerSubtle = Color(0xFFFFEBEA);
  static const Color info = Color(0xFF007AFF);
  static const Color infoSubtle = Color(0xFFE5F2FF);
  static const Color purple = Color(0xFF5856D6);
  static const Color purpleSubtle = Color(0xFFEFEFFC);
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.textInverse,
        primaryContainer: AppColors.primarySubtle,
        onPrimaryContainer: AppColors.primaryDark,
        secondary: AppColors.primaryDark,
        onSecondary: AppColors.textInverse,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.danger,
        onError: AppColors.textInverse,
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0.5,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textInverse,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
    );
  }
}

class FormatUtils {
  static String formatRupiah(num amount) {
    final int value = amount.round();
    final bool isNegative = value < 0;
    final String absStr = value.abs().toString();

    final StringBuffer buffer = StringBuffer();
    int count = 0;
    for (int i = absStr.length - 1; i >= 0; i--) {
      buffer.write(absStr[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write('.');
      }
    }
    final String formatted = buffer.toString().split('').reversed.join('');
    return '${isNegative ? '-' : ''}Rp $formatted';
  }

  static String formatCompact(num amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}jt';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}k';
    }
    return amount.toString();
  }

  static String formatDateTime(DateTime dt) {
    final String day = dt.day.toString().padLeft(2, '0');
    final String month = _monthName(dt.month);
    final String year = dt.year.toString();
    final String hour = dt.hour.toString().padLeft(2, '0');
    final String minute = dt.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$minute';
  }

  static String formatDateShort(DateTime dt) {
    final String day = dt.day.toString().padLeft(2, '0');
    final String month = _monthName(dt.month);
    return '$day $month';
  }

  static String formatTime(DateTime dt) {
    final String hour = dt.hour.toString().padLeft(2, '0');
    final String minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String _monthName(int month) {
    const List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }
}
