import 'dart:typed_data';

/// Receipt document model shared by ESC/POS formatters and printers.
class ReceiptDocument {
  const ReceiptDocument({
    required this.lines,
    this.header,
    this.footer,
    this.width = ReceiptWidth.mm58,
  });

  final ReceiptSection? header;
  final List<ReceiptLine> lines;
  final ReceiptSection? footer;
  final ReceiptWidth width;
}

/// Paper width selected for layout decisions made by a formatter.
enum ReceiptWidth {
  /// 58 mm paper, commonly 32 text columns.
  mm58,

  /// 80 mm paper, commonly 48 text columns.
  mm80,
}

extension ReceiptWidthColumns on ReceiptWidth {
  int get columns => this == ReceiptWidth.mm80 ? 48 : 32;
}

/// A named group of lines, used for header and footer blocks.
class ReceiptSection {
  const ReceiptSection({required this.lines});

  final List<ReceiptLine> lines;
}

/// One printable text line with presentation hints only.
class ReceiptLine {
  const ReceiptLine({
    required this.text,
    this.alignment = ReceiptAlignment.left,
    this.emphasis = false,
  });

  final String text;
  final ReceiptAlignment alignment;
  final bool emphasis;
}

enum ReceiptAlignment { left, center, right }

/// A connection-independent ESC/POS byte formatter.
///
/// Lives here (rather than in printer.dart) so receipt mapping and formatting
/// stay dependency-free and importable without sockets or platform adapters.
abstract interface class EscPosReceiptFormatter {
  Uint8List format(ReceiptDocument document);
}

/// Pure-Dart store values used by [TransactionReceiptMapper].
///
/// Keeping this small value object independent from Flutter's [StoreProfile]
/// allows receipt generation in tests, isolates, and background services.
class ReceiptStoreDetails {
  const ReceiptStoreDetails({
    this.name = '',
    this.tagline = '',
    this.address = '',
    this.phone = '',
    this.headerNote = '',
    this.footerNote = '',
  });

  final String name;
  final String tagline;
  final String address;
  final String phone;
  final String headerNote;
  final String footerNote;
}

/// Formats an amount for an Indonesian thermal receipt without an external
/// locale dependency. Values are rounded to whole rupiah and use `.` separators.
String formatReceiptRupiah(num amount) {
  final rounded = amount.round().abs().toString();
  final groups = <String>[];
  for (var end = rounded.length; end > 0;) {
    final start = end > 3 ? end - 3 : 0;
    groups.insert(0, rounded.substring(start, end));
    end = start;
  }
  final value = groups.join('.');
  return amount < 0 ? '-Rp$value' : 'Rp$value';
}

/// Converts the active UI [Transaction] model to a transport-neutral receipt.
///
/// The mapper is intentionally presentation-only: it does not open a printer,
/// read files, or call Flutter APIs. Importing this library from an app remains
/// safe even when printing is unavailable.
class TransactionReceiptMapper {
  const TransactionReceiptMapper({
    this.store = const ReceiptStoreDetails(),
    this.width = ReceiptWidth.mm58,
    this.includeItemMetadata = true,
  });

  final ReceiptStoreDetails store;
  final ReceiptWidth width;
  final bool includeItemMetadata;

