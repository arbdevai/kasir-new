import 'package:flutter/material.dart';
import '../models/models.dart';
import '../state/pos_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class ProductsScreen extends StatefulWidget {
  final PosState state;
  const ProductsScreen({super.key, required this.state});
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  int _tabIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.state,
      builder: (context, _) {
        return CustomScrollView(
          slivers: [
            const SliverAppBar(
              floating: true, pinned: true, toolbarHeight: 64, titleSpacing: 20,
              title: Text('Produk & Stok', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (v) => setState(() => _query = v),
                            decoration: const InputDecoration(
                              hintText: 'Cari nama, SKU, barcode...',
                              prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconActionButton(
                          icon: Icons.add_rounded, tooltip: 'Tambah produk',
                          color: Colors.white, backgroundColor: AppColors.primary,
                          onPressed: () => _showProductForm(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _tabs(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            if (_tabIndex == 0) _catalogSliver(context)
            else if (_tabIndex == 1) _mutationsSliver(context)
            else _categoriesSliver(context),
          ],
        );
      },
    );
  }

  Widget _tabs() {
    const labels = ['Katalog', 'Mutasi Stok', 'Kategori'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.surfaceSecondary, borderRadius: BorderRadius.circular(13)),
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
                  boxShadow: sel ? const [BoxShadow(color: Color(0x12000000), blurRadius: 5, offset: Offset(0, 2))] : null,
                ),
                child: Center(
                  child: Text(e.value, style: TextStyle(fontSize: 12, fontWeight: sel ? FontWeight.w700 : FontWeight.w500, color: sel ? AppColors.textPrimary : AppColors.textSecondary)),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Product> get _filteredProducts {
    return widget.state.products.where((p) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return p.name.toLowerCase().contains(q) || p.sku.toLowerCase().contains(q) || p.barcode.contains(q);
    }).toList();
  }

  Widget _catalogSliver(BuildContext context) {
    final list = _filteredProducts;
    if (list.isEmpty) {
      return SliverToBoxAdapter(
        child: EmptyState(
          icon: Icons.inventory_2_outlined, title: 'Belum Ada Produk',
          subtitle: 'Tambahkan produk pertama untuk mulai berjualan.',
          action: ElevatedButton.icon(onPressed: () => _showProductForm(context), icon: const Icon(Icons.add_rounded), label: const Text('Tambah Produk')),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
      sliver: SliverList.separated(
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) => _productRow(context, list[i]),
      ),
    );
  }

  Widget _productRow(BuildContext context, Product p) {
    return GlassPanel(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(color: AppColors.primarySubtle, borderRadius: BorderRadius.circular(13)),
            child: Center(child: Text(p.name.substring(0, 1).toUpperCase(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 3),
                Text('${p.sku} • ${p.categoryName}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(FormatUtils.formatRupiah(p.price), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    const SizedBox(width: 8),
                    StatusBadge(
                      label: p.isLowStock ? 'Menipis (${p.stock})' : '${p.stock} ${p.unit}',
                      icon: p.isLowStock ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
                      color: p.isLowStock ? AppColors.warning : AppColors.success, compact: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, size: 19),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (v) {
              if (v == 'edit') _showProductForm(context, existing: p);
              else if (v == 'stock') _showStockDialog(context, p);
              else if (v == 'delete') widget.state.deleteProduct(p.id);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit produk')),
              PopupMenuItem(value: 'stock', child: Text('Atur stok')),
              PopupMenuItem(value: 'delete', child: Text('Hapus')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mutationsSliver(BuildContext context) {
    final muts = widget.state.stockMutations;
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
      sliver: SliverList.separated(
        itemCount: muts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final m = muts[i];
          final bool positive = m.qty > 0;
          final Color c;
          switch (m.type) {
            case StockMutationType.inbound: c = AppColors.success; break;
            case StockMutationType.outbound: c = AppColors.danger; break;
            case StockMutationType.adjustment: c = AppColors.warning; break;
            case StockMutationType.sale: c = AppColors.info; break;
          }
          return GlassPanel(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: c.withOpacity(0.11), borderRadius: BorderRadius.circular(11)),
                  child: Icon(positive ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: c, size: 19)),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.productName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text('${stockMutationTypeLabel(m.type)} • ${m.note}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      const SizedBox(height: 2),
                      Text('${m.previousStock} → ${m.currentStock} • ${FormatUtils.formatTime(m.timestamp)} • ${m.cashierName}', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                Text('${positive ? '+' : ''}${m.qty}', style: TextStyle(fontWeight: FontWeight.w800, color: c)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _categoriesSliver(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 240, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.5),
        delegate: SliverChildBuilderDelegate((context, i) {
          final cat = widget.state.categories[i];
          final count = widget.state.products.where((p) => p.categoryId == cat.id).length;
          return GlassPanel(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Container(width: 42, height: 42, decoration: BoxDecoration(color: cat.color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)), child: Icon(cat.icon, color: cat.color, size: 21)),
                const SizedBox(width: 11),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)), Text('$count produk', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))])),
              ],
            ),
          );
        }, childCount: widget.state.categories.length),
      ),
    );
  }

  void _showProductForm(BuildContext context, {Product? existing}) {
    final nameC = TextEditingController(text: existing?.name ?? '');
    final skuC = TextEditingController(text: existing?.sku ?? '');
    final priceC = TextEditingController(text: existing != null ? existing.price.toStringAsFixed(0) : '');
    final stockC = TextEditingController(text: existing != null ? existing.stock.toString() : '0');
    String catId = existing?.categoryId ?? widget.state.categories.first.id;

    showModalBottomSheet(
      context: context, isScrollControlled: true, showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModal) => Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(existing == null ? 'Tambah Produk Baru' : 'Edit Produk', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 14),
                TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Nama produk')),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: TextField(controller: skuC, decoration: const InputDecoration(labelText: 'SKU / Kode'))),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: priceC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Harga jual (Rp)'))),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: TextField(controller: stockC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stok awal'))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: catId,
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      items: widget.state.categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                      onChanged: (v) => setModal(() => catId = v ?? catId),
                    ),
                  ),
                ]),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final cat = widget.state.categories.firstWhere((c) => c.id == catId);
                      final price = double.tryParse(priceC.text) ?? 0;
                      final stock = int.tryParse(stockC.text) ?? 0;
                      if (nameC.text.isEmpty || price <= 0) return;
                      if (existing == null) {
                        widget.state.addProduct(Product(
                          id: 'p_${DateTime.now().millisecondsSinceEpoch}',
                          name: nameC.text, sku: skuC.text.isEmpty ? 'SKU-${DateTime.now().millisecondsSinceEpoch % 10000}' : skuC.text,
                          barcode: DateTime.now().millisecondsSinceEpoch.toString(),
                          price: price, costPrice: price * 0.45, stock: stock, unit: 'Pcs',
                          categoryId: cat.id, categoryName: cat.name,
                        ));
                      } else {
                        widget.state.updateProduct(existing.copyWith(name: nameC.text, sku: skuC.text, price: price, stock: stock, categoryId: cat.id, categoryName: cat.name));
                      }
                      Navigator.pop(ctx);
                    },
                    child: Text(existing == null ? 'Simpan Produk' : 'Simpan Perubahan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showStockDialog(BuildContext context, Product p) {
    final qtyC = TextEditingController();
    final noteC = TextEditingController();
    StockMutationType type = StockMutationType.inbound;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setD) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Atur Stok — ${p.name}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<StockMutationType>(
                segments: const [
                  ButtonSegment(value: StockMutationType.inbound, label: Text('Masuk')),
                  ButtonSegment(value: StockMutationType.outbound, label: Text('Keluar')),
                  ButtonSegment(value: StockMutationType.adjustment, label: Text('Opname')),
                ],
                selected: {type},
                onSelectionChanged: (s) => setD(() => type = s.first),
              ),
              const SizedBox(height: 12),
              TextField(controller: qtyC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Jumlah (angka positif)')),
              const SizedBox(height: 10),
              TextField(controller: noteC, decoration: const InputDecoration(labelText: 'Catatan mutasi')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                final qty = int.tryParse(qtyC.text) ?? 0;
                if (qty <= 0) return;
                final delta = type == StockMutationType.inbound ? qty : -qty;
                widget.state.recordStockAdjustment(productId: p.id, type: type, quantityDelta: delta, note: noteC.text.isEmpty ? stockMutationTypeLabel(type) : noteC.text);
                Navigator.pop(ctx);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
