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
