import 'dart:async';
import 'dart:io';
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

  @override
  String toString() {
    switch (type) {
      case PrinterConnectionType.bluetooth:
        return 'Bluetooth($address, name: $name)';
      case PrinterConnectionType.usb:
        return 'USB($address, name: $name)';
      case PrinterConnectionType.network:
        return 'Network($host:$port, name: $name)';
    }
  }
}

class PrinterDevice {
  const PrinterDevice({required this.endpoint, required this.displayName});

  final PrinterEndpoint endpoint;
  final String displayName;
}

// ---------------------------------------------------------------------------
// Printer Error Hierarchy & Boundary
// ---------------------------------------------------------------------------

/// Base exception for all printer-related failures.
class PrinterException implements Exception {
  const PrinterException(this.message, {this.cause, this.stackTrace});

  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() => 'PrinterException: $message';
}

/// Thrown when establishing a connection to the printer fails.
class PrinterConnectionException extends PrinterException {
  const PrinterConnectionException(super.message, {super.cause, super.stackTrace});

  @override
  String toString() => 'PrinterConnectionException: $message';
}

/// Thrown when a printer operation exceeds its time limit.
class PrinterTimeoutException extends PrinterException {
  const PrinterTimeoutException(super.message, {super.cause, super.stackTrace});

  @override
  String toString() => 'PrinterTimeoutException: $message';
}

/// Thrown when writing data to the printer fails.
class PrinterWriteException extends PrinterException {
  const PrinterWriteException(super.message, {super.cause, super.stackTrace});

  @override
  String toString() => 'PrinterWriteException: $message';
}

/// Thrown when an operation requires an active connection that is missing.
class PrinterNotConnectedException extends PrinterException {
  const PrinterNotConnectedException([String message = 'Printer is not connected'])
      : super(message);

  @override
  String toString() => 'PrinterNotConnectedException: $message';
}

/// Thrown when formatting a receipt fails before transmission.
class PrinterFormattingException extends PrinterException {
  const PrinterFormattingException(super.message, {super.cause, super.stackTrace});

  @override
  String toString() => 'PrinterFormattingException: $message';
}

/// Thrown when an endpoint or device cannot be resolved.
class PrinterDeviceNotFoundException extends PrinterException {
  const PrinterDeviceNotFoundException(super.message, {super.cause, super.stackTrace});

  @override
  String toString() => 'PrinterDeviceNotFoundException: $message';
}

/// Boundary result wrapper that captures success or typed printer failure
/// without throwing unhandled errors across UI or service layers.
class PrinterResult<T> {
  const PrinterResult.success([this.data])
      : isSuccess = true,
        error = null;

  const PrinterResult.failure(this.error)
      : isSuccess = false,
        data = null;

  final bool isSuccess;
  final T? data;
  final PrinterException? error;

  bool get isFailure => !isSuccess;

  String? get errorMessage => error?.message;

  R when<R>({
    required R Function(T? data) success,
    required R Function(PrinterException error) failure,
  }) {
    if (isSuccess) {
      return success(data);
    } else {
      return failure(error!);
    }
  }

  @override
  String toString() => isSuccess ? 'PrinterResult.success($data)' : 'PrinterResult.failure($error)';
}

// ---------------------------------------------------------------------------
// Connection Interfaces & Abstract Implementations
// ---------------------------------------------------------------------------

/// Transport-neutral printer connection boundary.
abstract interface class PrinterConnection {
  PrinterConnectionType get type;
  PrinterConnectionState get state;
  Future<List<PrinterDevice>> discover({
    List<String>? candidates,
    Duration probeTimeout = const Duration(milliseconds: 800),
  });
  Future<void> connect(PrinterEndpoint endpoint);
  Future<void> disconnect();
  Future<void> write(Uint8List data);
}

/// Abstract contract for Bluetooth printers.
///
/// Avoids coupling to fragile native plugins (e.g. bluetooth_serial / flutter_blue).
/// Concrete platform adapters implement this in application or platform packages.
abstract class BluetoothPrinterConnection implements PrinterConnection {
  @override
  PrinterConnectionType get type => PrinterConnectionType.bluetooth;
}

/// Abstract contract for USB OTG printers.
///
/// Avoids coupling to fragile USB serial / OTG plugins. Platform adapters supply
/// raw byte streaming without leaking native driver dependencies to core domain logic.
abstract class UsbPrinterConnection implements PrinterConnection {
  @override
  PrinterConnectionType get type => PrinterConnectionType.usb;
}

