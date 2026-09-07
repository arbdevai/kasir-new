# Printer and backup services

The package in `lib/kasir_services.dart` contains platform-neutral contracts and pure-Dart implementations for Kasir integrations. It has no Flutter UI, native USB, Bluetooth, database, or image-decoding dependency.

## Receipt mapping and formatting

`TransactionReceiptMapper` transforms the active POS `Transaction` model into a `ReceiptDocument` without invoking Flutter widgets or UI dependencies:

- Supports 58 mm (32 cols) and 80 mm (48 cols) layouts.
- Formats store headers, invoice numbers, timestamps, cashier, and customer info.
- Formats item lines with variants, item notes, item subtotal, discounts, taxes, and service charges.
- Pure-Dart rupiah currency formatting (`formatReceiptRupiah`) without `intl` localization overhead.
- Supports duck-typed transaction shapes for background isolates and workers.

`EscPosTextFormatter` is a pure-Dart ESC/POS byte generator that emits standard ESC/POS sequences (`ESC @` init, alignment, bold emphasis, feed lines, and `GS V B` paper cut) without native printer SDKs.

## Safe TCP 9100 printer connection

`TcpNetworkPrinterConnection` implements `PrinterConnection` for ESC/POS thermal network printers (RAW stream on TCP port 9100):

- State machine tracking: `disconnected`, `connecting`, `connected`, `failed`.
- Connection and write timeouts with proper socket resource disposal (`flush`, `close`, `destroy`).
- Network discovery probing for candidate IP addresses.
- Dependency-injected `SocketAdapter` boundary for testing and headless execution.

## Abstract Bluetooth and USB printer boundaries

Native Bluetooth (BLE / Classic SPP) and USB OTG driver plugins in Flutter are often fragile across Android versions. To keep domain and service layers robust:

- `BluetoothPrinterConnection` and `UsbPrinterConnection` define abstract contracts.
- Concrete native bridges remain encapsulated within dedicated platform adapters or plugins without leaking into core app code.

## Printer error handling boundary

A comprehensive typed error hierarchy and safe boundary wrapper protect UI and checkout transactions from crashes:

- `PrinterException`: Root exception for printer failures.
  - `PrinterConnectionException`: Transport handshake/connection failures.
  - `PrinterTimeoutException`: Socket connection or write timeouts.
  - `PrinterWriteException`: Data transmission failures.
  - `PrinterNotConnectedException`: Write attempted while disconnected.
  - `PrinterFormattingException`: Receipt mapping/formatting failures.
  - `PrinterDeviceNotFoundException`: Unresolved printer endpoint.
- `PrinterResult<T>`: Functional result object (`success` / `failure`) providing `when(...)` pattern matching.
- `SafeReceiptPrinter`: Wraps `ReceiptPrinter`, auto-connects to default endpoints, catches and converts errors into `PrinterResult`, and triggers optional error callbacks.

## QRIS image state and configuration hooks

`QrisImageController` manages static QRIS payment configuration with lifecycle state and integration hooks:

- State snapshot (`QrisImageSnapshot`): `empty`, `ready`, `replacing`, `invalid`.
- Hooks:
  - `QrisImageStore`: Pluggable persistence boundary (`load`, `save`, `clear`).
  - `onChanged`: State change notification listener.
  - `previewBuilder`: Hook for UI layer to generate custom preview widgets or models.
- `MemoryQrisImageStore`: Fast in-memory implementation for unit tests and previews.
- `qrisBytes(...)`: Helper extracting `Uint8List` for image rendering.

## Backup and restore

`BackupService` owns serialization, optional encryption, validation, and restoration. `BackupArtifact` is a transport-neutral byte payload suitable for an app's file picker or share integration. Call `validateBackup` before `restoreBackup`. `BackupStore` is an optional local file boundary; it does not prescribe a path, archive format, encryption scheme, or cloud provider.
