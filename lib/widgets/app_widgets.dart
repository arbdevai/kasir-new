import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius borderRadius;
  final Color? color;
  final bool emphasized;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.color,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? (emphasized ? AppColors.primarySubtle : AppColors.surface),
        borderRadius: borderRadius,
        border: Border.all(
          color: emphasized ? AppColors.primary.withOpacity(0.15) : AppColors.border,
        ),
        boxShadow: emphasized
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.08),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ]
            : [
                const BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 20,
                  offset: Offset(0, 6),
                ),
              ],
      ),
      child: child,
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry margin;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.margin = const EdgeInsets.only(bottom: 14),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color? backgroundColor;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    this.backgroundColor,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 5 : 7,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withOpacity(0.11),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 12 : 14, color: color),
          SizedBox(width: compact ? 4 : 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String? change;
  final IconData icon;
  final Color accentColor;
  final bool isPositive;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    this.change,
    required this.icon,
    required this.accentColor,
    this.isPositive = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 20,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.11),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: accentColor, size: 20),
                  ),
                  const Spacer(),
                  if (change != null)
                    StatusBadge(
                      label: change!,
                      icon: isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      color: isPositive ? AppColors.success : AppColors.danger,
                      compact: true,
                    ),
                ],
              ),
              const Spacer(),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.primarySubtle,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 32),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: 22),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class AppSearchField extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onBarcodeTap;
  final TextEditingController? controller;

  const AppSearchField({
    super.key,
    this.hintText = 'Cari produk, SKU, atau scan barcode...',
    this.onChanged,
    this.onBarcodeTap,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 22),
        suffixIcon: IconButton(
          tooltip: 'Scan barcode',
          onPressed: onBarcodeTap,
          icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary),
        ),
      ),
    );
  }
}

class CategoryPill extends StatelessWidget {
  final Category category;
  final bool selected;
  final VoidCallback onTap;

  const CategoryPill({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? AppColors.primary : AppColors.border),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 13,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                category.icon,
                size: 16,
                color: selected ? AppColors.textInverse : category.color,
              ),
              const SizedBox(width: 7),
              Text(
                category.name,
                style: TextStyle(
                  color: selected ? AppColors.textInverse : AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool compact;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onLongPress,
    this.compact = false,
  });

  Color get _productColor {
    final String id = product.id;
    if (id.contains('1') || product.categoryId == 'cat_coffee') return AppColors.primary;
    if (product.categoryId == 'cat_tea') return AppColors.success;
    if (product.categoryId == 'cat_bakery') return AppColors.warning;
    if (product.categoryId == 'cat_food') return AppColors.info;
    return AppColors.purple;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x07000000),
                blurRadius: 16,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(compact ? 10 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: compact ? 10 : 11,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _productColor.withOpacity(0.16),
                                _productColor.withOpacity(0.045),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Icon(
                              _productIcon,
                              size: compact ? 38 : 48,
                              color: _productColor.withOpacity(0.9),
                            ),
                          ),
                        ),
                      ),
                      if (product.isLowStock)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: StatusBadge(
                            label: 'Menipis',
                            icon: Icons.warning_amber_rounded,
                            color: AppColors.warning,
                            compact: true,
                          ),
                        ),
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Container(
                          width: compact ? 29 : 32,
                          height: compact ? 29 : 32,
                          decoration: const BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x16000000),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.add_rounded, color: AppColors.primary, size: 21),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: compact ? 9 : 12),
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 12 : 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        FormatUtils.formatRupiah(product.price),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: compact ? 12 : 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      '${product.stock} ${product.unit}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData get _productIcon {
    switch (product.categoryId) {
      case 'cat_coffee':
        return Icons.local_cafe_rounded;
      case 'cat_tea':
        return Icons.local_drink_rounded;
      case 'cat_bakery':
        return Icons.bakery_dining_rounded;
      case 'cat_food':
        return Icons.ramen_dining_rounded;
      case 'cat_snack':
        return Icons.icecream_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }
}

