import 'package:flutter/material.dart';

import '../models/models.dart';
import '../state/pos_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class ReportsScreen extends StatefulWidget {
  final PosState state;

  const ReportsScreen({super.key, required this.state});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.state,
      builder: (context, _) {
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: true,
              toolbarHeight: 64,
              titleSpacing: 20,
              title: const Text('Laporan & Keuangan', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
              actions: [
                IconButton(
                  tooltip: 'Export Laporan',
                  icon: const Icon(Icons.file_download_outlined, color: AppColors.primary),
                  onPressed: () => _showExportDialog(context),
                ),
                const SizedBox(width: 8),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
                child: Column(
                  children: [
                    _buildTabs(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            if (_tabIndex == 0)
              _buildOverviewSliver(context)
            else if (_tabIndex == 1)
              _buildTransactionsSliver(context)
            else
              _buildDebtsSliver(context),
          ],
        );
      },
    );
  }

  Widget _buildTabs() {
    const labels = ['Ringkasan', 'Riwayat Transaksi', 'Buku Kasbon'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: labels.asMap().entries.map((e) {
          final sel = e.key == _tabIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tabIndex = e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: sel ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: sel
                      ? const [BoxShadow(color: Color(0x12000000), blurRadius: 5, offset: Offset(0, 2))]
                      : null,
                ),
                child: Center(
                  child: Text(
                    e.value,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                      color: sel ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOverviewSliver(BuildContext context) {
    final breakdown = widget.state.paymentMethodBreakdown;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Performa Kasir & Penjualan',
                  subtitle: 'Agregasi omzet real-time hari ini',
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _statItem('Total Omzet', FormatUtils.formatRupiah(widget.state.totalRevenueToday), AppColors.primary),
                    ),
                    Expanded(
                      child: _statItem('Laba Bersih Estimasi', FormatUtils.formatRupiah(widget.state.totalGrossProfitToday), AppColors.success),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _statItem('Transaksi Selesai', '${widget.state.completedTransactionsCount} Nota', AppColors.info),
                    ),
                    Expanded(
                      child: _statItem('Rata-rata Keranjang', FormatUtils.formatRupiah(widget.state.averageBasketSize), AppColors.purple),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Metode Pembayaran',
                  subtitle: 'Distribusi pendapatan kasir',
                ),
                const SizedBox(height: 8),
                ...breakdown.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(paymentMethodIcon(entry.key), size: 18, color: AppColors.textSecondary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            paymentMethodLabel(entry.key),
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                        Text(
                          FormatUtils.formatRupiah(entry.value),
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _statItem(String label, String val, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }

  Widget _buildTransactionsSliver(BuildContext context) {
    final list = widget.state.transactions;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
      sliver: SliverList.separated(
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final tx = list[i];
          final color = transactionStatusColor(tx.status);

          return GlassPanel(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(paymentMethodIcon(tx.paymentMethod), color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.customerName,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${tx.invoiceNumber} • ${FormatUtils.formatDateTime(tx.dateTime)}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      if (tx.notes.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(tx.notes, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      FormatUtils.formatRupiah(tx.total),
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    StatusBadge(
                      label: transactionStatusLabel(tx.status),
                      icon: Icons.circle,
                      color: color,
                      compact: true,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDebtsSliver(BuildContext context) {
    final debts = widget.state.transactions.where((t) => t.status == TransactionStatus.debt).toList();

    if (debts.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyState(
          icon: Icons.check_circle_outline_rounded,
          title: 'Tidak Ada Kasbon Tertunggak',
          subtitle: 'Semua transaksi pelanggan tercatat lunas.',
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
      sliver: SliverList.separated(
        itemCount: debts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final d = debts[i];
          return GlassPanel(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.warningSubtle,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.receipt_long_rounded, color: AppColors.warning, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.customerName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text(FormatUtils.formatDateTime(d.dateTime), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      const SizedBox(height: 2),
                      Text(FormatUtils.formatRupiah(d.total), style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.danger)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.state.settleDebt(d.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Kasbon atas nama ${d.customerName} telah dilunasi')),
                    );
                  },
                  child: const Text('Lunasi'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Ekspor Laporan Penjualan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        content: const Text('Pilih format laporan yang ingin disimpan atau dibagikan:'),
        actions: [
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Laporan Excel (.xlsx) berhasil digenerate')));
            },
            icon: const Icon(Icons.table_chart_rounded),
            label: const Text('Excel (.xlsx)'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Laporan PDF berhasil digenerate & siap dicetak')));
            },
            icon: const Icon(Icons.picture_as_pdf_rounded),
            label: const Text('Dokumen PDF'),
          ),
        ],
      ),
    );
  }
}
