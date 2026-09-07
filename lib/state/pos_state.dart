import 'package:flutter/material.dart';

import '../data/settings_repository.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

// Persistence is intentionally fire-and-forget so existing synchronous state
// APIs remain compatible with the UI.
void _ignorePersistenceError(Future<bool> operation) {
  operation.catchError((_) => false);
}

PrinterSettings _printerSettingsFromState(PosState state) => PrinterSettings(
      name: state.selectedPrinterName,
      paperSize: state.selectedPaperSize,
      isConnected: state.isPrinterConnected,
    );

PosState _applyPersistedSettings(PosState state, SettingsRepository repository) {
  state.settingsRepository = repository;
  state.storeProfile = repository.loadStoreProfile();
  final printer = repository.loadPrinterSettings();
  state.selectedPrinterName = printer.name;
  state.selectedPaperSize = printer.paperSize;
  state.isPrinterConnected = printer.isConnected;
  return state;
}

enum SalesPeriod { today, sevenDays, thirtyDays }

class SalesChartData {
  final SalesPeriod period;
  final List<String> labels;
  final List<double> values;

  const SalesChartData({required this.period, required this.labels, required this.values});

  double get total => values.fold(0.0, (sum, value) => sum + value);
  double get maxValue => values.fold(0.0, (max, value) => value > max ? value : max);
}

class OperationalAlert {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int navigationTab;
  final bool requiresAction;

  const OperationalAlert({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.navigationTab,
    this.requiresAction = true,
  });
}

PosState createPosState(SettingsRepository repository) {
  return _applyPersistedSettings(PosState.sample(), repository);
}

class PosState extends ChangeNotifier {
  // Store Profile
  StoreProfile storeProfile;

  // Users & Authentication
  List<UserAccount> users;
  UserAccount currentUser;

  // Catalog
  List<Category> categories;
  List<Product> products;
  String selectedCategoryId;
  String searchQuery;

  // Active Cart
  List<CartItem> cart;
  double orderDiscountPercent;
  double orderDiscountNominal;
  String activeCustomerName;
  String activeTableNumber;
  String activeOrderNote;

  // Orders / Transactions
  List<Transaction> transactions;

  // Stock Mutations
  List<StockMutation> stockMutations;

  // Active Shift
  Shift? currentShift;
  List<Shift> pastShifts;

  // Printer Settings
  String selectedPrinterName;
  String selectedPaperSize; // '58mm' or '80mm'
  bool isPrinterConnected;

  SettingsRepository? settingsRepository;

  PosState({
    this.settingsRepository,
    required this.storeProfile,
    required this.users,
    required this.currentUser,
    required this.categories,
    required this.products,
    this.selectedCategoryId = 'all',
    this.searchQuery = '',
    required this.cart,
    this.orderDiscountPercent = 0.0,
    this.orderDiscountNominal = 0.0,
    this.activeCustomerName = '',
    this.activeTableNumber = '',
    this.activeOrderNote = '',
    required this.transactions,
    required this.stockMutations,
    this.currentShift,
    required this.pastShifts,
    this.selectedPrinterName = 'RP-58 Bluetooth Thermal (Connected)',
    this.selectedPaperSize = '58mm',
    this.isPrinterConnected = true,
  });

