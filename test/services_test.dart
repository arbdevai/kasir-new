import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:kasir_new/kasir_services.dart';
import 'package:kasir_new/models/models.dart';
import 'package:test/test.dart';

class _FakeSocket implements SocketAdapter {
  final writes = <List<int>>[];
  bool closed = false;
  bool destroyed = false;

  @override
  void add(List<int> data) => writes.add(List<int>.from(data));

  @override
  Future<void> flush() async {}

  @override
  Future<void> close() async => closed = true;

  @override
  void destroy() => destroyed = true;
}

class _FakeTransactionItem {
  _FakeTransactionItem(
    this.product,
    this.quantity,
    this.subtotal, {
    this.note = '',
    this.selectedVariant,
  });
  final dynamic product;
  final double quantity;
  final double subtotal;
  final String note;
  final dynamic selectedVariant;
}

class _FakeProduct {
  _FakeProduct(this.name);
  final String name;
}

class _FakeVariant {
  _FakeVariant(this.name);
  final String name;
}

class _FakeTransactionShape {
  final String invoiceNumber = 'INV-002';
  final DateTime dateTime = DateTime.utc(2026, 9, 7, 10, 30);
  final String cashierName = 'Siti';
  final String customerName = 'Budi';
  final String tableNumber = 'A1';
  final double subtotal = 40000;
  final double discount = 5000;
  final double tax = 3500;
  final double serviceCharge = 1750;
  final double total = 40250;
  final PaymentMethod paymentMethod = PaymentMethod.cash;
  final double cashReceived = 50000;
  final double cashChange = 9750;
  final String referenceNumber = 'REF-991';
  final String notes = 'Less ice';
  final List<dynamic> items = [
    _FakeTransactionItem(_FakeProduct('Americano'), 2, 40000, note: 'No sugar', selectedVariant: _FakeVariant('Iced')),
  ];
}

class _FakeQrisStore implements QrisImageStore {
  QrisImageConfiguration? value;
  bool failSave = false;

  @override
  Future<QrisImageConfiguration?> load() async => value;

  @override
  Future<void> save(QrisImageConfiguration configuration) async {
    if (failSave) throw StateError('disk full');
    value = configuration;
  }

  @override
  Future<void> clear() async => value = null;
}

