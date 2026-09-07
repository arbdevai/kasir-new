import 'dart:typed_data';

import 'receipt.dart';

export 'receipt.dart';

enum PrinterConnectionType { bluetooth, usb, network }

enum PrinterConnectionState { disconnected, connecting, connected, failed }

class PrinterEndpoint {
  const PrinterEndpoint.bluetooth({required this.address, this.name})
      : type = PrinterConnectionType.bluetooth,
        host = null,
        port = null;

  const PrinterEndpoint.usb({required this.address, this.name})
      : type = PrinterConnectionType.usb,
        host = null,
        port = null;

  const PrinterEndpoint.network({required this.host, this.port = 9100, this.name})
      : type = PrinterConnectionType.network,
        address = null;

  final PrinterConnectionType type;
  final String? address;
  final String? name;
  final String? host;
  final int? port;
}

class PrinterDevice {
  const PrinterDevice({required this.endpoint, required this.displayName});

  final PrinterEndpoint endpoint;
  final String displayName;
}

class PrinterConnectionException implements Exception {
  const PrinterConnectionException(this.message);

  final String message;

  @override
  String toString() => 'PrinterConnectionException: $message';
}

/// Transport-neutral printer connection boundary.
///
/// This interface does not scan, pair, open sockets, or claim hardware
/// support. Platform adapters supply those behaviors.
abstract interface class PrinterConnection {
  PrinterConnectionType get type;
  PrinterConnectionState get state;
  Future<List<PrinterDevice>> discover();
  Future<void> connect(PrinterEndpoint endpoint);
  Future<void> disconnect();
  Future<void> write(Uint8List data);
}

/// A connection-independent ESC/POS byte formatter.
abstract interface class EscPosReceiptFormatter {
  Uint8List format(ReceiptDocument document);
}

/// Coordinates formatting and optional output to a connection.
abstract interface class ReceiptPrinter {
  Future<Uint8List> format(ReceiptDocument document);
  Future<void> print(ReceiptDocument document);
}
