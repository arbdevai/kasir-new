import 'dart:convert';
import 'dart:typed_data';

import '../models/models.dart';

/// A transport-neutral report export (CSV or readable text).
class ReportArtifact {
  const ReportArtifact({required this.bytes, required this.fileName, required this.contentType});

  final Uint8List bytes;
  final String fileName;
  final String contentType;

  String get text => utf8.decode(bytes);
}

class ReportExportService {
  const ReportExportService();

  ReportArtifact exportCsv(Iterable<Transaction> transactions, {String fileName = 'kasir-transactions.csv'}) {
    final rows = <List<String>>[
      ['Invoice', 'Tanggal', 'Pelanggan', 'Kasir', 'Status', 'Pembayaran', 'Subtotal', 'Diskon', 'Pajak', 'Layanan', 'Total'],
      ...transactions.map((t) => [
            t.invoiceNumber,
            t.dateTime.toIso8601String(),
            t.customerName,
            t.cashierName,
            t.status.name,
            t.paymentMethod.name,
            _money(t.subtotal),
            _money(t.discount),
            _money(t.tax),
            _money(t.serviceCharge),
            _money(t.total),
          ]),
    ];
    final text = rows.map((row) => row.map(_escapeCsv).join(',')).join('\r\n');
    return ReportArtifact(bytes: Uint8List.fromList(utf8.encode('$text\r\n')), fileName: fileName, contentType: 'text/csv; charset=utf-8');
  }

  ReportArtifact exportText(Iterable<Transaction> transactions, {String fileName = 'kasir-report.txt'}) {
    final list = transactions.toList(growable: false);
    final total = list.fold<double>(0, (sum, t) => sum + t.total);
    final completed = list.where((t) => t.status == TransactionStatus.completed).length;
    final lines = <String>[
      'LAPORAN TRANSAKSI KASIR',
      '========================',
      'Jumlah transaksi: ${list.length}',
      'Transaksi selesai: $completed',
      'Total nilai: ${_money(total)}',
      '',
      ...list.map((t) => '${t.invoiceNumber} | ${t.dateTime.toIso8601String()} | ${t.customerName} | ${_money(t.total)} | ${t.status.name}'),
    ];
    return ReportArtifact(bytes: Uint8List.fromList(utf8.encode('${lines.join('\n')}\n')), fileName: fileName, contentType: 'text/plain; charset=utf-8');
  }

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n') || value.contains('\r')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  String _money(num value) => value.toStringAsFixed(2);
}
