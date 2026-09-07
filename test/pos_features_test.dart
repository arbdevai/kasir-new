import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kasir_new/kasir_services.dart';

void main() {
  group('PosState barcode scanning', () {
    test('finds matching product by barcode or SKU and ignores empty strings', () {
      final state = PosState.sample();
      expect(state.findProductByBarcode(''), isNull);
      expect(state.findProductByBarcode('   '), isNull);
      expect(state.findProductByBarcode('UNKNOWN_CODE'), isNull);

      final foundByBarcode = state.findProductByBarcode('8991001001');
      expect(foundByBarcode, isNotNull);
      expect(foundByBarcode!.name, 'Kopi Susu Gula Aren');

      final foundBySku = state.findProductByBarcode('kop-002');
      expect(foundBySku, isNotNull);
      expect(foundBySku!.id, 'p2');
    });

    test('addScannedBarcode adds item safely and rejects unknown barcode', () {
      final state = PosState.sample();
      state.clearCart();
      expect(state.cart, isEmpty);

      final added = state.addScannedBarcode('8991001001');
      expect(added, isTrue);
      expect(state.cart.length, 1);
      expect(state.cart.first.product.id, 'p1');

      final unknownAdded = state.addScannedBarcode('does-not-exist');
      expect(unknownAdded, isFalse);
      expect(state.cart.length, 1);
    });
  });

  group('Versioned JSON .kasir backup and restore', () {
    test('creates backup with valid magic, version, and matching checksum', () async {
      final state = PosState.sample();
      final service = VersionedJsonBackupService(state);
      final artifact = await service.createBackup();

      expect(artifact.fileName, 'kasir-backup.kasir');
      expect(artifact.bytes, isNotEmpty);

      final decoded = jsonDecode(utf8.decode(artifact.bytes)) as Map<String, dynamic>;
      expect(decoded['magic'], VersionedJsonBackupService.magic);
      expect(decoded['version'], VersionedJsonBackupService.version);
      expect((decoded['checksum'] as String).length, 64);
      expect(decoded['payload'], isA<Map<String, dynamic>>());

      final validation = await service.validateBackup(artifact.bytes);
      expect(validation.isValid, isTrue);
    });

    test('rejects tampered checksum, bad magic, or empty data', () async {
      final state = PosState.sample();
      final service = VersionedJsonBackupService(state);
      final artifact = await service.createBackup();

      final emptyVal = await service.validateBackup(Uint8List(0));
      expect(emptyVal.isValid, isFalse);

      final decoded = jsonDecode(utf8.decode(artifact.bytes)) as Map<String, dynamic>;

      final badMagic = Map<String, dynamic>.from(decoded)..['magic'] = 'WRONG_MAGIC';
      final magicVal = await service.validateBackup(Uint8List.fromList(utf8.encode(jsonEncode(badMagic))));
      expect(magicVal.isValid, isFalse);

      final tampered = Map<String, dynamic>.from(decoded)..['checksum'] = '0' * 64;
      final checksumVal = await service.validateBackup(Uint8List.fromList(utf8.encode(jsonEncode(tampered))));
      expect(checksumVal.isValid, isFalse);
    });

    test('roundtrips active PosState in memory without leaking mutations', () async {
      final original = PosState.sample();
      original.activeCustomerName = 'Pelanggan Uji';
      original.activeTableNumber = 'Meja 42';

      final service = VersionedJsonBackupService(original);
      final artifact = await service.createBackup();

      final target = PosState.sample();
      target.activeCustomerName = 'Lain';
      target.products.clear();
      expect(target.products, isEmpty);

      await VersionedJsonBackupService(target).restoreBackup(artifact.bytes);
      expect(target.activeCustomerName, 'Pelanggan Uji');
      expect(target.activeTableNumber, 'Meja 42');
      expect(target.products.length, original.products.length);
      expect(target.transactions.length, original.transactions.length);
    });
  });

  group('Report export service', () {
    test('exports CSV with proper header and escaped cells', () {
      final state = PosState.sample();
      const service = ReportExportService();
      final artifact = service.exportCsv(state.transactions);

      expect(artifact.contentType, contains('text/csv'));
      expect(artifact.text, contains('Invoice,Tanggal,Pelanggan'));
      expect(artifact.text, contains(state.transactions.first.invoiceNumber));
    });

    test('exports text report summarizing counts and transactions', () {
      final state = PosState.sample();
      const service = ReportExportService();
      final artifact = service.exportText(state.transactions);

      expect(artifact.contentType, contains('text/plain'));
      expect(artifact.text, contains('LAPORAN TRANSAKSI KASIR'));
      expect(artifact.text, contains('Jumlah transaksi: ${state.transactions.length}'));
    });
  });
}