class QuantityStepper extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;
  final bool compact;

  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepperButton(
            icon: quantity <= 1 ? Icons.delete_outline_rounded : Icons.remove_rounded,
            onTap: () => onChanged(quantity - 1),
            color: quantity <= 1 ? AppColors.danger : AppColors.textSecondary,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10),
            child: Text(
              quantity.toString(),
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: compact ? 12 : 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _stepperButton(
            icon: Icons.add_rounded,
            onTap: () => onChanged(quantity + 1),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _stepperButton({required IconData icon, required VoidCallback onTap, required Color color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: EdgeInsets.all(compact ? 7 : 8),
        child: Icon(icon, size: compact ? 14 : 16, color: color),
      ),
    );
  }
}

class PrimaryActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool expanded;

  const PrimaryActionButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class IconActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;

  const IconActionButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: backgroundColor ?? AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: color ?? AppColors.textPrimary, size: 19),
          ),
        ),
      ),
    );
  }
}

class ResponsiveContent extends StatelessWidget {
  final Widget phone;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveContent({
    super.key,
    required this.phone,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200 && desktop != null) {
          return desktop!;
        }
        if (constraints.maxWidth >= 700 && tablet != null) {
          return tablet!;
        }
        return phone;
      },
    );
  }
}

class TabSegmentedControl extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const TabSegmentedControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: labels.asMap().entries.map((entry) {
          final bool selected = entry.key == selectedIndex;
          return GestureDetector(
            onTap: () => onChanged(entry.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppColors.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                boxShadow: selected
                    ? const [
                        BoxShadow(
                          color: Color(0x12000000),
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                entry.value,
                style: TextStyle(
                  color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class AppNavigationItem {
  final String label;
  final IconData icon;

  const AppNavigationItem({required this.label, required this.icon});
}

const List<AppNavigationItem> appNavigationItems = [
  AppNavigationItem(label: 'Dashboard', icon: Icons.space_dashboard_rounded),
  AppNavigationItem(label: 'Kasir', icon: Icons.point_of_sale_rounded),
  AppNavigationItem(label: 'Produk', icon: Icons.inventory_2_rounded),
  AppNavigationItem(label: 'Laporan', icon: Icons.bar_chart_rounded),
  AppNavigationItem(label: 'Pengaturan', icon: Icons.settings_rounded),
];

String paymentMethodLabel(PaymentMethod method) {
  switch (method) {
    case PaymentMethod.cash:
      return 'Tunai';
    case PaymentMethod.qris:
      return 'QRIS';
    case PaymentMethod.transfer:
      return 'Transfer';
    case PaymentMethod.debit:
      return 'Kartu Debit';
    case PaymentMethod.debt:
      return 'Kasbon';
    case PaymentMethod.split:
      return 'Split Payment';
  }
}

IconData paymentMethodIcon(PaymentMethod method) {
  switch (method) {
    case PaymentMethod.cash:
      return Icons.payments_rounded;
    case PaymentMethod.qris:
      return Icons.qr_code_2_rounded;
    case PaymentMethod.transfer:
      return Icons.account_balance_rounded;
    case PaymentMethod.debit:
      return Icons.credit_card_rounded;
    case PaymentMethod.debt:
      return Icons.receipt_long_rounded;
    case PaymentMethod.split:
      return Icons.call_split_rounded;
  }
}

Color transactionStatusColor(TransactionStatus status) {
  switch (status) {
    case TransactionStatus.completed:
      return AppColors.success;
    case TransactionStatus.hold:
      return AppColors.warning;
    case TransactionStatus.debt:
      return AppColors.info;
    case TransactionStatus.voided:
      return AppColors.danger;
  }
}

String transactionStatusLabel(TransactionStatus status) {
  switch (status) {
    case TransactionStatus.completed:
      return 'Selesai';
    case TransactionStatus.hold:
      return 'Tertunda';
    case TransactionStatus.debt:
      return 'Kasbon';
    case TransactionStatus.voided:
      return 'Dibatalkan';
  }
}

String stockMutationTypeLabel(StockMutationType type) {
  switch (type) {
    case StockMutationType.inbound:
      return 'Stok Masuk';
    case StockMutationType.outbound:
      return 'Stok Keluar';
    case StockMutationType.adjustment:
      return 'Penyesuaian';
    case StockMutationType.sale:
      return 'Penjualan';
  }
}