/// Coordinates formatting and optional output to a connection.
abstract interface class ReceiptPrinter {
  Future<Uint8List> format(ReceiptDocument document);
  Future<void> print(ReceiptDocument document);
}

// ---------------------------------------------------------------------------
// Safe TCP 9100 Printer Connection
// ---------------------------------------------------------------------------

/// Abstract socket boundary to allow dependency injection and headless unit tests.
abstract interface class SocketAdapter {
  void add(List<int> data);
  Future<void> flush();
  Future<void> close();
  void destroy();
}

class _DefaultSocketAdapter implements SocketAdapter {
  _DefaultSocketAdapter(this._socket);
  final Socket _socket;

  @override
  void add(List<int> data) => _socket.add(data);

  @override
  Future<void> flush() => _socket.flush();

  @override
  Future<void> close() => _socket.close();

  @override
  void destroy() {
    _socket.destroy();
  }
}

typedef TcpSocketFactory = Future<SocketAdapter> Function(
  String host,
  int port, {
  Duration timeout,
});

Future<SocketAdapter> defaultTcpSocketFactory(
  String host,
  int port, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final socket = await Socket.connect(host, port, timeout: timeout);
  return _DefaultSocketAdapter(socket);
}

/// Safe network printer connection for ESC/POS thermal printers communicating
/// over TCP port 9100 (RAW print stream).
///
/// Includes state transitions, configurable timeouts, graceful recovery on error,
/// and safe socket cleanup.
class TcpNetworkPrinterConnection implements PrinterConnection {
  TcpNetworkPrinterConnection({
    this.defaultEndpoint,
    this.connectTimeout = const Duration(seconds: 5),
    this.writeTimeout = const Duration(seconds: 5),
    TcpSocketFactory? socketFactory,
  }) : _socketFactory = socketFactory ?? defaultTcpSocketFactory;

  final PrinterEndpoint? defaultEndpoint;
  final Duration connectTimeout;
  final Duration writeTimeout;
  final TcpSocketFactory _socketFactory;

  PrinterConnectionState _state = PrinterConnectionState.disconnected;
  SocketAdapter? _socket;
  PrinterEndpoint? _currentEndpoint;

  @override
  PrinterConnectionType get type => PrinterConnectionType.network;

  @override
  PrinterConnectionState get state => _state;

  PrinterEndpoint? get currentEndpoint => _currentEndpoint;