  /// Maps the active transaction model used by the POS UI.
  ReceiptDocument mapTransaction(dynamic transaction) {
    if (transaction == null || !_hasTransactionShape(transaction)) {
      throw ArgumentError.value(
        transaction,
        'transaction',
        'Expected the active Transaction model',
      );
    }

    final columns = width.columns;
    String value(String name) {
      try {
        final dynamic result = switch (name) {
          'invoiceNumber' => transaction.invoiceNumber,
          'cashierName' => transaction.cashierName,
          'customerName' => transaction.customerName,
          'tableNumber' => transaction.tableNumber,
          'referenceNumber' => transaction.referenceNumber,
          'notes' => transaction.notes,
          'dateTime' => transaction.dateTime,
          'subtotal' => transaction.subtotal,
          'discount' => transaction.discount,
          'tax' => transaction.tax,
          'serviceCharge' => transaction.serviceCharge,
          'total' => transaction.total,
          'cashReceived' => transaction.cashReceived,
          'cashChange' => transaction.cashChange,
          'paymentMethod' => transaction.paymentMethod,
          'items' => transaction.items,
          _ => throw StateError('Unknown transaction field $name'),
        };
        return '$result';
      } catch (error) {
        throw StateError('Unable to read transaction field $name: $error');
      }
    }

    final headerLines = <ReceiptLine>[];
    void addCenter(String text, {bool emphasis = false}) {
      if (text.trim().isNotEmpty) {
        headerLines.add(ReceiptLine(
          text: text.trim(),
          alignment: ReceiptAlignment.center,
          emphasis: emphasis,
        ));
      }
    }

    addCenter(store.name, emphasis: true);
    addCenter(store.tagline);
    addCenter(store.address);
    addCenter(store.phone);
    addCenter(store.headerNote);

    final lines = <ReceiptLine>[
      ReceiptLine(text: _rule(columns)),
      ReceiptLine(text: 'No: ${value('invoiceNumber')}'),
      ReceiptLine(text: 'Waktu: ${_formatDateTime(value('dateTime'))}'),
      ReceiptLine(text: 'Kasir: ${value('cashierName')}'),
    ];
    final customer = value('customerName').trim();
    final table = value('tableNumber').trim();
    if (customer.isNotEmpty) lines.add(ReceiptLine(text: 'Pelanggan: $customer'));
    if (table.isNotEmpty) lines.add(ReceiptLine(text: 'Meja: $table'));
    lines.add(ReceiptLine(text: _rule(columns)));

    for (final item in (transaction.items as Iterable<dynamic>)) {
      final name = '${item.product.name}';
      final quantity = _formatQuantity(item.quantity);
      final amount = formatReceiptRupiah(item.subtotal as num);
      lines.add(ReceiptLine(text: _fitItemLine(name, '$quantity x', amount, columns)));
      if (includeItemMetadata) {
        final variant = item.selectedVariant?.name?.toString() ?? '';
        final note = item.note?.toString() ?? '';
        if (variant.isNotEmpty) lines.add(ReceiptLine(text: '  Varian: $variant'));
        if (note.isNotEmpty) lines.add(ReceiptLine(text: '  Catatan: $note'));
      }
    }
    lines.add(ReceiptLine(text: _rule(columns)));
    lines.add(_amountLine('Subtotal', value('subtotal'), columns));
    final discountVal = double.tryParse(value('discount')) ?? 0;
    if (discountVal > 0) {
      lines.add(_amountLine('Diskon', discountVal, columns));
    }
    final taxVal = double.tryParse(value('tax')) ?? 0;
    if (taxVal > 0) {
      lines.add(_amountLine('Pajak', taxVal, columns));
    }
    final serviceVal = double.tryParse(value('serviceCharge')) ?? 0;
    if (serviceVal > 0) {
      lines.add(_amountLine('Layanan', serviceVal, columns));
    }
    lines.add(ReceiptLine(text: _rule(columns)));
    lines.add(_amountLine('TOTAL', value('total'), columns, emphasis: true));
    lines.add(ReceiptLine(text: 'Bayar: ${_paymentLabel(value('paymentMethod'))}'));

    final cashReceived = double.tryParse(value('cashReceived')) ?? 0;
    final cashChange = double.tryParse(value('cashChange')) ?? 0;
    if (cashReceived > 0) lines.add(_amountLine('Diterima', cashReceived, columns));
    if (cashChange > 0) lines.add(_amountLine('Kembalian', cashChange, columns));
    final reference = value('referenceNumber').trim();
    if (reference.isNotEmpty) lines.add(ReceiptLine(text: 'Referensi: $reference'));
    final notes = value('notes').trim();
    if (notes.isNotEmpty) lines.add(ReceiptLine(text: 'Catatan: $notes'));

    final footerLines = <ReceiptLine>[];
    void addFooterCenter(String text) {
      if (text.trim().isNotEmpty) {
        footerLines.add(ReceiptLine(text: text.trim(), alignment: ReceiptAlignment.center));
      }
    }
    addFooterCenter(store.footerNote);

    return ReceiptDocument(
      header: headerLines.isEmpty ? null : ReceiptSection(lines: headerLines),
      lines: lines,
      footer: footerLines.isEmpty ? null : ReceiptSection(lines: footerLines),
      width: width,
    );
  }

  bool _hasTransactionShape(dynamic obj) {
    try {
      return obj.invoiceNumber != null &&
          obj.items != null &&
          obj.total != null &&
          obj.cashierName != null;
    } catch (_) {
      return false;
    }
  }

