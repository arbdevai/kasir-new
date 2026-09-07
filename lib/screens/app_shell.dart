import 'package:flutter/material.dart';

import '../models/models.dart';
import '../state/pos_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'dashboard_screen.dart';
import 'pos_screen.dart';
import 'products_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';

class AppShell extends StatefulWidget {
  final PosState state;

  const AppShell({super.key, required this.state});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(
        state: widget.state,
        onNavigateToTab: _navigateToTab,
        onRequestUserSwitch: () => _showUserSwitchDialog(context),
      ),
      PosScreen(state: widget.state),
      ProductsScreen(state: widget.state),
      ReportsScreen(state: widget.state),
      SettingsScreen(state: widget.state),
    ];
  }

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.state,
      builder: (context, _) => LayoutBuilder(
        builder: (context, constraints) {
          final bool isTablet = constraints.maxWidth >= 780;
        return Scaffold(
          body: isTablet
              ? Row(
                  children: [
                    _buildTabletSidebar(context),
                    const VerticalDivider(width: 1, thickness: 1, color: AppColors.border),
                    Expanded(
                      child: IndexedStack(
                        index: _currentIndex,
                        children: _screens,
                      ),
                    ),
                  ],
                )
              : SafeArea(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: _screens,
                  ),
                ),
          bottomNavigationBar: isTablet ? null : _buildMobileBottomBar(context),
        );
        },
      ),
    );
  }

  Widget _buildTabletSidebar(BuildContext context) {
    final holdCount = widget.state.transactions.where((t) => t.status == TransactionStatus.hold).length;
    final lowStockCount = widget.state.products.where((p) => p.isLowStock).length;

    return Container(
      width: 250,
      color: AppColors.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.point_of_sale_rounded, color: Colors.white, size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.state.storeProfile.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Expanded(
                            child: Text(
                              'Offline POS Active',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              softWrap: false,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildSidebarItem(
                  index: 0,
                  icon: Icons.space_dashboard_rounded,
                  label: 'Dashboard',
                ),
                _buildSidebarItem(
                  index: 1,
                  icon: Icons.point_of_sale_rounded,
                  label: 'Kasir',
                  badgeCount: widget.state.cartTotalQuantity > 0
                      ? widget.state.cartTotalQuantity
                      : (holdCount > 0 ? holdCount : null),
                  badgeColor: widget.state.cartTotalQuantity > 0 ? AppColors.primary : AppColors.warning,
                ),
                _buildSidebarItem(
                  index: 2,
                  icon: Icons.inventory_2_rounded,
                  label: 'Produk',
                  badgeCount: lowStockCount > 0 ? lowStockCount : null,
                  badgeColor: AppColors.danger,
                ),
                _buildSidebarItem(
                  index: 3,
                  icon: Icons.bar_chart_rounded,
                  label: 'Laporan',
                ),
                _buildSidebarItem(
                  index: 4,
                  icon: Icons.settings_rounded,
                  label: 'Pengaturan',
                ),
              ],
            ),
          ),
          _buildUserShiftFooter(context),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required int index,
    required IconData icon,
    required String label,
    int? badgeCount,
    Color badgeColor = AppColors.primary,
  }) {
    final bool isSelected = _currentIndex == index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToTab(index),
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primarySubtle : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (badgeCount != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badgeCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserShiftFooter(BuildContext context) {
    final user = widget.state.currentUser;
    final shift = widget.state.currentShift;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: AppColors.surfaceSecondary,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => _showUserSwitchDialog(context),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      user.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          user.roleTitle,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.swap_horiz_rounded, size: 18, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _showShiftDialog(context),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(
                    shift != null ? Icons.schedule_rounded : Icons.lock_outline_rounded,
                    size: 14,
                    color: shift != null ? AppColors.success : AppColors.warning,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      shift != null ? 'Shift Aktif' : 'Shift Ditutup',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: shift != null ? AppColors.success : AppColors.warning,
                      ),
                    ),
                  ),
                  Text(
                    shift != null ? FormatUtils.formatRupiah(shift.expectedCash) : 'Buka',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBottomBar(BuildContext context) {
    final holdCount = widget.state.transactions.where((t) => t.status == TransactionStatus.hold).length;
    final cartCount = widget.state.cartTotalQuantity;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _navigateToTab,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primarySubtle,
        elevation: 0,
        height: 64,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.space_dashboard_outlined, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.space_dashboard_rounded, color: AppColors.primary),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: cartCount > 0 || holdCount > 0,
              label: Text('${cartCount > 0 ? cartCount : holdCount}'),
              backgroundColor: cartCount > 0 ? AppColors.primary : AppColors.warning,
              child: const Icon(Icons.point_of_sale_outlined, color: AppColors.textSecondary),
            ),
            selectedIcon: Badge(
              isLabelVisible: cartCount > 0 || holdCount > 0,
              label: Text('${cartCount > 0 ? cartCount : holdCount}'),
              backgroundColor: cartCount > 0 ? AppColors.primary : AppColors.warning,
              child: const Icon(Icons.point_of_sale_rounded, color: AppColors.primary),
            ),
            label: 'Kasir',
          ),
          const NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.inventory_2_rounded, color: AppColors.primary),
            label: 'Produk',
          ),
          const NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.bar_chart_rounded, color: AppColors.primary),
            label: 'Laporan',
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.settings_rounded, color: AppColors.primary),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }

  void _showUserSwitchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => UserSwitchDialog(state: widget.state),
    );
  }

  void _showShiftDialog(BuildContext context) {
    final shift = widget.state.currentShift;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.schedule_rounded, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                shift != null ? 'Informasi Shift Kasir' : 'Buka Shift Baru',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: shift != null
              ? SizedBox(
                  width: 340,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _shiftRow('Kasir Bertugas', shift.cashierName),
                      _shiftRow('Waktu Buka', FormatUtils.formatTime(shift.startTime)),
                      const Divider(height: 16),
                      _shiftRow('Modal Awal Kasir', FormatUtils.formatRupiah(shift.startingCash)),
                      _shiftRow('Total Penjualan Tunai', FormatUtils.formatRupiah(shift.cashSales)),
                      _shiftRow('Kas Masuk (Petty Cash)', FormatUtils.formatRupiah(shift.cashIn)),
                      _shiftRow('Kas Keluar (Operasional)', FormatUtils.formatRupiah(shift.cashOut)),
                      const Divider(height: 16),
                      _shiftRow(
                        'Total Kas di Laci (Sistem)',
                        FormatUtils.formatRupiah(shift.expectedCash),
                        isBold: true,
                        valueColor: AppColors.primary,
                      ),
                    ],
                  ),
                )
              : const Text('Shift kasir saat ini ditutup. Anda dapat membuka shift dengan modal awal.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tutup'),
            ),
            if (shift != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _showCloseShiftDialog(context, shift);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                child: const Text('Tutup Shift (Z-Report)'),
              )
            else
              ElevatedButton(
                onPressed: () {
                  widget.state.startNewShift(200000);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Shift kasir dibuka dengan modal Rp 200.000')),
                  );
                },
                child: const Text('Buka Shift'),
              ),
          ],
        );
      },
    );
  }

  Widget _shiftRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showCloseShiftDialog(BuildContext context, Shift shift) {
    final actualController = TextEditingController(text: shift.expectedCash.toStringAsFixed(0));
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Tutup Shift Kasir (Z-Report)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Kas yang seharusnya di laci: ${FormatUtils.formatRupiah(shift.expectedCash)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: actualController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Uang Fisik Aktual (Rp)',
                  prefixText: 'Rp ',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Catatan Penutupan Shift (Opsional)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final double actual = double.tryParse(actualController.text) ?? shift.expectedCash;
                widget.state.closeCurrentShift(actual, noteController.text);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Shift berhasil ditutup & Z-Report dicetak')),
                );
              },
              child: const Text('Simpan & Tutup Shift'),
            ),
          ],
        );
      },
    );
  }
}
