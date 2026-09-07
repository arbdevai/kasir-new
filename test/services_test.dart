import 'dart:typed_data';

import 'package:kasir_new/kasir_services.dart';
import 'package:test/test.dart';

void main() {
  group('printer models', () {
    test('network endpoint defaults to ESC/POS port', () {
      const endpoint = PrinterEndpoint.network(host: '192.168.1.20');

      expect(endpoint.type, PrinterConnectionType.network);
      expect(endpoint.port, 9100);
      expect(endpoint.host, '192.168.1.20');
    });

    test('receipt width exposes formatter columns', () {
      expect(ReceiptWidth.mm58.columns, 32);
      expect(ReceiptWidth.mm80.columns, 48);
    });
  });

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
}
