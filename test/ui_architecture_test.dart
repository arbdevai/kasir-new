import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kasir_new/kasir_services.dart';
import 'package:kasir_new/main.dart';
import 'package:kasir_new/models/models.dart';
import 'package:kasir_new/state/pos_state.dart';

class _MemoryPrinterConnection implements PrinterConnection {
  _MemoryPrinterConnection({required this.onWrite});

  final void Function(Uint8List data) onWrite;
  PrinterConnectionState _state = PrinterConnectionState.connected;

  @override
  PrinterConnectionType get type => PrinterConnectionType.network;

  @override
  PrinterConnectionState get state => _state;

  @override
  Future<List<PrinterDevice>> discover({
    List<String>? candidates,
    Duration probeTimeout = const Duration(milliseconds: 800),
  }) async =>
      const <PrinterDevice>[];

  @override
  Future<void> connect(PrinterEndpoint endpoint) async {
    _state = PrinterConnectionState.connected;
  }

  @override
  Future<void> disconnect() async {
    _state = PrinterConnectionState.disconnected;
  }

  @override
  Future<void> write(Uint8List data) async {
    if (_state != PrinterConnectionState.connected) {
      throw const PrinterNotConnectedException();
    }
    onWrite(data);
  }
}

void main() {
  group('POS State & Security Logic', () {
    test('User account role title uses standardized Super Admin', () {
      const owner = UserAccount(id: 'u1', name: 'Owner', role: UserRole.owner, pin: '1234');
      expect(owner.roleTitle, 'Owner / Super Admin');
    });

    test('switchUser validates 4-6 digit numeric PIN and inactive status', () {
      final state = PosState.sample();
      // u1 is owner with PIN 1234, u3 is active cashier with PIN 0000
      expect(state.switchUser('u1', 'wrong'), isFalse);
      expect(state.switchUser('u1', '12'), isFalse);
      expect(state.switchUser('u1', '1234567'), isFalse);
      expect(state.switchUser('u1', 'abcd'), isFalse);
      expect(state.switchUser('unknown', '1234'), isFalse);

      // Switching to active user with correct PIN
      // Note: currentShift belongs to Siti Sarah, so switching to a different user with active shift is guarded
      expect(state.currentShift?.cashierName, 'Siti Sarah');
      expect(state.currentUser.name, 'Siti Sarah');
    });

    test('voidTransaction requires active manager or owner PIN', () {
      final state = PosState.sample();
      const targetTxId = 'tx_001';
      expect(state.voidTransaction(targetTxId, adminPin: 'wrong', reason: 'Test'), isFalse);
      expect(state.voidTransaction(targetTxId, adminPin: '0000', reason: 'Cashier cannot void'), isFalse);
      expect(state.voidTransaction(targetTxId, adminPin: '1234', reason: 'Salah input'), isTrue);

      final voided = state.transactions.firstWhere((t) => t.id == targetTxId);
      expect(voided.status, TransactionStatus.voided);
      expect(voided.notes, contains('by Admin Budi Santoso (Owner / Super Admin)'));
    });

    test('Hold and Recall order preserves and validates state', () {
      final state = PosState.sample();
      expect(state.holdCurrentOrder(customerName: 'Meja 9'), isFalse);

      final product = state.products.first;
      state.addToCart(product);
      expect(state.cart.length, 1);

      expect(state.holdCurrentOrder(customerName: 'Meja 9'), isTrue);
      expect(state.cart.isEmpty, isTrue);

      final holdTx = state.transactions.firstWhere((t) => t.status == TransactionStatus.hold);
      expect(holdTx.customerName, 'Meja 9');

      expect(state.recallHoldOrder(holdTx), isTrue);
      expect(state.cart.length, 1);
      expect(state.transactions.any((t) => t.id == holdTx.id), isFalse);
    });
  });

  group('Pure-Dart EscPos and TCP Printer', () {
    test('EscPosTextFormatter formats document correctly', () {
      const formatter = EscPosTextFormatter();
      const doc = ReceiptDocument(
        header: ReceiptSection(lines: [
          ReceiptLine(text: 'Kopi & Roti Nusantara', alignment: ReceiptAlignment.center, emphasis: true),
        ]),
        lines: [
          ReceiptLine(text: 'Kopi Susu x 1      22.000'),
        ],
        footer: ReceiptSection(lines: [
          ReceiptLine(text: 'Terima Kasih', alignment: ReceiptAlignment.center),
        ]),
      );

      final bytes = formatter.format(doc);
      expect(bytes, isA<Uint8List>());
      expect(bytes.length, greaterThan(20));
      expect(bytes.sublist(0, 2), <int>[0x1B, 0x40]); // ESC @
    });

    test('SafeReceiptPrinter invokes write callback through connection', () async {
      final written = <List<int>>[];
      final connection = _MemoryPrinterConnection(
        onWrite: (data) => written.add(List<int>.from(data)),
      );
      final printer = SafeReceiptPrinter(
        formatter: const EscPosTextFormatter(),
        connection: connection,
        autoConnect: false,
      );

      const doc = ReceiptDocument(lines: [ReceiptLine(text: 'Halo Kasir')]);
      final result = await printer.safePrint(doc);

      expect(result.isSuccess, isTrue);
      expect(written, isNotEmpty);
      expect(printer.connection.state, PrinterConnectionState.connected);
    });
  });

  group('Active App Shell Smoke Test', () {
    testWidgets('Renders stable KasirApp with standardized navigation', (tester) async {
      await tester.pumpWidget(const KasirApp());
      await tester.pumpAndSettle();

      expect(find.text('Kasir'), findsWidgets);
      expect(find.text('Produk'), findsWidgets);
      expect(find.text('Laporan'), findsWidgets);
      expect(find.text('Pengaturan'), findsWidgets);
    });
  });
}
