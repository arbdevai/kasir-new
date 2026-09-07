# Printer and backup services

The package in `lib/kasir_services.dart` contains platform-neutral contracts for
Kasir integrations. It has no Flutter, USB, Bluetooth, socket, database, or
image-decoding dependency.

## Printer connections

Implement `PrinterConnection` in an application/platform adapter. The endpoint
models Bluetooth and USB addresses as opaque strings and network printers as a
host and port (default `9100`). `write` accepts already formatted ESC/POS
bytes; the abstraction makes no claim that a device exists or that a transport
supports a particular command.

`EscPosReceiptFormatter` converts a `ReceiptDocument` into bytes. The document
supports 58 mm and 80 mm widths, header/footer sections, alignment, and
emphasis. Add richer receipt fields in an adapter or a higher-level domain
model rather than coupling this package to a printer SDK.

## QRIS image

`QrisImageConfiguration` carries image bytes, MIME type, optional file name,
and preview alt text. Store it with the app's chosen local persistence layer
and render it in the UI or receipt adapter as needed.

## Backup and restore

`BackupService` owns serialization, optional encryption, validation, and
restoration. `BackupArtifact` is a transport-neutral byte payload suitable for
an app's file picker or share integration. Call `validateBackup` before
`restoreBackup`. `BackupStore` is an optional local file boundary; it does not
prescribe a path, archive format, encryption scheme, or cloud provider.