  factory PosState.sample({StoreProfile? storeProfile}) {
    final StoreProfile profile = storeProfile ?? const StoreProfile();

    final List<Category> cats = [
      const Category(
        id: 'cat_coffee',
        name: 'Kopi & Espresso',
        icon: Icons.coffee_rounded,
        color: Color(0xFFFF6B00),
      ),
      const Category(
        id: 'cat_tea',
        name: 'Teh & Non-Kopi',
        icon: Icons.local_drink_rounded,
        color: Color(0xFF34C759),
      ),
      const Category(
        id: 'cat_bakery',
        name: 'Roti & Pastry',
        icon: Icons.bakery_dining_rounded,
        color: Color(0xFFFF9500),
      ),
      const Category(
        id: 'cat_food',
        name: 'Makanan Berat',
        icon: Icons.restaurant_rounded,
        color: Color(0xFF007AFF),
      ),
      const Category(
        id: 'cat_snack',
        name: 'Camilan & Dessert',
        icon: Icons.cookie_rounded,
        color: Color(0xFF5856D6),
      ),
    ];

    final List<Product> prods = [
      Product(
        id: 'p1',
        name: 'Kopi Susu Gula Aren',
        sku: 'KOP-001',
        barcode: '8991001001',
        price: 22000,
        costPrice: 9500,
        stock: 64,
        unit: 'Cup',
        categoryId: 'cat_coffee',
        categoryName: 'Kopi & Espresso',
        minStockAlert: 10,
        variants: const [
          ProductVariant(id: 'v1_reg', name: 'Regular (Ice)'),
          ProductVariant(id: 'v1_lrg', name: 'Large (Ice)', additionalPrice: 5000),
          ProductVariant(id: 'v1_hot', name: 'Hot Cup'),
        ],
      ),
      Product(
        id: 'p2',
        name: 'Americano Double Shot',
        sku: 'KOP-002',
        barcode: '8991001002',
        price: 18000,
        costPrice: 6000,
        stock: 45,
        unit: 'Cup',
        categoryId: 'cat_coffee',
        categoryName: 'Kopi & Espresso',
        minStockAlert: 8,
        variants: const [
          ProductVariant(id: 'v2_hot', name: 'Hot'),
          ProductVariant(id: 'v2_ice', name: 'Iced', additionalPrice: 2000),
        ],
      ),
      Product(
        id: 'p3',
        name: 'Caramel Macchiato',
        sku: 'KOP-003',
        barcode: '8991001003',
        price: 28000,
        costPrice: 12000,
        stock: 30,
        unit: 'Cup',
        categoryId: 'cat_coffee',
        categoryName: 'Kopi & Espresso',
        minStockAlert: 5,
      ),
      Product(
        id: 'p4',
        name: 'Matcha Uji Latte',
        sku: 'TEA-001',
        barcode: '8992002001',
        price: 26000,
        costPrice: 11000,
        stock: 22,
        unit: 'Cup',
        categoryId: 'cat_tea',
        categoryName: 'Teh & Non-Kopi',
        minStockAlert: 5,
      ),
      Product(
        id: 'p5',
        name: 'Earl Grey Milk Tea',
        sku: 'TEA-002',
        barcode: '8992002002',
        price: 24000,
        costPrice: 9000,
        stock: 18,
        unit: 'Cup',
        categoryId: 'cat_tea',
        categoryName: 'Teh & Non-Kopi',
        minStockAlert: 5,
      ),
      Product(
        id: 'p6',
        name: 'Butter Croissant Premium',
        sku: 'BAK-001',
        barcode: '8993003001',
        price: 24000,
        costPrice: 10500,
        stock: 14,
        unit: 'Pcs',
        categoryId: 'cat_bakery',
        categoryName: 'Roti & Pastry',
        minStockAlert: 6,
      ),
      Product(
        id: 'p7',
        name: 'Pain Au Chocolat',
        sku: 'BAK-002',
        barcode: '8993003002',
        price: 27000,
        costPrice: 12500,
        stock: 8,
        unit: 'Pcs',
        categoryId: 'cat_bakery',
        categoryName: 'Roti & Pastry',
        minStockAlert: 5,
      ),
      Product(
        id: 'p8',
        name: 'Roti Toast Srikaya',
        sku: 'BAK-003',
        barcode: '8993003003',
        price: 19000,
        costPrice: 7500,
        stock: 3, // Low stock demo
        unit: 'Porsi',
        categoryId: 'cat_bakery',
        categoryName: 'Roti & Pastry',
        minStockAlert: 5,
      ),
      Product(
        id: 'p9',
        name: 'Nasi Goreng Kampung Spesial',
        sku: 'FOD-001',
        barcode: '8994004001',
        price: 35000,
        costPrice: 15000,
        stock: 40,
        unit: 'Porsi',
        categoryId: 'cat_food',
        categoryName: 'Makanan Berat',
        minStockAlert: 10,
      ),
      Product(
        id: 'p10',
        name: 'Mie Godog Jawa Telur Bebek',
        sku: 'FOD-002',
        barcode: '8994004002',
        price: 32000,
        costPrice: 14000,
        stock: 25,
        unit: 'Porsi',
        categoryId: 'cat_food',
        categoryName: 'Makanan Berat',
        minStockAlert: 5,
      ),
      Product(
        id: 'p11',
        name: 'French Fries Truffle Oil',
        sku: 'SNK-001',
        barcode: '8995005001',
        price: 25000,
        costPrice: 9000,
        stock: 35,
        unit: 'Porsi',
        categoryId: 'cat_snack',
        categoryName: 'Camilan & Dessert',
        minStockAlert: 8,
      ),
      Product(
        id: 'p12',
        name: 'Singkong Keju Goreng Renyah',
        sku: 'SNK-002',
        barcode: '8995005002',
        price: 18000,
        costPrice: 6500,
        stock: 20,
        unit: 'Porsi',
        categoryId: 'cat_snack',
        categoryName: 'Camilan & Dessert',
        minStockAlert: 5,
      ),
    ];

    final List<UserAccount> userAccounts = [
      const UserAccount(
        id: 'u1',
        name: 'Budi Santoso',
        role: UserRole.owner,
        pin: '1234',
      ),
      const UserAccount(
        id: 'u2',
        name: 'Rian Pratama',
        role: UserRole.manager,
        pin: '2345',
      ),
      const UserAccount(
        id: 'u3',
        name: 'Siti Sarah',
        role: UserRole.cashier,
        pin: '0000',
      ),
    ];

    final Shift activeShift = Shift(
      id: 'sh_001',
      cashierName: 'Siti Sarah',
      startTime: DateTime.now().subtract(const Duration(hours: 4, minutes: 20)),
      startingCash: 200000,
      cashIn: 50000,
      cashOut: 25000,
      cashSales: 486000,
      nonCashSales: 638000,
    );

    final DateTime now = DateTime.now();

    final List<Transaction> initialTransactions = [
      Transaction(
        id: 'tx_001',
        invoiceNumber: 'INV/20260907/001',
        dateTime: now.subtract(const Duration(hours: 3, minutes: 45)),
        items: [
          CartItem(
            id: 'ci_1',
            product: prods[0],
            quantity: 2,
            unitPrice: 22000,
            selectedVariant: prods[0].variants.first,
          ),
          CartItem(
            id: 'ci_2',
            product: prods[5],
            quantity: 1,
            unitPrice: 24000,
          ),
        ],
        subtotal: 68000,
        discount: 0,
        tax: 0,
        serviceCharge: 0,
        total: 68000,
        paymentMethod: PaymentMethod.qris,
        status: TransactionStatus.completed,
        cashierName: 'Siti Sarah',
        customerName: 'Kak Dimas',
        tableNumber: 'Meja 02',
        referenceNumber: 'QRIS-88231940',
      ),
      Transaction(
        id: 'tx_002',
        invoiceNumber: 'INV/20260907/002',
        dateTime: now.subtract(const Duration(hours: 3, minutes: 10)),
        items: [
          CartItem(
            id: 'ci_3',
            product: prods[8],
            quantity: 2,
            unitPrice: 35000,
          ),
          CartItem(
            id: 'ci_4',
            product: prods[1],
            quantity: 2,
            unitPrice: 20000,
            selectedVariant: prods[1].variants.last,
          ),
        ],
        subtotal: 110000,
        discount: 10000,
        tax: 0,
        serviceCharge: 0,
        total: 100000,
        paymentMethod: PaymentMethod.cash,
        status: TransactionStatus.completed,
        cashierName: 'Siti Sarah',
        customerName: 'Pak Wahyu (Kantor BUMN)',
        tableNumber: 'Meja 05',
        cashReceived: 100000,
        cashChange: 0,
      ),
      Transaction(
        id: 'tx_003',
        invoiceNumber: 'INV/20260907/003',
        dateTime: now.subtract(const Duration(hours: 1, minutes: 30)),
        items: [
          CartItem(
            id: 'ci_5',
            product: prods[3],
            quantity: 2,
            unitPrice: 26000,
          ),
          CartItem(
            id: 'ci_6',
            product: prods[10],
            quantity: 1,
            unitPrice: 25000,
          ),
        ],
        subtotal: 77000,
        discount: 0,
        tax: 0,
        serviceCharge: 0,
        total: 77000,
        paymentMethod: PaymentMethod.transfer,
        status: TransactionStatus.completed,
        cashierName: 'Siti Sarah',
        customerName: 'Ibu Linda',
        tableNumber: 'Takeaway',
        referenceNumber: 'BCA-71829311',
      ),
      Transaction(
        id: 'tx_004',
        invoiceNumber: 'HOLD/20260907/001',
        dateTime: now.subtract(const Duration(minutes: 40)),
        items: [
          CartItem(
            id: 'ci_7',
            product: prods[6],
            quantity: 2,
            unitPrice: 27000,
          ),
          CartItem(
            id: 'ci_8',
            product: prods[2],
            quantity: 2,
            unitPrice: 28000,
          ),
        ],
        subtotal: 110000,
        discount: 0,
        tax: 0,
        serviceCharge: 0,
        total: 110000,
        paymentMethod: PaymentMethod.cash,
        status: TransactionStatus.hold,
        cashierName: 'Siti Sarah',
        customerName: 'Pak Gunawan (Rombongan)',
        tableNumber: 'Meja 08',
        notes: 'Tunggu rekan datang sebelum pesan makanan berat',
      ),
      Transaction(
        id: 'tx_005',
        invoiceNumber: 'DEBT/20260907/001',
        dateTime: now.subtract(const Duration(hours: 2)),
        items: [
          CartItem(
            id: 'ci_9',
            product: prods[9],
            quantity: 3,
            unitPrice: 32000,
          ),
        ],
        subtotal: 96000,
        discount: 0,
        tax: 0,
        serviceCharge: 0,
        total: 96000,
        paymentMethod: PaymentMethod.debt,
        status: TransactionStatus.debt,
        cashierName: 'Siti Sarah',
        customerName: 'Mas Hendra (Tetangga Ruko)',
        tableNumber: 'Takeaway',
        notes: 'Jatuh tempo tgl 10 Sep 2026 (DP Rp 0)',
      ),
    ];

    final List<StockMutation> initialMutations = [
      StockMutation(
        id: 'sm_1',
        productId: 'p1',
        productName: 'Kopi Susu Gula Aren',
        type: StockMutationType.inbound,
        qty: 50,
        previousStock: 16,
        currentStock: 66,
        note: 'Restock bahan baku biji kopi & susu fresh',
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        cashierName: 'Budi Santoso',
      ),
      StockMutation(
        id: 'sm_2',
        productId: 'p8',
        productName: 'Roti Toast Srikaya',
        type: StockMutationType.outbound,
        qty: 2,
        previousStock: 5,
        currentStock: 3,
        note: 'Bahan srikaya tumpah/rusak (Waste)',
        timestamp: now.subtract(const Duration(hours: 5)),
        cashierName: 'Rian Pratama',
      ),
      StockMutation(
        id: 'sm_3',
        productId: 'p6',
        productName: 'Butter Croissant Premium',
        type: StockMutationType.adjustment,
        qty: -1,
        previousStock: 15,
        currentStock: 14,
        note: 'Penyesuaian stok opname harian',
        timestamp: now.subtract(const Duration(hours: 6)),
        cashierName: 'Rian Pratama',
      ),
    ];

    return PosState(
      storeProfile: profile,
      users: userAccounts,
      currentUser: userAccounts[2],
      categories: cats,
      products: prods,
      cart: [],
      transactions: initialTransactions,
      stockMutations: initialMutations,
      currentShift: activeShift,
      pastShifts: [],
    );
  }