  ReceiptLine _amountLine(String label, dynamic amount, int columns, {bool emphasis = false}) {
    final number = amount is num ? amount : double.tryParse('$amount') ?? 0;
    final right = formatReceiptRupiah(number);
    final available = columns - right.length - 1;
    final left = label.length > available
        ? label.substring(0, available.clamp(0, label.length).toInt())
        : label;
    final spacing = (columns - left.length - right.length).clamp(1, columns).toInt();
    return ReceiptLine(
      text: '$left${' ' * spacing}$right',
      emphasis: emphasis,
    );
  }

  String _fitItemLine(String name, String quantity, String amount, int columns) {
    final prefix = '$quantity ';
    final spaces = columns - prefix.length - amount.length - 1;
    final nameLength = spaces > 0 ? spaces : 1;
    final clipped = name.length > nameLength ? name.substring(0, nameLength) : name;
    final spacing = (columns - prefix.length - clipped.length - amount.length).clamp(1, columns).toInt();
    return '$prefix$clipped${' ' * spacing}$amount';
  }

  String _rule(int columns) => '-' * columns;

  String _formatQuantity(dynamic quantity) {
    final value = quantity is num ? quantity : double.tryParse('$quantity') ?? 0;
    return value == value.roundToDouble() ? value.toInt().toString() : value.toString();
  }

  String _formatDateTime(dynamic value) {
    final date = value is DateTime ? value : DateTime.tryParse('$value');
    if (date == null) return '$value';
    final local = date.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  String _paymentLabel(dynamic method) {
    final name = '$method'.split('.').last;
    return switch (name) {
      'cash' => 'Tunai',
      'qris' => 'QRIS',
      'transfer' => 'Transfer Bank',
      'debit' => 'Kartu Debit',
      'debt' => 'Kasbon',
      'split' => 'Split Payment',
      _ => name,
    };
  }
}

/// Backwards-friendly name for callers that prefer a mapper noun.
typedef ReceiptMapper = TransactionReceiptMapper;

/// Minimal pure-Dart ESC/POS formatter that emits raw printer bytes.
class EscPosTextFormatter implements EscPosReceiptFormatter {
  const EscPosTextFormatter();

  @override
  Uint8List format(ReceiptDocument document) {
    final bytes = <int>[
      0x1b, 0x40, // ESC @ (Initialize printer)
    ];

    void writeLine(ReceiptLine line) {
      bytes.addAll(<int>[0x1b, 0x61, _alignmentByte(line.alignment)]); // Alignment
      bytes.addAll(<int>[0x1b, 0x45, line.emphasis ? 1 : 0]); // Bold on/off
      final safe = line.text.replaceAll(RegExp(r'[\r\n]'), ' ');
      final chunks = _wrap(safe, document.width.columns);
      for (final chunk in chunks) {
        bytes.addAll(_encode(chunk));
        bytes.add(0x0a); // LF
      }
    }

    if (document.header != null) {
      for (final line in document.header!.lines) {
        writeLine(line);
      }
    }

    for (final line in document.lines) {
      writeLine(line);
    }

    if (document.footer != null) {
      for (final line in document.footer!.lines) {
        writeLine(line);
      }
    }

    // Feed lines and cut paper
    bytes.addAll(<int>[
      0x0a, 0x0a, 0x0a, // 3 blank lines feed
      0x1d, 0x56, 0x42, 0x00, // GS V B 0 (Partial cut / feed and cut)
    ]);

    return Uint8List.fromList(bytes);
  }

  int _alignmentByte(ReceiptAlignment alignment) => switch (alignment) {
        ReceiptAlignment.left => 0,
        ReceiptAlignment.center => 1,
        ReceiptAlignment.right => 2,
      };

  List<int> _encode(String text) =>
      text.codeUnits.map((unit) => unit <= 0xff ? unit : 0x3f).toList();

  List<String> _wrap(String text, int width) {
    if (text.isEmpty) return <String>[''];
    if (text.length <= width) return <String>[text];
    final result = <String>[];
    for (var start = 0; start < text.length; start += width) {
      final end = (start + width).clamp(0, text.length);
      result.add(text.substring(start, end));
    }
    return result;
  }
}

/// Alias with the common ESC/POS spelling.
typedef EscPosFormatter = EscPosTextFormatter;
