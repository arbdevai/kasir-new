import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kasir_new/data/settings_repository.dart';
import 'package:kasir_new/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('store profile and printer settings round trip through preferences', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = SettingsRepository(await SharedPreferences.getInstance());
    final profile = const StoreProfile(
      name: 'Toko Baru',
      tagline: 'Kopi harian',
      isTaxEnabled: true,
    );
    const printer = PrinterSettings(
      name: 'Printer Dapur',
      paperSize: '80mm',
      isConnected: false,
    );

    expect(await repository.saveStoreProfile(profile), isTrue);
    expect(await repository.savePrinterSettings(printer), isTrue);
    expect(repository.loadStoreProfile().toMap(), profile.toMap());
    expect(repository.loadPrinterSettings().toMap(), printer.toMap());
  });

  test('missing and malformed settings return model defaults', () async {
    SharedPreferences.setMockInitialValues({
      'settings.store_profile': '{bad json',
      'settings.printer': jsonEncode({'is_connected': 0}),
    });
    final repository = SettingsRepository(await SharedPreferences.getInstance());

    expect(repository.loadStoreProfile().name, const StoreProfile().name);
    expect(repository.loadPrinterSettings().isConnected, isFalse);
    expect(repository.loadPrinterSettings().paperSize, const PrinterSettings().paperSize);
  });
}