void main() {
  group('printer models and endpoints', () {
    test('network endpoint defaults to ESC/POS port', () {
      const endpoint = PrinterEndpoint.network(host: '192.168.1.20');

      expect(endpoint.type, PrinterConnectionType.network);
      expect(endpoint.port, 9100);
      expect(endpoint.host, '192.168.1.20');
      expect(endpoint.toString(), contains('192.168.1.20:9100'));
    });

    test('bluetooth and usb endpoints keep native details abstract', () {
      const bt = PrinterEndpoint.bluetooth(address: '00:11:22:33:44:55', name: 'RP58-BT');
      const usb = PrinterEndpoint.usb(address: '/dev/bus/usb/001/002', name: 'USB-POS');

      expect(bt.type, PrinterConnectionType.bluetooth);
      expect(bt.address, '00:11:22:33:44:55');
      expect(usb.type, PrinterConnectionType.usb);
      expect(usb.address, '/dev/bus/usb/001/002');
    });

    test('receipt width exposes formatter columns', () {
      expect(ReceiptWidth.mm58.columns, 32);
      expect(ReceiptWidth.mm80.columns, 48);
    });
  });

  group('pure-Dart receipt mapping and formatting', () {
    test('formats rupiah correctly without intl dependency', () {
      expect(formatReceiptRupiah(0), 'Rp0');
      expect(formatReceiptRupiah(1500), 'Rp1.500');
      expect(formatReceiptRupiah(25000), 'Rp25.000');
      expect(formatReceiptRupiah(1250000), 'Rp1.250.000');
      expect(formatReceiptRupiah(-5000), '-Rp5.000');
    });

    test('maps active Transaction model to 58mm and 80mm ReceiptDocument', () {
      const store = ReceiptStoreDetails(
        name: 'Kopi & Roti Nusantara',
        tagline: 'Specialty Coffee',
        address: 'Jl. Senopati No. 45',
        phone: '0812-3456-7890',
        headerNote: 'Selamat Menikmati',
        footerNote: 'Terima kasih atas kunjungannya',
      );

      final realTx = Transaction(
        id: 'tx_01',
        invoiceNumber: 'INV/20260907/001',
        dateTime: DateTime.utc(2026, 9, 7, 14, 15),
        items: [
          CartItem(
            id: 'ci_1',
            product: const Product(
              id: 'p1',
              name: 'Kopi Susu Gula Aren',
              sku: 'KOP-1',
              barcode: '12345',
              price: 22000,
              costPrice: 10000,
              stock: 20,
              unit: 'Cup',
              categoryId: 'c1',
              categoryName: 'Kopi',
            ),
            quantity: 2,
            unitPrice: 22000,
            selectedVariant: const ProductVariant(id: 'v1', name: 'Less Sugar'),
            note: 'Extra espresso shot',
          ),
        ],
        subtotal: 44000,
        discount: 4000,
        tax: 4000,
        serviceCharge: 2000,
        total: 46000,
        paymentMethod: PaymentMethod.qris,
        status: TransactionStatus.completed,
        cashierName: 'Siti Sarah',
        customerName: 'Kak Dimas',
        tableNumber: 'Meja 02',
        referenceNumber: 'QRIS-88231940',
      );

      final mapper58 = TransactionReceiptMapper(store: store, width: ReceiptWidth.mm58);
      final doc58 = mapper58.mapTransaction(realTx);

      expect(doc58.width, ReceiptWidth.mm58);
      expect(doc58.header, isNotNull);
      expect(doc58.header!.lines.first.text, 'Kopi & Roti Nusantara');
      expect(doc58.header!.lines.first.emphasis, isTrue);

      final lineTexts = doc58.lines.map((l) => l.text).toList();
      expect(lineTexts.any((t) => t.contains('INV/20260907/001')), isTrue);
      expect(lineTexts.any((t) => t.contains('Siti Sarah')), isTrue);
      expect(lineTexts.any((t) => t.contains('Kak Dimas')), isTrue);
      expect(lineTexts.any((t) => t.contains('Meja 02')), isTrue);
      expect(lineTexts.any((t) => t.contains('2 x Kopi Susu Gula Aren')), isTrue);
      expect(lineTexts.any((t) => t.contains('Varian: Less Sugar')), isTrue);
      expect(lineTexts.any((t) => t.contains('Catatan: Extra espresso shot')), isTrue);
      expect(lineTexts.any((t) => t.contains('TOTAL')), isTrue);
      expect(lineTexts.any((t) => t.contains('Bayar: QRIS')), isTrue);
      expect(lineTexts.any((t) => t.contains('Referensi: QRIS-88231940')), isTrue);

      expect(doc58.footer, isNotNull);
      expect(doc58.footer!.lines.first.text, 'Terima kasih atas kunjungannya');

      // Test 80mm
      final mapper80 = TransactionReceiptMapper(store: store, width: ReceiptWidth.mm80);
      final doc80 = mapper80.mapTransaction(realTx);
      expect(doc80.width, ReceiptWidth.mm80);
    });

    test('supports duck-typed transaction shapes in background workers', () {
      final fakeTx = _FakeTransactionShape();
      const mapper = TransactionReceiptMapper();
      final doc = mapper.mapTransaction(fakeTx);

      expect(doc.lines.any((l) => l.text.contains('INV-002')), isTrue);
      expect(doc.lines.any((l) => l.text.contains('Americano')), isTrue);
      expect(doc.lines.any((l) => l.text.contains('Diskon')), isTrue);
      expect(doc.lines.any((l) => l.text.contains('Pajak')), isTrue);
      expect(doc.lines.any((l) => l.text.contains('Layanan')), isTrue);
      expect(doc.lines.any((l) => l.text.contains('Diterima')), isTrue);
      expect(doc.lines.any((l) => l.text.contains('Kembalian')), isTrue);
    });

    test('throws ArgumentError on invalid transaction model', () {
      const mapper = TransactionReceiptMapper();
      expect(() => mapper.mapTransaction('invalid object'), throwsArgumentError);
      expect(() => mapper.mapTransaction(null), throwsArgumentError);
    });

    test('EscPosTextFormatter produces valid ESC/POS byte sequence', () {
      const formatter = EscPosTextFormatter();
      final doc = ReceiptDocument(
        header: const ReceiptSection(lines: [
          ReceiptLine(text: 'TOKO KASIR', alignment: ReceiptAlignment.center, emphasis: true),
        ]),
        lines: const [
          ReceiptLine(text: 'Item 1                 Rp10.000'),
          ReceiptLine(text: 'TOTAL                  Rp10.000', emphasis: true),
        ],
        footer: const ReceiptSection(lines: [
          ReceiptLine(text: 'Terima Kasih', alignment: ReceiptAlignment.center),
        ]),
        width: ReceiptWidth.mm58,
      );

      final bytes = formatter.format(doc);
      expect(bytes, isA<Uint8List>());
      expect(bytes, isNotEmpty);

      // Check ESC @ init (0x1b, 0x40)
      expect(bytes[0], 0x1b);
      expect(bytes[1], 0x40);

      // Check cut command at end: GS V B 0 (0x1d, 0x56, 0x42, 0x00)
      expect(bytes.sublist(bytes.length - 4), <int>[0x1d, 0x56, 0x42, 0x00]);
    });
  });

  group('safe TCP 9100 PrinterConnection', () {
    test('connects successfully and transitions state', () async {
      final fakeSocket = _FakeSocket();
      final connection = TcpNetworkPrinterConnection(
        socketFactory: (host, port, {timeout = const Duration(seconds: 5)}) async {
          expect(host, '192.168.1.100');
          expect(port, 9100);
          return fakeSocket;
        },
      );

      expect(connection.state, PrinterConnectionState.disconnected);

      await connection.connect(
        const PrinterEndpoint.network(host: '192.168.1.100', port: 9100),
      );

      expect(connection.state, PrinterConnectionState.connected);
      expect(connection.currentEndpoint?.host, '192.168.1.100');

      final data = Uint8List.fromList([1, 2, 3, 4]);
      await connection.write(data);
      expect(fakeSocket.writes, hasLength(1));
      expect(fakeSocket.writes.first, [1, 2, 3, 4]);

      await connection.disconnect();
      expect(connection.state, PrinterConnectionState.disconnected);
      expect(fakeSocket.closed, isTrue);
    });

    test('throws PrinterConnectionException on invalid endpoint type or empty host', () async {
      final connection = TcpNetworkPrinterConnection();
      expect(
        () => connection.connect(const PrinterEndpoint.bluetooth(address: 'AA:BB')),
        throwsA(isA<PrinterConnectionException>()),
      );
      expect(
        () => connection.connect(const PrinterEndpoint.network(host: '')),
        throwsA(isA<PrinterConnectionException>()),
      );
    });

    test('handles connection timeout safely and sets state to failed', () async {
      final connection = TcpNetworkPrinterConnection(
        connectTimeout: const Duration(seconds: 1),
        socketFactory: (host, port, {timeout = const Duration(seconds: 5)}) async {
          throw TimeoutException('Simulated timeout');
        },
      );

      expect(
        () => connection.connect(const PrinterEndpoint.network(host: '10.0.0.99')),
        throwsA(isA<PrinterTimeoutException>()),
      );
      expect(connection.state, PrinterConnectionState.failed);
    });

    test('write throws PrinterNotConnectedException when disconnected', () async {
      final connection = TcpNetworkPrinterConnection();
      expect(
        () => connection.write(Uint8List.fromList([1])),
        throwsA(isA<PrinterNotConnectedException>()),
      );
    });

    test('discover probes candidate hosts and returns matching devices', () async {
      final connection = TcpNetworkPrinterConnection(
        socketFactory: (host, port, {timeout = const Duration(seconds: 5)}) async {
          if (host == '192.168.1.50') {
            return _FakeSocket();
          }
          throw const SocketException('Host unreachable');
        },
      );

      final devices = await connection.discover(
        candidates: ['192.168.1.50', '192.168.1.51'],
      );

      expect(devices, hasLength(1));
      expect(devices.first.endpoint.host, '192.168.1.50');
      expect(devices.first.displayName, contains('192.168.1.50:9100'));
    });
  });

  group('printer error handling boundary', () {
    test('SafeReceiptPrinter auto-connects and prints', () async {
      final fakeSocket = _FakeSocket();
      final connection = TcpNetworkPrinterConnection(
        socketFactory: (host, port, {timeout = const Duration(seconds: 5)}) async => fakeSocket,
      );

      final printer = SafeReceiptPrinter(
        connection: connection,
        defaultEndpoint: const PrinterEndpoint.network(host: '192.168.1.88'),
        autoConnect: true,
      );

      const doc = ReceiptDocument(lines: [ReceiptLine(text: 'Hello POS')]);

      final result = await printer.safePrint(doc);
      expect(result.isSuccess, isTrue);
      expect(connection.state, PrinterConnectionState.connected);
      expect(fakeSocket.writes, isNotEmpty);
    });

    test('SafeReceiptPrinter catches connection failure without throwing', () async {
      final connection = TcpNetworkPrinterConnection(
        socketFactory: (host, port, {timeout = const Duration(seconds: 5)}) async {
          throw const SocketException('Printer offline');
        },
      );

      PrinterException? captured;
      final printer = SafeReceiptPrinter(
        connection: connection,
        defaultEndpoint: const PrinterEndpoint.network(host: '192.168.1.88'),
        autoConnect: true,
        onError: (err) => captured = err,
      );

      const doc = ReceiptDocument(lines: [ReceiptLine(text: 'Test')]);
      final result = await printer.safePrint(doc);

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.error, isA<PrinterConnectionException>());
      expect(captured, isNotNull);
      expect(result.errorMessage, contains('Printer offline'));
    });

    test('SafeReceiptPrinter catches formatting failure and wraps in PrinterFormattingException', () async {
      final fakeSocket = _FakeSocket();
      final connection = TcpNetworkPrinterConnection(
        socketFactory: (host, port, {timeout = const Duration(seconds: 5)}) async => fakeSocket,
      );
      await connection.connect(const PrinterEndpoint.network(host: '192.168.1.88'));

      final badFormatter = _FailingFormatter();
      final printer = SafeReceiptPrinter(
        connection: connection,
        formatter: badFormatter,
      );

      const doc = ReceiptDocument(lines: []);
      final result = await printer.safePrint(doc);

      expect(result.isSuccess, isFalse);
      expect(result.error, isA<PrinterFormattingException>());
    });

    test('PrinterResult when matcher handles success and failure', () {
      const ok = PrinterResult<String>.success('printed');
      final okMsg = ok.when(success: (d) => 'OK: $d', failure: (e) => 'ERR');
      expect(okMsg, 'OK: printed');

      const fail = PrinterResult<String>.failure(PrinterException('paper out'));
      final failMsg = fail.when(success: (d) => 'OK', failure: (e) => 'ERR: ${e.message}');
      expect(failMsg, 'ERR: paper out');
    });
  });

  group('QRIS configuration and state hooks', () {
    test('QRIS configuration can be copied without changing original', () {
      final original = QrisImageConfiguration(
        bytes: <int>[1, 2],
        mimeType: 'image/png',
      );
      final copy = original.copyWith(bytes: <int>[3]);

      expect(original.bytes, <int>[1, 2]);
      expect(copy.bytes, <int>[3]);
      expect(copy.mimeType, 'image/png');
    });

    test('QrisImageController integrates load, set, clear, and snapshot hooks', () async {
      final store = _FakeQrisStore();
      final snapshots = <QrisImageSnapshot>[];

      final controller = QrisImageController(
        store: store,
        onChanged: (snap) => snapshots.add(snap),
        previewBuilder: (cfg) => 'preview_${cfg.fileName}',
      );

      expect(controller.snapshot.state, QrisImageState.empty);
      expect(controller.snapshot.isConfigured, isFalse);

      // Load with empty store
      await controller.load();
      expect(controller.snapshot.state, QrisImageState.empty);

      // Set valid QRIS image
      final qrisConfig = QrisImageConfiguration(
        bytes: const <int>[137, 80, 78, 71],
        mimeType: 'image/png',
        fileName: 'my_qris.png',
      );
      await controller.setImage(qrisConfig);

      expect(controller.snapshot.state, QrisImageState.ready);
      expect(controller.snapshot.isConfigured, isTrue);
      expect(controller.snapshot.configuration?.fileName, 'my_qris.png');
      expect(controller.buildPreview(), 'preview_my_qris.png');
      expect(qrisBytes(controller.snapshot.configuration!), hasLength(4));

      // Reject non-image
      final nonImage = QrisImageConfiguration(
        bytes: const <int>[1, 2],
        mimeType: 'application/pdf',
      );
      final rejected = await controller.setImage(nonImage);
      expect(rejected.state, QrisImageState.invalid);
      expect(rejected.message, contains('File QRIS harus berupa gambar'));

      // Clear
      await controller.clear();
      expect(controller.snapshot.state, QrisImageState.empty);
      expect(controller.snapshot.isConfigured, isFalse);
      expect(controller.buildPreview(), isNull);
    });

    test('MemoryQrisImageStore stores and clears configuration', () async {
      final memStore = MemoryQrisImageStore();
      expect(await memStore.load(), isNull);

      final config = QrisImageConfiguration(bytes: [1, 2], mimeType: 'image/jpeg');
      await memStore.save(config);
      expect(await memStore.load(), config);

      await memStore.clear();
      expect(await memStore.load(), isNull);
    });
  });

  group('backup service contracts', () {
    test('backup validation represents valid and invalid payloads', () {
      const valid = RestoreValidation.valid();
      const invalid = RestoreValidation.invalid('bad checksum');
      final artifact = BackupArtifact(
        bytes: Uint8List.fromList(<int>[1]),
        fileName: 'backup.kasir',
        contentType: 'application/octet-stream',
      );

      expect(valid.isValid, isTrue);
      expect(invalid.isValid, isFalse);
      expect(invalid.message, 'bad checksum');
      expect(artifact.bytes, hasLength(1));
    });
  });
}

class _FailingFormatter implements EscPosReceiptFormatter {
  @override
  Uint8List format(ReceiptDocument document) {
    throw StateError('corrupted layout format');
  }
}