  @override
  Future<void> connect(PrinterEndpoint endpoint) async {
    if (endpoint.type != PrinterConnectionType.network) {
      throw PrinterConnectionException(
        'TcpNetworkPrinterConnection requires network endpoint, got ${endpoint.type}',
      );
    }

    final host = endpoint.host;
    final port = endpoint.port ?? 9100;
    if (host == null || host.trim().isEmpty) {
      throw const PrinterConnectionException('Printer host must not be empty');
    }

    await disconnect();

    _state = PrinterConnectionState.connecting;
    _currentEndpoint = endpoint;

    try {
      _socket = await _socketFactory(
        host.trim(),
        port,
        timeout: connectTimeout,
      );
      _state = PrinterConnectionState.connected;
    } on SocketException catch (e, st) {
      _state = PrinterConnectionState.failed;
      throw PrinterConnectionException(
        'Could not connect to printer at $host:$port: ${e.message}',
        cause: e,
        stackTrace: st,
      );
    } on TimeoutException catch (e, st) {
      _state = PrinterConnectionState.failed;
      throw PrinterTimeoutException(
        'Connection to printer at $host:$port timed out after ${connectTimeout.inSeconds}s',
        cause: e,
        stackTrace: st,
      );
    } catch (e, st) {
      _state = PrinterConnectionState.failed;
      throw PrinterConnectionException(
        'Unexpected connection error to $host:$port: $e',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> disconnect() async {
    if (_socket != null) {
      try {
        await _socket!.flush().timeout(const Duration(milliseconds: 500));
        await _socket!.close().timeout(const Duration(milliseconds: 500));
      } catch (_) {
        _socket!.destroy();
      } finally {
        _socket = null;
      }
    }
    _state = PrinterConnectionState.disconnected;
  }

  @override
  Future<void> write(Uint8List data) async {
    if (_state != PrinterConnectionState.connected || _socket == null) {
      throw const PrinterNotConnectedException(
        'Cannot write: TCP printer connection is not open',
      );
    }

    try {
      _socket!.add(data);
      await _socket!.flush().timeout(writeTimeout);
    } on TimeoutException catch (e, st) {
      _state = PrinterConnectionState.failed;
      await disconnect();
      throw PrinterTimeoutException(
        'Write to printer timed out after ${writeTimeout.inSeconds}s',
        cause: e,
        stackTrace: st,
      );
    } catch (e, st) {
      _state = PrinterConnectionState.failed;
      await disconnect();
      throw PrinterWriteException(
        'Failed to write bytes to printer: $e',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<List<PrinterDevice>> discover({
    List<String>? candidates,
    Duration probeTimeout = const Duration(milliseconds: 800),
  }) async {
    final targets = <String>{};
    if (candidates != null && candidates.isNotEmpty) {
      targets.addAll(candidates);
    } else if (_currentEndpoint?.host != null) {
      targets.add(_currentEndpoint!.host!);
    } else if (defaultEndpoint?.host != null) {
      targets.add(defaultEndpoint!.host!);
    }

    if (targets.isEmpty) {
      return const <PrinterDevice>[];
    }

    final found = <PrinterDevice>[];
    for (final host in targets) {
      try {
        final probe = await _socketFactory(
          host,
          9100,
          timeout: probeTimeout,
        );
        await probe.close();
        found.add(
          PrinterDevice(
            endpoint: PrinterEndpoint.network(host: host, port: 9100, name: 'TCP Printer ($host)'),
            displayName: 'ESC/POS Printer ($host:9100)',
          ),
        );
      } catch (_) {
        // Host did not respond on 9100; continue discovery
      }
    }
    return found;
  }
}

// ---------------------------------------------------------------------------
// Safe Receipt Printer & Error Boundary
// ---------------------------------------------------------------------------

/// Wraps printer operations in a structured error boundary.
///
/// Ensures formatting errors, timeout failures, and transport disconnects
/// are caught, logged, and returned as [PrinterResult] values without terminating
/// UI transactions.
class SafeReceiptPrinter implements ReceiptPrinter {
  SafeReceiptPrinter({
    required this.connection,
    this.formatter = const EscPosTextFormatter(),
    this.defaultEndpoint,
    this.autoConnect = true,
    this.onError,
  });

  final PrinterConnection connection;
  final EscPosReceiptFormatter formatter;
  final PrinterEndpoint? defaultEndpoint;
  final bool autoConnect;
  final void Function(PrinterException error)? onError;

  @override
  Future<Uint8List> format(ReceiptDocument document) async {
    try {
      return formatter.format(document);
    } catch (e, st) {
      final exception = PrinterFormattingException(
        'Failed to format receipt document: $e',
        cause: e,
        stackTrace: st,
      );
      onError?.call(exception);
      throw exception;
    }
  }

  @override
  Future<void> print(ReceiptDocument document) async {
    final bytes = await format(document);

    if (connection.state != PrinterConnectionState.connected) {
      if (autoConnect && defaultEndpoint != null) {
        try {
          await connection.connect(defaultEndpoint!);
        } on PrinterException catch (e) {
          onError?.call(e);
          rethrow;
        } catch (e, st) {
          final ex = PrinterConnectionException(
            'Auto-connect failed: $e',
            cause: e,
            stackTrace: st,
          );
          onError?.call(ex);
          throw ex;
        }
      } else {
        final exception = PrinterNotConnectedException(
          'Cannot print: connection is ${connection.state.name}',
        );
        onError?.call(exception);
        throw exception;
      }
    }

    try {
      await connection.write(bytes);
    } on PrinterException catch (e) {
      onError?.call(e);
      rethrow;
    } catch (e, st) {
      final exception = PrinterWriteException(
        'Failed transmitting receipt to printer: $e',
        cause: e,
        stackTrace: st,
      );
      onError?.call(exception);
      throw exception;
    }
  }

  /// Safe boundary method that never throws; returns a [PrinterResult].
  Future<PrinterResult<void>> safePrint(ReceiptDocument document) async {
    try {
      await print(document);
      return const PrinterResult.success();
    } on PrinterException catch (e) {
      return PrinterResult.failure(e);
    } catch (e, st) {
      final fallback = PrinterException(
        'Unexpected printer error: $e',
        cause: e,
        stackTrace: st,
      );
      onError?.call(fallback);
      return PrinterResult.failure(fallback);
    }
  }
}
