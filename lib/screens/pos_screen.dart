import 'package:flutter/material.dart';

import '../models/models.dart';
import '../state/pos_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class PosScreen extends StatefulWidget {
  final PosState state;

  const PosScreen({super.key, required this.state});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.state,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final bool isTabletLandscape = constraints.maxWidth >= 900;
            if (isTabletLandscape) {
              return Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: _buildCatalogSection(context),
                  ),
                  const VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: AppColors.border,
                  ),
                  SizedBox(
                    width: 380,
                    child: _buildCartPanel(context, isEmbedded: true),
                  ),
                ],
              );
            }

            return Stack(
              children: [
                _buildCatalogSection(
                  context,
                  bottomPadding: widget.state.cart.isNotEmpty ? 90 : 20,
                ),
                if (widget.state.cart.isNotEmpty)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: _buildFloatingCartBar(context),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCatalogSection(BuildContext context, {double bottomPadding = 20}) {
    final products = widget.state.filteredProducts;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppSearchField(
                        controller: _searchController,
                        hintText: 'Cari kopi, pastry, makanan, barcode...',
                        onChanged: (val) => widget.state.setSearchQuery(val),
                        onBarcodeTap: () => _simulateBarcodeScan(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildHoldOrderBadge(context),
                  ],
                ),
                const SizedBox(height: 12),
                _buildCategoryFilter(),
              ],
            ),
          ),
        ),
        if (products.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: Icons.search_off_rounded,
              title: 'Produk Tidak Ditemukan',
              subtitle: 'Coba ubah filter kategori atau kata kunci pencarian Anda.',
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(18, 6, 18, bottomPadding),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.76,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = products[index];
                  return ProductCard(
                    product: product,
                    onTap: () => _handleProductTap(context, product),
                  );
                },
                childCount: products.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          CategoryPill(
            category: const Category(
              id: 'all',
              name: 'Semua Menu',
              icon: Icons.grid_view_rounded,
              color: AppColors.primary,
            ),
            selected: widget.state.selectedCategoryId == 'all',
            onTap: () => widget.state.selectCategory('all'),
          ),
          const SizedBox(width: 8),
          ...widget.state.categories.map((cat) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CategoryPill(
                category: cat,
                selected: widget.state.selectedCategoryId == cat.id,
                onTap: () => widget.state.selectCategory(cat.id),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHoldOrderBadge(BuildContext context) {
    final holdOrders = widget.state.transactions.where((t) => t.status == TransactionStatus.hold).toList();
    if (holdOrders.isEmpty) return const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showHoldOrdersListModal(context),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.warningSubtle,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.warning.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.pause_circle_filled_rounded, color: AppColors.warning, size: 20),
              const SizedBox(width: 6),
              Text(
                'Hold (${holdOrders.length})',
                style: const TextStyle(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingCartBar(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: BorderRadius.circular(20),
      color: AppColors.surface,
      emphasized: true,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${widget.state.cartTotalQuantity} Item',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Total Tagihan',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                Text(
                  FormatUtils.formatRupiah(widget.state.cartTotal),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _showMobileCartSheet(context),
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: const Text('Buka Keranjang'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartPanel(BuildContext context, {bool isEmbedded = false}) {
    final cart = widget.state.cart;

    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: Row(
              children: [
                const Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Keranjang Pesanan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                if (cart.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => widget.state.clearCart(),
                    icon: const Icon(Icons.delete_sweep_rounded, size: 16, color: AppColors.danger),
                    label: const Text('Reset', style: TextStyle(color: AppColors.danger, fontSize: 12)),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (cart.isEmpty)
            const Expanded(
              child: EmptyState(
                icon: Icons.add_shopping_cart_rounded,
                title: 'Keranjang Kosong',
                subtitle: 'Ketuk produk di sebelah kiri untuk memasukkannya ke transaksi.',
              ),
            )
          else ...[
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: cart.length,
                separatorBuilder: (_, __) => const Divider(height: 20),
                itemBuilder: (context, index) {
                  final item = cart[index];
                  return _buildCartItemTile(context, item, index);
                },
              ),
            ),
            _buildCartSummaryAndActions(context),
          ],
        ],
      ),
    );
  }

  Widget _buildCartItemTile(BuildContext context, CartItem item, int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              if (item.selectedVariant != null) ...[
                const SizedBox(height: 2),
                Text(
                  'Varian: ${item.selectedVariant!.name}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
              if (item.note.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  'Catatan: ${item.note}',
                  style: const TextStyle(color: AppColors.primary, fontSize: 11, fontStyle: FontStyle.italic),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                FormatUtils.formatRupiah(item.subtotal),
                style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontSize: 13),
              ),
            ],
          ),
        ),
        QuantityStepper(
          quantity: item.quantity,
          compact: true,
          onChanged: (newQty) => widget.state.updateCartItemQuantity(index, newQty),
        ),
      ],
    );
  }

  Widget _buildCartSummaryAndActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _summaryRow('Subtotal', FormatUtils.formatRupiah(widget.state.cartSubtotal)),
          if (widget.state.cartCalculatedDiscount > 0)
            _summaryRow('Diskon', '-${FormatUtils.formatRupiah(widget.state.cartCalculatedDiscount)}', color: AppColors.danger),
          if (widget.state.cartTax > 0)
            _summaryRow('PPN (${widget.state.storeProfile.taxPercentage.toInt()}%)', FormatUtils.formatRupiah(widget.state.cartTax)),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Tagihan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
              Text(
                FormatUtils.formatRupiah(widget.state.cartTotal),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _handleHoldOrder(context),
                  icon: const Icon(Icons.pause_circle_outline_rounded, size: 18),
                  label: const Text('Hold'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () => _showPaymentSheet(context),
                  icon: const Icon(Icons.payment_rounded, size: 18),
                  label: const Text('Bayar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color ?? AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  void _handleProductTap(BuildContext context, Product product) {
    if (product.variants.isNotEmpty) {
      _showVariantSelectorModal(context, product);
    } else {
      widget.state.addToCart(product);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} dimasukkan ke keranjang'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showVariantSelectorModal(BuildContext context, Product product) {
    ProductVariant selectedVariant = product.variants.first;
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Harga Dasar: ${FormatUtils.formatRupiah(product.price)}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  const Text('Pilih Varian / Opsi:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: product.variants.map((v) {
                      final isSelected = v.id == selectedVariant.id;
                      return ChoiceChip(
                        label: Text('${v.name} ${v.additionalPrice > 0 ? '(+${FormatUtils.formatRupiah(v.additionalPrice)})' : ''}'),
                        selected: isSelected,
                        selectedColor: AppColors.primarySubtle,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() => selectedVariant = v);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      labelText: 'Catatan Khusus (misal: Less Sugar / Tanpa Sambal)',
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.state.addToCart(
                          product,
                          variant: selectedVariant,
                          note: noteController.text,
                        );
                        Navigator.pop(ctx);
                      },
                      child: Text(
                        'Tambah — ${FormatUtils.formatRupiah(product.price + selectedVariant.additionalPrice)}',
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showMobileCartSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.85,
          child: _buildCartPanel(ctx),
        );
      },
    );
  }

  void _handleHoldOrder(BuildContext context) {
    final nameController = TextEditingController(text: widget.state.activeCustomerName);
    final tableController = TextEditingController(text: widget.state.activeTableNumber);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Simpan Sementara (Hold)', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Transaksi akan disimpan dan keranjang dikosongkan untuk melayani pelanggan berikutnya.'),
            const SizedBox(height: 14),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama Pelanggan / Catatan'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: tableController,
              decoration: const InputDecoration(labelText: 'No. Meja (Opsional)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              widget.state.holdCurrentOrder(
                customerName: nameController.text.isNotEmpty ? nameController.text : null,
                tableNumber: tableController.text.isNotEmpty ? tableController.text : null,
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pesanan berhasil disimpan di tab Hold')),
              );
            },
            child: const Text('Simpan Pesanan'),
          ),
        ],
      ),
    );
  }

  void _showHoldOrdersListModal(BuildContext context) {
    final holdOrders = widget.state.transactions.where((t) => t.status == TransactionStatus.hold).toList();

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.72,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.pause_circle_filled_rounded, color: AppColors.warning),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Daftar Pesanan Tertunda (Hold)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: ListView.builder(
                      itemCount: holdOrders.length,
                      itemBuilder: (context, index) {
                        final ho = holdOrders[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            title: Text(ho.customerName, style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: Text('${ho.invoiceNumber} • ${ho.items.length} item • ${ho.tableNumber}'),
                            trailing: ElevatedButton(
                              onPressed: () {
                                widget.state.recallHoldOrder(ho);
                                Navigator.pop(ctx);
                              },
                              child: const Text('Lanjutkan'),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPaymentSheet(BuildContext context) {
    PaymentMethod selectedMethod = PaymentMethod.cash;
    final total = widget.state.cartTotal;
    final nominalSuggestions = [
      total,
      (total / 10000).ceil() * 10000.0,
      (total / 50000).ceil() * 50000.0,
      100000.0,
      200000.0,
    ].toSet().where((n) => n >= total).toList()..sort();

    double receivedCash = nominalSuggestions.isNotEmpty ? nominalSuggestions.first : total;
    final customerController = TextEditingController(text: widget.state.activeCustomerName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final double change = (receivedCash - total).clamp(0, double.infinity);

            return Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Checkout & Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        Text(
                          FormatUtils.formatRupiah(total),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Metode Pembayaran:', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        PaymentMethod.cash,
                        PaymentMethod.qris,
                        PaymentMethod.transfer,
                        PaymentMethod.debit,
                        PaymentMethod.debt,
                      ].map((m) {
                        final isSelected = m == selectedMethod;
                        return ChoiceChip(
                          avatar: Icon(paymentMethodIcon(m), size: 16, color: isSelected ? AppColors.primary : AppColors.textSecondary),
                          label: Text(paymentMethodLabel(m)),
                          selected: isSelected,
                          selectedColor: AppColors.primarySubtle,
                          onSelected: (sel) {
                            if (sel) setModalState(() => selectedMethod = m);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    if (selectedMethod == PaymentMethod.cash) ...[
                      const Text('Pilihan Uang Tunai Diterima:', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: nominalSuggestions.map((nom) {
                          final isSelected = nom == receivedCash;
                          return ActionChip(
                            label: Text(FormatUtils.formatRupiah(nom)),
                            backgroundColor: isSelected ? AppColors.primary : AppColors.surfaceSecondary,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                            onPressed: () => setModalState(() => receivedCash = nom),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSecondary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Kembalian Pelanggan:', style: TextStyle(fontWeight: FontWeight.w600)),
                            Text(
                              FormatUtils.formatRupiah(change),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.success),
                            ),
                          ],
                        ),
                      ),
                    ] else if (selectedMethod == PaymentMethod.qris) ...[
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.qr_code_2_rounded, size: 120, color: AppColors.textPrimary),
                              const SizedBox(height: 6),
                              Text('QRIS Dinamis Toko • ${FormatUtils.formatRupiah(total)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    TextField(
                      controller: customerController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Pelanggan (Opsional)',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_rounded),
                        label: const Text('Konfirmasi & Cetak Struk'),
                        onPressed: () {
                          final tx = widget.state.checkout(
                            paymentMethod: selectedMethod,
                            cashReceived: selectedMethod == PaymentMethod.cash ? receivedCash : total,
                            cashChange: selectedMethod == PaymentMethod.cash ? change : 0.0,
                            customerName: customerController.text,
                          );
                          Navigator.pop(ctx);
                          _showTransactionSuccessDialog(context, tx);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showTransactionSuccessDialog(BuildContext context, Transaction tx) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: AppColors.successSubtle,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: AppColors.success, size: 36),
            ),
            const SizedBox(height: 16),
            const Text('Transaksi Berhasil!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(tx.invoiceNumber, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const Divider(height: 24),
            _summaryRow('Total Pembayaran', FormatUtils.formatRupiah(tx.total)),
            _summaryRow('Metode', paymentMethodLabel(tx.paymentMethod)),
            if (tx.paymentMethod == PaymentMethod.cash) ...[
              _summaryRow('Uang Diterima', FormatUtils.formatRupiah(tx.cashReceived)),
              _summaryRow('Kembalian', FormatUtils.formatRupiah(tx.cashChange), color: AppColors.success),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Struk berhasil dicetak ulang ke Thermal Printer')),
                      );
                    },
                    icon: const Icon(Icons.print_rounded, size: 16),
                    label: const Text('Cetak'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Selesai'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _simulateBarcodeScan(BuildContext context) async {
    final codeController = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Scan Barcode'),
        content: TextField(
          controller: codeController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Kode barcode / SKU',
            hintText: 'Contoh: 8991001001',
          ),
          onSubmitted: (value) => Navigator.pop(ctx, value),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, codeController.text), child: const Text('Cari & Tambah')),
        ],
      ),
    );
    if (!context.mounted || code == null) return;

    final product = widget.state.findProductByBarcode(code);
    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Barcode tidak ditemukan: ${code.trim()}')),
      );
      return;
    }
    final added = widget.state.addToCart(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added
              ? 'Scan Barcode: ${product.name} dimasukkan (+1)'
              : 'Stok ${product.name} tidak mencukupi',
        ),
      ),
    );
  }
}