  // --- Cart Getters & Operations ---
  int get cartTotalQuantity => cart.fold(0, (sum, item) => sum + item.quantity);

  double get cartSubtotal => cart.fold(0.0, (sum, item) => sum + item.subtotal);

  double get cartCalculatedDiscount {
    if (orderDiscountPercent > 0) {
      return (cartSubtotal * orderDiscountPercent) / 100.0;
    }
    return orderDiscountNominal;
  }

  double get cartTax {
    if (!storeProfile.isTaxEnabled) return 0.0;
    final taxable = (cartSubtotal - cartCalculatedDiscount).clamp(0.0, double.infinity);
    return (taxable * storeProfile.taxPercentage) / 100.0;
  }

  double get cartServiceCharge {
    if (!storeProfile.isServiceEnabled) return 0.0;
    final chargeable = (cartSubtotal - cartCalculatedDiscount).clamp(0.0, double.infinity);
    return (chargeable * storeProfile.servicePercentage) / 100.0;
  }

  double get cartTotal {
    final double base = cartSubtotal - cartCalculatedDiscount + cartTax + cartServiceCharge;
    return base < 0 ? 0.0 : base;
  }

  void selectCategory(String categoryId) {
    selectedCategoryId = categoryId;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  List<Product> get filteredProducts {
    return products.where((p) {
      final matchesCategory =
          selectedCategoryId == 'all' || p.categoryId == selectedCategoryId;
      final matchesSearch = searchQuery.isEmpty ||
          p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          p.sku.toLowerCase().contains(searchQuery.toLowerCase()) ||
          p.barcode.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  /// Finds a product by an exact barcode (or SKU for keyboard scanners).
  /// Blank scans and unknown codes never fall back to the first product.
  Product? findProductByBarcode(String code) {
    final normalized = code.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    for (final product in products) {
      if (product.barcode.trim().toLowerCase() == normalized ||
          product.sku.trim().toLowerCase() == normalized) {
        return product;
      }
    }
    return null;
  }

  /// Handles a scanner result and reports whether an item was added.
  bool addScannedBarcode(String code) {
    final product = findProductByBarcode(code);
    return product != null && addToCart(product);
  }

  bool canAddQuantity(Product product, {ProductVariant? variant, String note = '', int requestedQuantity = 1}) {
    final int onHand = products
        .firstWhere((p) => p.id == product.id, orElse: () => product)
        .stock;
    final int reserved = cart
        .where(
          (item) =>
              item.product.id == product.id &&
              item.selectedVariant?.id == variant?.id &&
              item.note == note,
        )
        .fold(0, (sum, item) => sum + item.quantity);
    return onHand >= reserved + requestedQuantity;
  }

  bool addToCart(Product product, {ProductVariant? variant, String note = ''}) {
    if (!canAddQuantity(product, variant: variant, note: note)) {
      return false;
    }

    final double price = product.price + (variant?.additionalPrice ?? 0.0);
    final int existingIndex = cart.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.selectedVariant?.id == variant?.id &&
          item.note == note,
    );

    if (existingIndex >= 0) {
      cart[existingIndex].quantity += 1;
    } else {
      cart.add(
        CartItem(
          id: 'cart_${DateTime.now().millisecondsSinceEpoch}_${cart.length}',
          product: product,
          quantity: 1,
          unitPrice: price,
          selectedVariant: variant,
          note: note,
        ),
      );
    }
    notifyListeners();
    return true;
  }

  bool updateCartItemQuantity(int index, int newQty) {
    if (index >= 0 && index < cart.length) {
      if (newQty <= 0) {
        cart.removeAt(index);
        notifyListeners();
        return true;
      }

      final CartItem item = cart[index];
      final int siblingReserved = cart
          .asMap()
          .entries
          .where(
            (entry) =>
                entry.key != index &&
                entry.value.product.id == item.product.id &&
                entry.value.selectedVariant?.id == item.selectedVariant?.id &&
                entry.value.note == item.note,
          )
          .fold(0, (sum, entry) => sum + entry.value.quantity);
      final int onHand = products
          .firstWhere((p) => p.id == item.product.id, orElse: () => item.product)
          .stock;
      if (newQty + siblingReserved > onHand) {
        return false;
      }

      cart[index].quantity = newQty;
      notifyListeners();
      return true;
    }
    return false;
  }

  void removeCartItem(int index) {
    if (index >= 0 && index < cart.length) {
      cart.removeAt(index);
      notifyListeners();
    }
  }

  void updateCartItemNote(int index, String note) {
    if (index >= 0 && index < cart.length) {
      cart[index].note = note;
      notifyListeners();
    }
  }

  void setItemDiscount(int index, double discountNominal) {
    if (index >= 0 && index < cart.length) {
      final item = cart[index];
      item.discountNominal = discountNominal.clamp(0.0, item.unitPrice * item.quantity);
      notifyListeners();
    }
  }

  void setOrderDiscount({double? percent, double? nominal}) {
    if (percent != null) {
      orderDiscountPercent = percent.clamp(0.0, 100.0);
      orderDiscountNominal = 0.0;
    } else if (nominal != null) {
      orderDiscountNominal = nominal.clamp(0.0, cartSubtotal);
      orderDiscountPercent = 0.0;
    }
    notifyListeners();
  }

  void setCustomerInfo({String? name, String? table, String? note}) {
    if (name != null) activeCustomerName = name;
    if (table != null) activeTableNumber = table;
    if (note != null) activeOrderNote = note;
    notifyListeners();
  }

  void clearCart() {
    cart.clear();
    orderDiscountPercent = 0.0;
    orderDiscountNominal = 0.0;
    activeCustomerName = '';
    activeTableNumber = '';
    activeOrderNote = '';
    notifyListeners();
  }

  // --- Hold & Recall Orders ---
  bool holdCurrentOrder({String? customerName, String? tableNumber, String? note}) {
    if (cart.isEmpty) return false;

    final String inv = 'HOLD/${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}/${(transactions.where((t) => t.status == TransactionStatus.hold).length + 1).toString().padLeft(3, '0')}';

    final tx = Transaction(
      id: 'tx_hold_${DateTime.now().millisecondsSinceEpoch}',
      invoiceNumber: inv,
      dateTime: DateTime.now(),
      items: List.from(cart.map((i) => i.copyWith())),
      subtotal: cartSubtotal,
      discount: cartCalculatedDiscount,
      tax: cartTax,
      serviceCharge: cartServiceCharge,
      total: cartTotal,
      paymentMethod: PaymentMethod.cash,
      status: TransactionStatus.hold,
      cashierName: currentUser.name,
      customerName: customerName ?? (activeCustomerName.isNotEmpty ? activeCustomerName : 'Pesanan Hold'),
      tableNumber: tableNumber ?? activeTableNumber,
      notes: note ?? activeOrderNote,
    );

    transactions.insert(0, tx);
    clearCart();
    return true;
  }

  bool recallHoldOrder(Transaction tx) {
    if (tx.status != TransactionStatus.hold) return false;
    cart = List.from(tx.items.map((i) => i.copyWith()));
    activeCustomerName = tx.customerName;
    activeTableNumber = tx.tableNumber;
    activeOrderNote = tx.notes;
    orderDiscountPercent = 0.0;
    orderDiscountNominal = tx.discount;

    // Remove from hold list
    transactions.removeWhere((t) => t.id == tx.id);
    notifyListeners();
    return true;
  }

  // --- Checkout Transaction ---
  Transaction checkout({
    required PaymentMethod paymentMethod,
    double cashReceived = 0.0,
    double cashChange = 0.0,
    String referenceNumber = '',
    String? customerName,
    String? tableNumber,
    String? note,
  }) {
    if (currentShift == null) {
      throw StateError('Buka shift kasir sebelum checkout');
    }
    if (cart.isEmpty) {
      throw StateError('Keranjang transaksi kosong');
    }
    final Map<String, int> requestedByProduct = <String, int>{};
    for (final item in cart) {
      requestedByProduct.update(
        item.product.id,
        (quantity) => quantity + item.quantity,
        ifAbsent: () => item.quantity,
      );
    }
    for (final entry in requestedByProduct.entries) {
      final product = products.firstWhere((p) => p.id == entry.key);
      if (entry.value > product.stock) {
        throw StateError('Stok ${product.name} tidak mencukupi');
      }
    }
    final String dateKey = '${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}';
    final int nextNumber = transactions
            .map((t) => RegExp(r'^INV/\d{8}/(\d+)$').firstMatch(t.invoiceNumber))
            .whereType<RegExpMatch>()
            .map((m) => int.tryParse(m.group(1)!) ?? 0)
            .fold(0, (max, value) => value > max ? value : max) +
        1;
    final String inv = 'INV/$dateKey/${nextNumber.toString().padLeft(3, '0')}';


    final tx = Transaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      invoiceNumber: inv,
      dateTime: DateTime.now(),
      items: List.from(cart.map((i) => i.copyWith())),
      subtotal: cartSubtotal,
      discount: cartCalculatedDiscount,
      tax: cartTax,
      serviceCharge: cartServiceCharge,
      total: cartTotal,
      paymentMethod: paymentMethod,
      status: paymentMethod == PaymentMethod.debt
          ? TransactionStatus.debt
          : TransactionStatus.completed,
      cashierName: currentUser.name,
      customerName: (customerName != null && customerName.isNotEmpty)
          ? customerName
          : (activeCustomerName.isNotEmpty ? activeCustomerName : 'Pelanggan Umum'),
      tableNumber: tableNumber ?? activeTableNumber,
      cashReceived: cashReceived,
      cashChange: cashChange,
      referenceNumber: referenceNumber,
      notes: note ?? activeOrderNote,
    );

    // Reduce stock and record mutation
    for (final item in cart) {
      final int prodIndex = products.indexWhere((p) => p.id == item.product.id);
      if (prodIndex >= 0) {
        final Product prod = products[prodIndex];
        final int oldStock = prod.stock;
        final int newStock = (oldStock - item.quantity).clamp(0, 999999);
        products[prodIndex] = prod.copyWith(stock: newStock);

        stockMutations.insert(
          0,
          StockMutation(
            id: 'sm_sale_${DateTime.now().millisecondsSinceEpoch}_${item.id}',
            productId: prod.id,
            productName: prod.name,
            type: StockMutationType.sale,
            qty: -item.quantity,
            previousStock: oldStock,
            currentStock: newStock,
            note: 'Penjualan Nota $inv',
            timestamp: DateTime.now(),
            cashierName: currentUser.name,
          ),
        );
      }
    }

    // Update active shift if any
    if (currentShift != null) {
      if (paymentMethod == PaymentMethod.cash) {
        currentShift!.cashSales += tx.total;
      } else if (paymentMethod != PaymentMethod.debt) {
        currentShift!.nonCashSales += tx.total;
      }
    }

    transactions.insert(0, tx);
    clearCart();
    notifyListeners();
    return tx;
  }

  // --- Transaction Actions: Void & Refund ---
  bool voidTransaction(String transactionId, {required String adminPin, required String reason}) {
    // Verify admin PIN on active owner/manager account
    UserAccount? authorizedAdmin;
    for (final u in users) {
      if (u.isActive &&
          (u.role == UserRole.owner || u.role == UserRole.manager) &&
          u.pin == adminPin) {
        authorizedAdmin = u;
        break;
      }
    }

    if (authorizedAdmin == null) return false;

    final int index = transactions.indexWhere((t) => t.id == transactionId);
    if (index >= 0) {
      final oldTx = transactions[index];
      if (oldTx.status == TransactionStatus.voided) {
        return false;
      }
      transactions[index] = oldTx.copyWith(
        status: TransactionStatus.voided,
        notes: '${oldTx.notes} [VOID: $reason by Admin ${authorizedAdmin.name} (${authorizedAdmin.roleTitle})]',
      );

      // Restore stock
      for (final item in oldTx.items) {
        final int prodIndex = products.indexWhere((p) => p.id == item.product.id);
        if (prodIndex >= 0) {
          final Product prod = products[prodIndex];
          final int oldStock = prod.stock;
          final int newStock = oldStock + item.quantity;
          products[prodIndex] = prod.copyWith(stock: newStock);

          stockMutations.insert(
            0,
            StockMutation(
              id: 'sm_void_${DateTime.now().millisecondsSinceEpoch}_${item.id}',
              productId: prod.id,
              productName: prod.name,
              type: StockMutationType.adjustment,
              qty: item.quantity,
              previousStock: oldStock,
              currentStock: newStock,
              note: 'Pembatalan (Void) Nota ${oldTx.invoiceNumber}',
              timestamp: DateTime.now(),
              cashierName: currentUser.name,
            ),
          );
        }
      }

      // Reconcile shift totals
      if (currentShift != null) {
        if (oldTx.paymentMethod == PaymentMethod.cash) {
          currentShift!.cashSales = (currentShift!.cashSales - oldTx.total).clamp(0.0, double.infinity);
        } else if (oldTx.paymentMethod != PaymentMethod.debt) {
          currentShift!.nonCashSales = (currentShift!.nonCashSales - oldTx.total).clamp(0.0, double.infinity);
        }
      }

      notifyListeners();
      return true;
    }
    return false;
  }

  void settleDebt(String transactionId, {PaymentMethod method = PaymentMethod.cash}) {
    final int index = transactions.indexWhere((t) => t.id == transactionId);
    if (index >= 0) {
      final oldTx = transactions[index];
      if (oldTx.status != TransactionStatus.debt) return;
      transactions[index] = oldTx.copyWith(
        status: TransactionStatus.completed,
        paymentMethod: method,
        notes: '${oldTx.notes} (Lunas via ${method.name.toUpperCase()}: ${DateTime.now()})',
      );
      if (currentShift != null) {
        if (method == PaymentMethod.cash) {
          currentShift!.cashSales += oldTx.total;
        } else {
          currentShift!.nonCashSales += oldTx.total;
        }
      }
      notifyListeners();
    }
  }

  // --- Product & Stock Management ---
  void addProduct(Product product) {
    products.add(product);
    stockMutations.insert(
      0,
      StockMutation(
        id: 'sm_add_${DateTime.now().millisecondsSinceEpoch}',
        productId: product.id,
        productName: product.name,
        type: StockMutationType.inbound,
        qty: product.stock,
        previousStock: 0,
        currentStock: product.stock,
        note: 'Produk Baru Terdaftar',
        timestamp: DateTime.now(),
        cashierName: currentUser.name,
      ),
    );
    notifyListeners();
  }

  void updateProduct(Product product) {
    final int index = products.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      products[index] = product;
      notifyListeners();
    }
  }

  void deleteProduct(String productId) {
    products.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  void recordStockAdjustment({
    required String productId,
    required StockMutationType type,
    required int quantityDelta,
    required String note,
  }) {
    final int index = products.indexWhere((p) => p.id == productId);
    if (index >= 0) {
      final Product prod = products[index];
      final int prevStock = prod.stock;
      final int newStock = (prevStock + quantityDelta).clamp(0, 999999);
      products[index] = prod.copyWith(stock: newStock);

      stockMutations.insert(
        0,
        StockMutation(
          id: 'sm_adj_${DateTime.now().millisecondsSinceEpoch}',
          productId: prod.id,
          productName: prod.name,
          type: type,
          qty: quantityDelta,
          previousStock: prevStock,
          currentStock: newStock,
          note: note,
          timestamp: DateTime.now(),
          cashierName: currentUser.name,
        ),
      );
      notifyListeners();
    }
  }

  // --- Shift Management ---
  void startNewShift(double startingCash) {
    if (currentShift != null || startingCash < 0) return;
    currentShift = Shift(
      id: 'sh_${DateTime.now().millisecondsSinceEpoch}',
      cashierName: currentUser.name,
      startTime: DateTime.now(),
      startingCash: startingCash,
    );
    notifyListeners();
  }

  void addShiftCashMovement({required double amount, required bool isCashIn, required String note}) {
    if (currentShift != null && amount > 0) {
      if (isCashIn) {
        currentShift!.cashIn += amount;
      } else {
        currentShift!.cashOut += amount;
      }
      currentShift!.notes += ' [${isCashIn ? "Kas Masuk" : "Kas Keluar"} ${FormatUtils.formatRupiah(amount)}: $note]';
      notifyListeners();
    }
  }

  void closeCurrentShift(double actualCash, String closingNotes) {
    if (currentShift != null) {
      currentShift!.endTime = DateTime.now();
      currentShift!.actualCash = actualCash;
      currentShift!.notes += ' [Tutup: $closingNotes]';
      currentShift!.isClosed = true;

      pastShifts.insert(0, currentShift!);
      currentShift = null;
      notifyListeners();
    }
  }

  // --- User Account Management ---
  bool _isValidUserPin(String pin) => RegExp(r'^\d{4,6}$').hasMatch(pin);

  /// Adds a user account after validating name, role, and 4-6 digit numeric PIN.
  bool addUserAccount({
    required String name,
    required UserRole role,
    required String pin,
    bool isActive = true,
  }) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return false;
    if (!_isValidUserPin(pin)) return false;
    users.add(
      UserAccount(
        id: 'u_${DateTime.now().millisecondsSinceEpoch}_${users.length}',
        name: trimmedName,
        role: role,
        pin: pin,
        isActive: isActive,
      ),
    );
    notifyListeners();
    return true;
  }

  /// Edits an existing user account. Empty names and invalid PINs are rejected.
  bool updateUserAccount(
    String userId, {
    String? name,
    UserRole? role,
    String? pin,
    bool? isActive,
  }) {
    final index = users.indexWhere((u) => u.id == userId);
    if (index < 0) return false;
    final current = users[index];
    final nextName = name == null ? current.name : name.trim();
    if (nextName.isEmpty) return false;
    if (pin != null && !_isValidUserPin(pin)) return false;
    final updated = current.copyWith(
      name: nextName,
      role: role,
      pin: pin,
      isActive: isActive,
    );
    users[index] = updated;
    if (currentUser.id == userId) {
      if (updated.isActive) {
        currentUser = updated;
      } else {
        final fallback = users.firstWhere(
          (u) => u.isActive && u.id != userId,
          orElse: () => updated.copyWith(isActive: true),
        );
        currentUser = fallback;
        if (fallback.id == userId) users[index] = fallback;
      }
    }
    notifyListeners();
    return true;
  }

  /// Toggles the active status of a user account.
  bool toggleUserStatus(String userId) {
    final index = users.indexWhere((u) => u.id == userId);
    if (index < 0) return false;
    final toggled = users[index].copyWith(isActive: !users[index].isActive);
    return updateUserAccount(userId, isActive: toggled.isActive);
  }

  /// Resets all transactional data after verifying an active owner PIN.
  ///
  /// Clears transactions and cart, drops stock mutations, discards active and
  /// past shifts, restores a clean sample catalog, clears persisted settings
  /// to defaults, and notifies listeners.
  bool resetTotalData({required String ownerPin}) {
    final owns = users.any(
      (u) => u.isActive && u.role == UserRole.owner && u.pin == ownerPin,
    );
    if (!owns) return false;

    final fresh = PosState.sample();
    transactions = fresh.transactions.where((t) => false).toList();
    cart = <CartItem>[];
    orderDiscountPercent = 0.0;
    orderDiscountNominal = 0.0;
    activeCustomerName = '';
    activeTableNumber = '';
    activeOrderNote = '';
    stockMutations = <StockMutation>[];
    currentShift = null;
    pastShifts = <Shift>[];
    categories = fresh.categories;
    products = fresh.products;
    selectedCategoryId = 'all';
    searchQuery = '';
    storeProfile = const StoreProfile();
    selectedPrinterName = const PrinterSettings().name;
    selectedPaperSize = const PrinterSettings().paperSize;
    isPrinterConnected = const PrinterSettings().isConnected;

    final repository = settingsRepository;
    if (repository != null) {
      _ignorePersistenceError(repository.clear());
    }
    notifyListeners();
    return true;
  }

  // --- Authentication / User Switching ---
  bool switchUser(String userId, String pin) {
    final matches = users.where((u) => u.id == userId && u.isActive);
    if (matches.isEmpty) return false;
    final user = matches.first;
    if (pin.length < 4 || pin.length > 6 || !RegExp(r'^\d{4,6}$').hasMatch(pin) || user.pin != pin) {
      return false;
    }
    if (user.id == currentUser.id) return true;
    // Do not silently hand an open shift to another cashier.
    if (currentShift != null && currentShift!.cashierName != user.name) return false;
    currentUser = user;
    notifyListeners();
    return true;
  }

  // --- Settings & Profile ---
  void emitStateChanged() => notifyListeners();

  void updateStoreProfile(StoreProfile newProfile) {
    storeProfile = newProfile;
    final repo = settingsRepository;
    if (repo != null) {
      _ignorePersistenceError(repo.saveStoreProfile(newProfile));
    }
    notifyListeners();
  }

  void updatePrinterSettings({String? name, String? paperSize, bool? isConnected}) {
    if (name != null) selectedPrinterName = name;
    if (paperSize != null) selectedPaperSize = paperSize;
    if (isConnected != null) isPrinterConnected = isConnected;
    final repo = settingsRepository;
    if (repo != null) {
      _ignorePersistenceError(repo.savePrinterSettings(_printerSettingsFromState(this)));
    }
    notifyListeners();
  }

  // --- Analytics & Reports Helpers ---
  bool _isSameCalendarDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Aggregates completed transaction revenue into stable buckets for the dashboard chart.
  /// The optional reference time keeps this logic deterministic for reports and tests.
  SalesChartData salesChartData(SalesPeriod period, {DateTime? reference}) {
    final now = reference ?? DateTime.now();
    late final List<String> labels;
    late final List<DateTime> starts;
    late final Duration bucketSize;

    switch (period) {
      case SalesPeriod.today:
        final first = DateTime(now.year, now.month, now.day, now.hour).subtract(const Duration(hours: 11));
        bucketSize = const Duration(hours: 1);
        starts = List<DateTime>.generate(12, (index) => first.add(Duration(hours: index)));
        labels = starts.map((date) => '${date.hour.toString().padLeft(2, '0')}.00').toList();
      case SalesPeriod.sevenDays:
        final first = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
        bucketSize = const Duration(days: 1);
        starts = List<DateTime>.generate(7, (index) => first.add(Duration(days: index)));
        labels = starts.map((date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}').toList();
      case SalesPeriod.thirtyDays:
        final first = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 29));
        bucketSize = const Duration(days: 5);
        starts = List<DateTime>.generate(6, (index) => first.add(Duration(days: index * 5)));
        labels = starts.map((date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}').toList();
    }

    final values = List<double>.filled(starts.length, 0.0);
    for (final transaction in transactions) {
      if (transaction.status != TransactionStatus.completed) continue;
      final difference = transaction.dateTime.difference(starts.first);
      final index = difference.inMilliseconds ~/ bucketSize.inMilliseconds;
      if (index >= 0 && index < values.length) values[index] += transaction.total;
    }
    return SalesChartData(period: period, labels: labels, values: values);
  }

  List<OperationalAlert> get operationalAlerts {
    final alerts = <OperationalAlert>[];
    final lowStockCount = products.where((product) => product.isLowStock).length;
    if (lowStockCount > 0) {
      alerts.add(OperationalAlert(
        id: 'low-stock',
        title: '$lowStockCount produk stok menipis',
        subtitle: 'Segera restock produk di bawah minimum alert.',
        icon: Icons.inventory_rounded,
        color: AppColors.warning,
        navigationTab: 2,
      ));
    }
    final holdCount = transactions.where((transaction) => transaction.status == TransactionStatus.hold).length;
    if (holdCount > 0) {
      alerts.add(OperationalAlert(
        id: 'held-orders',
        title: '$holdCount pesanan tertunda',
        subtitle: 'Recall pesanan hold agar tidak terlupakan.',
        icon: Icons.pause_circle_outline_rounded,
        color: AppColors.warning,
        navigationTab: 1,
      ));
    }
    final debtCount = transactions.where((transaction) => transaction.status == TransactionStatus.debt).length;
    if (debtCount > 0) {
      alerts.add(OperationalAlert(
        id: 'debts',
        title: '$debtCount kasbon belum lunas',
        subtitle: 'Tinjau buku kasbon dan catat pelunasan.',
        icon: Icons.receipt_long_rounded,
        color: AppColors.danger,
        navigationTab: 3,
      ));
    }
    if (currentShift == null) {
      alerts.add(const OperationalAlert(
        id: 'shift-closed',
        title: 'Shift kasir belum dibuka',
        subtitle: 'Buka shift sebelum menerima transaksi baru.',
        icon: Icons.schedule_rounded,
        color: AppColors.info,
        navigationTab: 1,
      ));
    }
    if (!isPrinterConnected) {
      alerts.add(OperationalAlert(
        id: 'printer-disconnected',
        title: 'Printer belum terhubung',
        subtitle: 'Hubungkan printer agar struk dapat dicetak.',
        icon: Icons.print_disabled_rounded,
        color: AppColors.danger,
        navigationTab: 4,
      ));
    }
    return alerts;
  }

  int get actionableAlertCount => operationalAlerts.where((alert) => alert.requiresAction).length;

  bool get hasNotifications => operationalAlerts.isNotEmpty;

  String get notificationSummary => hasNotifications
      ? '$actionableAlertCount perlu tindakan'
      : 'Semua operasional aman';



  double get totalRevenueToday {
    final now = DateTime.now();
    return transactions
        .where(
          (t) =>
              t.status == TransactionStatus.completed &&
              _isSameCalendarDay(t.dateTime, now),
        )
        .fold(0.0, (sum, t) => sum + t.total);
  }

  double get totalGrossProfitToday {
    final now = DateTime.now();
    return transactions
        .where(
          (t) =>
              t.status == TransactionStatus.completed &&
              _isSameCalendarDay(t.dateTime, now),
        )
        .fold(0.0, (sum, t) => sum + (t.total - t.tax - t.serviceCharge - t.items.fold(0.0, (cost, item) => cost + item.totalCost)));
  }

  int get completedTransactionsCount {
    final now = DateTime.now();
    return transactions
        .where(
          (t) =>
              t.status == TransactionStatus.completed &&
              _isSameCalendarDay(t.dateTime, now),
        )
        .length;
  }

  double get averageBasketSize {
    final count = completedTransactionsCount;
    return count > 0 ? totalRevenueToday / count : 0.0;
  }

  Map<PaymentMethod, double> get paymentMethodBreakdown {
    final Map<PaymentMethod, double> breakdown = {
      PaymentMethod.cash: 0.0,
      PaymentMethod.qris: 0.0,
      PaymentMethod.transfer: 0.0,
      PaymentMethod.debit: 0.0,
      PaymentMethod.debt: 0.0,
    };
    for (final t in transactions.where((t) => t.status == TransactionStatus.completed)) {
      breakdown[t.paymentMethod] = (breakdown[t.paymentMethod] ?? 0.0) + t.total;
    }
    return breakdown;
  }
}
