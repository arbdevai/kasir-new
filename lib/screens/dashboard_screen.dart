import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/models.dart';
import '../state/pos_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class DashboardScreen extends StatelessWidget {
  final PosState state;
  final ValueChanged<int> onNavigateToTab;

  const DashboardScreen({super.key, required this.state, required this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildWelcomeHeader(context),
              const SizedBox(height: 22),
              _buildMetricGrid(context),
              const SizedBox(height: 24),
              _buildMainGrid(context),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      toolbarHeight: 68,
      titleSpacing: 20,
      title: Row(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.point_of_sale_rounded, color: Colors.white, size: 19),
          ),
          const SizedBox(width: 10),
          const Text('Kasir', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
        ],
      ),
      actions: [
        IconActionButton(
          icon: Icons.notifications_none_rounded,
          tooltip: 'Notifikasi',
          onPressed: () => _showNotifications(context),
          backgroundColor: Colors.transparent,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 18, left: 5),
          child: PopupMenuButton<String>(
            tooltip: 'Menu akun',
            offset: const Offset(0, 46),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: (value) {
              if (value == 'switch') {
                _showUserSwitchDialog(context);
              } else if (value == 'settings') {
                onNavigateToTab(4);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'switch',
                child: Row(
                  children: [
                    const Icon(Icons.swap_horiz_rounded, size: 19),
                    const SizedBox(width: 10),
                    Text('Ganti akun (${state.currentUser.name})'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, size: 19),
                    SizedBox(width: 10),
                    Text('Pengaturan'),
                  ],
                ),
              ),
            ],
            child: CircleAvatar(
              radius: 17,
              backgroundColor: AppColors.primarySubtle,
              child: Text(
                state.currentUser.name.substring(0, 1),
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    final now = DateTime.now();
    final greeting = now.hour < 11 ? 'Selamat pagi' : now.hour < 15 ? 'Selamat siang' : now.hour < 19 ? 'Selamat sore' : 'Selamat malam';
    final shift = state.currentShift;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, ${state.currentUser.name.split(' ').first}!',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Berikut ringkasan performa tokomu hari ini.',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (shift != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.successSubtle,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.schedule_rounded, color: AppColors.success, size: 15),
                const SizedBox(width: 6),
                Text(
                  'Shift aktif sejak ${FormatUtils.formatTime(shift.startTime)}',
                  style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMetricGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int columns = constraints.maxWidth >= 1000 ? 4 : constraints.maxWidth >= 600 ? 2 : 2;
        final double aspect = constraints.maxWidth >= 600 ? 1.65 : 1.05;
        return GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: aspect,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            MetricCard(
              label: 'Omzet Hari Ini',
              value: FormatUtils.formatRupiah(state.totalRevenueToday),
              change: '+12.8%',
              icon: Icons.payments_rounded,
              accentColor: AppColors.primary,
            ),
            MetricCard(
              label: 'Total Transaksi',
              value: state.completedTransactionsCount.toString(),
              change: '+8.4%',
              icon: Icons.receipt_long_rounded,
              accentColor: AppColors.info,
            ),
            MetricCard(
              label: 'Laba Kotor',
              value: FormatUtils.formatRupiah(state.totalGrossProfitToday),
              change: '+15.2%',
              icon: Icons.trending_up_rounded,
              accentColor: AppColors.success,
            ),
            MetricCard(
              label: 'Rata-rata Transaksi',
              value: FormatUtils.formatRupiah(state.averageBasketSize),
              change: '+4.1%',
              icon: Icons.shopping_bag_rounded,
              accentColor: AppColors.purple,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMainGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool wide = constraints.maxWidth >= 900;
        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 6, child: _buildSalesChartCard(context)),
              const SizedBox(width: 16),
              Expanded(flex: 4, child: _buildQuickActionsCard(context)),
            ],
          );
        }
        return Column(
          children: [
            _buildSalesChartCard(context),
            const SizedBox(height: 16),
            _buildQuickActionsCard(context),
            const SizedBox(height: 16),
            _buildRecentTransactionsCard(context),
            const SizedBox(height: 16),
            _buildLowStockCard(context),
          ],
        );
      },
    );
  }

  Widget _buildSalesChartCard(BuildContext context) {
    const chartData = [
      0.42,
      0.53,
      0.47,
      0.71,
      0.59,
      0.82,
      0.68,
      0.91,
      0.74,
      0.88,
      0.80,
      0.97,
    ];
    const labels = ['08.00', '09.00', '10.00', '11.00', '12.00', '13.00', '14.00', '15.00', '16.00', '17.00', '18.00', '19.00'];

    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Tren Penjualan',
            subtitle: 'Performa omzet hari ini per jam',
            margin: EdgeInsets.zero,
            trailing: TabSegmentedControl(
              labels: const ['Hari ini', '7 hari', '30 hari'],
              selectedIndex: 0,
              onChanged: (_) {},
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 214,
            child: CustomPaint(
              painter: _SalesChartPainter(
                data: chartData,
                lineColor: AppColors.primary,
                fillColor: AppColors.primary.withOpacity(0.12),
                gridColor: AppColors.divider,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: labels.map((label) {
                      return Text(
                        label,
                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
              const SizedBox(width: 7),
              const Text('Omzet', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(width: 18),
              const Text('Puncak penjualan', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              const Spacer(),
              const Text('Rp 128,4 jt', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Akses Cepat',
            subtitle: 'Shortcut untuk operasional harian',
            margin: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          _buildQuickAction(
            context,
            icon: Icons.point_of_sale_rounded,
            title: 'Mulai Transaksi Baru',
            subtitle: 'Buka halaman kasir',
            color: AppColors.primary,
            onTap: () => onNavigateToTab(1),
          ),
          _buildQuickAction(
            context,
            icon: Icons.add_box_rounded,
            title: 'Tambah Produk',
            subtitle: 'Daftarkan item baru ke katalog',
            color: AppColors.info,
            onTap: () => onNavigateToTab(2),
          ),
          _buildQuickAction(
            context,
            icon: Icons.inventory_rounded,
            title: 'Cek Stok Menipis',
            subtitle: '${state.products.where((p) => p.isLowStock).length} produk perlu direstock',
            color: AppColors.warning,
            onTap: () => onNavigateToTab(2),
          ),
          _buildQuickAction(
            context,
            icon: Icons.file_download_rounded,
            title: 'Export Laporan',
            subtitle: 'Unduh ringkasan penjualan',
            color: AppColors.success,
            onTap: () => onNavigateToTab(3),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: color.withOpacity(0.11), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 3),
                      Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 19),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransactionsCard(BuildContext context) {
    final recent = state.transactions.where((t) => t.status == TransactionStatus.completed).take(4).toList();
    return GlassPanel(
      child: Column(
        children: [
          SectionHeader(
            title: 'Transaksi Terbaru',
            subtitle: 'Transaksi selesai hari ini',
            trailing: TextButton(
              onPressed: () => onNavigateToTab(3),
              child: const Text('Lihat semua'),
            ),
          ),
          ...recent.map((t) => _buildTransactionRow(t)),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(Transaction transaction) {
    final String initials = transaction.customerName.trim().isEmpty
        ? 'PG'
        : transaction.customerName.trim().split(' ').map((e) => e.substring(0, 1)).take(2).join().toUpperCase();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: AppColors.primarySubtle,
            child: Text(initials, style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.customerName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                Text('${transaction.invoiceNumber} • ${FormatUtils.formatTime(transaction.dateTime)}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(FormatUtils.formatRupiah(transaction.total), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 3),
              StatusBadge(label: paymentMethodLabel(transaction.paymentMethod), icon: paymentMethodIcon(transaction.paymentMethod), color: transaction.paymentMethod == PaymentMethod.cash ? AppColors.success : AppColors.info, compact: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockCard(BuildContext context) {
    final lowStock = state.products.where((p) => p.isLowStock).toList();
    return GlassPanel(
      child: Column(
        children: [
          SectionHeader(
            title: 'Perlu Restock',
            subtitle: 'Stok di bawah minimum alert',
            trailing: TextButton(
              onPressed: () => onNavigateToTab(2),
              child: const Text('Kelola stok'),
            ),
          ),
          ...lowStock.map((p) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  Container(width: 35, height: 35, decoration: BoxDecoration(color: AppColors.warningSubtle, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.inventory_2_rounded, color: AppColors.warning, size: 18)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
                  Text('${p.stock} ${p.unit}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.danger)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    final lowCount = state.products.where((p) => p.isLowStock).length;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Notifikasi Operasional', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                const SizedBox(height: 18),
                _notificationRow(Icons.inventory_rounded, AppColors.warning, '$lowCount produk stok menipis', 'Segera buat pesanan restock untuk menjaga penjualan.'),
                _notificationRow(Icons.cloud_done_rounded, AppColors.success, 'Backup lokal tersimpan', 'Data terakhir tersimpan di perangkat ini 12 menit lalu.'),
                _notificationRow(Icons.print_rounded, AppColors.info, 'Printer siap digunakan', state.isPrinterConnected ? 'RP-58 Bluetooth Thermal terhubung.' : 'Belum ada printer terhubung.'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _notificationRow(IconData icon, Color color, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 38, height: 38, decoration: BoxDecoration(color: color.withOpacity(0.11), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 19)),
          const SizedBox(width: 11),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)), const SizedBox(height: 3), Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3))])),
        ],
      ),
    );
  }

  void _showUserSwitchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Ganti Akun', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: state.users.map((user) {
            final active = user.id == state.currentUser.id;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(backgroundColor: active ? AppColors.primary : AppColors.surfaceSecondary, child: Text(user.name.substring(0, 1), style: TextStyle(color: active ? Colors.white : AppColors.textPrimary))),
              title: Text(user.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              subtitle: Text(user.roleTitle),
              trailing: active ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : const Icon(Icons.chevron_right_rounded),
              onTap: () {
                state.switchUser(user.id, user.pin);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SalesChartPainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final Color fillColor;
  final Color gridColor;

  const _SalesChartPainter({required this.data, required this.lineColor, required this.fillColor, required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    final double chartHeight = size.height - 27;
    final double chartWidth = size.width;
    const double topPad = 8;
    const double bottomPad = 17;

    final gridPaint = Paint()..color = gridColor..strokeWidth = 1;
    for (int i = 0; i < 4; i++) {
      final y = topPad + (chartHeight - topPad - bottomPad) * i / 3;
      canvas.drawLine(Offset(0, y), Offset(chartWidth, y), gridPaint);
    }

    final path = Path();
    final fillPath = Path();
    for (int i = 0; i < data.length; i++) {
      final x = chartWidth * i / (data.length - 1);
      final y = topPad + (chartHeight - topPad - bottomPad) * (1 - data[i]);
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, chartHeight - bottomPad);
        fillPath.lineTo(x, y);
      } else {
        final prevX = chartWidth * (i - 1) / (data.length - 1);
        final prevY = topPad + (chartHeight - topPad - bottomPad) * (1 - data[i - 1]);
        final controlX = (prevX + x) / 2;
        path.cubicTo(controlX, prevY, controlX, y, x, y);
        fillPath.cubicTo(controlX, prevY, controlX, y, x, y);
      }
    }
    fillPath.lineTo(chartWidth, chartHeight - bottomPad);
    fillPath.close();
    canvas.drawPath(fillPath, Paint()..color = fillColor);
    canvas.drawPath(path, Paint()..color = lineColor..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);

    for (int i = 0; i < data.length; i++) {
      final x = chartWidth * i / (data.length - 1);
      final y = topPad + (chartHeight - topPad - bottomPad) * (1 - data[i]);
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = AppColors.surface);
      canvas.drawCircle(Offset(x, y), 2.5, Paint()..color = lineColor);
    }
  }

  @override
  bool shouldRepaint(covariant _SalesChartPainter oldDelegate) => false;
}
