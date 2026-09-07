import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kasir_new/kasir_services.dart';
import 'package:kasir_new/models/models.dart';
import 'package:kasir_new/state/pos_state.dart';

void main() {
  group('User account management (Task 16)', () {
    test('addUserAccount validates name and 4-6 digit numeric PIN', () {
      final state = PosState.sample();
      final initialCount = state.users.length;

      expect(state.addUserAccount(name: '  ', role: UserRole.cashier, pin: '1234'), isFalse);
      expect(state.addUserAccount(name: 'Kasir Baru', role: UserRole.cashier, pin: '123'), isFalse);
      expect(state.addUserAccount(name: 'Kasir Baru', role: UserRole.cashier, pin: '1234567'), isFalse);
      expect(state.addUserAccount(name: 'Kasir Baru', role: UserRole.cashier, pin: 'abcd'), isFalse);
      expect(state.users.length, initialCount);

      expect(state.addUserAccount(name: 'Kasir Baru', role: UserRole.cashier, pin: '4321'), isTrue);
      expect(state.users.length, initialCount + 1);
      final added = state.users.last;
      expect(added.name, 'Kasir Baru');
      expect(added.role, UserRole.cashier);
      expect(added.pin, '4321');
      expect(added.isActive, isTrue);
    });

    test('updateUserAccount edits fields and rejects invalid input', () {
      final state = PosState.sample();
      final target = state.users.firstWhere((u) => u.role == UserRole.cashier);

      expect(state.updateUserAccount('unknown', name: 'X'), isFalse);
      expect(state.updateUserAccount(target.id, name: '   '), isFalse);
      expect(state.updateUserAccount(target.id, pin: '12ab'), isFalse);
      expect(state.transactions, isNotEmpty);

      expect(
        state.updateUserAccount(
          target.id,
          name: 'Kasir Update',
          role: UserRole.manager,
          pin: '9876',
        ),
        isTrue,
      );
      final updated = state.users.firstWhere((u) => u.id == target.id);
      expect(updated.name, 'Kasir Update');
      expect(updated.role, UserRole.manager);
      expect(updated.pin, '9876');
    });

    test('toggleUserStatus flips active state and keeps current user usable', () {
      final state = PosState.sample();
      final target = state.users.firstWhere((u) => u.id != state.currentUser.id);
      final initial = target.isActive;

      expect(state.toggleUserStatus(target.id), isTrue);
      expect(state.users.firstWhere((u) => u.id == target.id).isActive, !initial);
      expect(state.toggleUserStatus('unknown'), isFalse);
    });
  });

  group('Total data reset (Task 17)', () {
    test('resetTotalData rejects wrong PIN and clears everything on owner PIN', () async {
      final state = PosState.sample();
      expect(state.transactions, isNotEmpty);
      expect(state.currentShift, isNotNull);

      state.addToCart(state.products.first);
      expect(state.cart, isNotEmpty);

      expect(state.resetTotalData(ownerPin: '0000'), isFalse);
      expect(state.transactions, isNotEmpty);

      expect(state.resetTotalData(ownerPin: '1234'), isTrue);
      expect(state.transactions, isEmpty);
      expect(state.cart, isEmpty);
      expect(state.stockMutations, isEmpty);
      expect(state.currentShift, isNull);
      expect(state.pastShifts, isEmpty);
      expect(state.products, isNotEmpty);
      expect(state.categories, isNotEmpty);
      expect(state.orderDiscountPercent, 0.0);
      expect(state.orderDiscountNominal, 0.0);
      expect(state.activeCustomerName, isEmpty);
      expect(state.activeTableNumber, isEmpty);
      expect(state.activeOrderNote, isEmpty);
      expect(state.storeProfile.name, const StoreProfile().name);
      expect(state.selectedPrinterName, const PrinterSettings().name);
    });
  });

  group('Import / restore backup (Task 18)', () {
    test('validateBackup accepts fresh backup and restore rehydrates state', () async {
      final original = PosState.sample();
      original.activeCustomerName = 'Pelanggan Restore';
      final service = VersionedJsonBackupService(original);
      final artifact = await service.createBackup();

      final target = PosState.sample();
      target.activeCustomerName = 'Berbeda';
      target.products.clear();
      expect(target.products, isEmpty);

      final targetService = VersionedJsonBackupService(target);
      final validation = await targetService.validateBackup(artifact.bytes);
      expect(validation.isValid, isTrue);

      await targetService.restoreBackup(artifact.bytes);
      expect(target.activeCustomerName, 'Pelanggan Restore');
      expect(target.products.length, original.products.length);
      expect(target.transactions.length, original.transactions.length);
      expect(target.users.length, original.users.length);
    });

    test('validateBackup rejects tampered, empty, and malformed payloads', () async {
      final state = PosState.sample();
      final service = VersionedJsonBackupService(state);
      final artifact = await service.createBackup();
      final decoded = jsonDecode(utf8.decode(artifact.bytes)) as Map<String, dynamic>;

      expect((await service.validateBackup(Uint8List(0))).isValid, isFalse);
      expect(
        (await service.validateBackup(Uint8List.fromList(utf8.encode('bukan json')))).isValid,
        isFalse,
      );

      final tampered = Map<String, dynamic>.from(decoded)..['checksum'] = '0' * 64;
      expect(
        (await service.validateBackup(Uint8List.fromList(utf8.encode(jsonEncode(tampered))))).isValid,
        isFalse,
      );

      final badMagic = Map<String, dynamic>.from(decoded)..['magic'] = 'SALAH';
      expect(
        (await service.validateBackup(Uint8List.fromList(utf8.encode(jsonEncode(badMagic))))).isValid,
        isFalse,
      );
    });
  });
}
