import 'package:flutter/material.dart';

enum TransactionStatus {
  completed,
  hold,
  debt,
  voided,
}

enum PaymentMethod {
  cash,
  qris,
  transfer,
  debit,
  debt,
  split,
}

enum StockMutationType {
  inbound,
  outbound,
  adjustment,
  sale,
}

enum UserRole {
  owner,
  manager,
  cashier,
}

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  Category copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon_code': icon.codePoint,
      'icon_font_family': icon.fontFamily,
      'icon_font_package': icon.fontPackage,
      'color': color.value,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    final iconCode = map['icon_code'] as int? ??
        (map['icon'] is int ? map['icon'] as int : Icons.category_rounded.codePoint);
    final fontFamily = map['icon_font_family'] as String? ?? (map['font_family'] as String?);
    final fontPackage = map['icon_font_package'] as String? ?? (map['font_package'] as String?);
    final colorValue = map['color'] is int
        ? map['color'] as int
        : map['color'] is String
            ? int.tryParse(map['color'] as String) ?? 0xFFFF6B00
            : 0xFFFF6B00;

    return Category(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      icon: IconData(iconCode, fontFamily: fontFamily, fontPackage: fontPackage),
      color: Color(colorValue),
    );
  }
}

class ProductVariant {
  final String id;
  final String name;
  final double additionalPrice;

  const ProductVariant({
    required this.id,
    required this.name,
    this.additionalPrice = 0.0,
  });

  ProductVariant copyWith({
    String? id,
    String? name,
    double? additionalPrice,
  }) {
    return ProductVariant(
      id: id ?? this.id,
      name: name ?? this.name,
      additionalPrice: additionalPrice ?? this.additionalPrice,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'additional_price': additionalPrice,
    };
  }

  factory ProductVariant.fromMap(Map<String, dynamic> map) {
    return ProductVariant(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      additionalPrice: (map['additional_price'] as num?)?.toDouble() ??
          (map['additionalPrice'] as num?)?.toDouble() ??
          0.0,
    );
  }
}

class Product {
  final String id;
  final String name;
  final String sku;
  final String barcode;
  final double price;
  final double costPrice;
  final int stock;
  final String unit;
  final String categoryId;
  final String categoryName;
  final String? imageUrl;
  final List<ProductVariant> variants;
  final int minStockAlert;

  const Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.barcode,
    required this.price,
    required this.costPrice,
    required this.stock,
    required this.unit,
    required this.categoryId,
    required this.categoryName,
    this.imageUrl,
    this.variants = const [],
    this.minStockAlert = 5,
  });

  bool get isLowStock => stock <= minStockAlert;

  Product copyWith({
    String? id,
    String? name,
    String? sku,
    String? barcode,
    double? price,
    double? costPrice,
    int? stock,
    String? unit,
    String? categoryId,
    String? categoryName,
    String? imageUrl,
    List<ProductVariant>? variants,
    int? minStockAlert,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      stock: stock ?? this.stock,
      unit: unit ?? this.unit,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      imageUrl: imageUrl ?? this.imageUrl,
      variants: variants ?? this.variants,
      minStockAlert: minStockAlert ?? this.minStockAlert,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'barcode': barcode,
      'price': price,
      'cost_price': costPrice,
      'stock': stock,
      'unit': unit,
      'category_id': categoryId,
      'category_name': categoryName,
      'image_url': imageUrl,
      'variants': variants.map((v) => v.toMap()).toList(),
      'min_stock_alert': minStockAlert,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    final rawVariants = map['variants'];
    List<ProductVariant> variantsList = const [];
    if (rawVariants is List) {
      variantsList = rawVariants
          .whereType<Map>()
          .map((v) => ProductVariant.fromMap(Map<String, dynamic>.from(v)))
          .toList();
    }
    return Product(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      sku: map['sku'] as String? ?? '',
      barcode: map['barcode'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      costPrice: (map['cost_price'] as num?)?.toDouble() ??
          (map['costPrice'] as num?)?.toDouble() ??
          0.0,
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      unit: map['unit'] as String? ?? 'Pcs',
      categoryId: map['category_id'] as String? ?? map['categoryId'] as String? ?? '',
      categoryName: map['category_name'] as String? ?? map['categoryName'] as String? ?? '',
      imageUrl: map['image_url'] as String? ?? map['imageUrl'] as String?,
      variants: variantsList,
      minStockAlert: (map['min_stock_alert'] as num?)?.toInt() ??
          (map['minStockAlert'] as num?)?.toInt() ??
          5,
    );
  }
}

class CartItem {
  final String id;
  final Product product;
  int quantity;
  double unitPrice;
  String note;
  double discountNominal;
  ProductVariant? selectedVariant;

  CartItem({
    required this.id,
    required this.product,
    this.quantity = 1,
    required this.unitPrice,
    this.note = '',
    this.discountNominal = 0.0,
    this.selectedVariant,
  });

  double get subtotal => ((unitPrice * quantity) - discountNominal).clamp(0.0, double.infinity);
  double get totalCost => product.costPrice * quantity;

  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    double? unitPrice,
    String? note,
    double? discountNominal,
    ProductVariant? selectedVariant,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      note: note ?? this.note,
      discountNominal: discountNominal ?? this.discountNominal,
      selectedVariant: selectedVariant ?? this.selectedVariant,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product': product.toMap(),
      'quantity': quantity,
      'unit_price': unitPrice,
      'note': note,
      'discount_nominal': discountNominal,
      'selected_variant': selectedVariant?.toMap(),
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] as String? ?? '',
      product: Product.fromMap(Map<String, dynamic>.from(map['product'] as Map? ?? {})),
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (map['unit_price'] as num?)?.toDouble() ??
          (map['unitPrice'] as num?)?.toDouble() ??
          0.0,
      note: map['note'] as String? ?? '',
      discountNominal: (map['discount_nominal'] as num?)?.toDouble() ??
          (map['discountNominal'] as num?)?.toDouble() ??
          0.0,
      selectedVariant: map['selected_variant'] != null
          ? ProductVariant.fromMap(Map<String, dynamic>.from(map['selected_variant'] as Map))
          : map['selectedVariant'] != null
              ? ProductVariant.fromMap(Map<String, dynamic>.from(map['selectedVariant'] as Map))
              : null,
    );
  }
}

class Transaction {
  final String id;
  final String invoiceNumber;
  final DateTime dateTime;
  final List<CartItem> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double serviceCharge;
  final double total;
  final PaymentMethod paymentMethod;
  final TransactionStatus status;
  final String cashierName;
  final String customerName;
  final String tableNumber;
  final double cashReceived;
  final double cashChange;
  final String referenceNumber;
  final String notes;

  const Transaction({
    required this.id,
    required this.invoiceNumber,
    required this.dateTime,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.serviceCharge,
    required this.total,
    required this.paymentMethod,
    required this.status,
    required this.cashierName,
    this.customerName = 'Pelanggan Umum',
    this.tableNumber = '',
    this.cashReceived = 0.0,
    this.cashChange = 0.0,
    this.referenceNumber = '',
    this.notes = '',
  });

  double get totalProfit {
    final double totalCost = items.fold(0.0, (sum, item) => sum + item.totalCost);
    return total - totalCost;
  }

  Transaction copyWith({
    String? id,
    String? invoiceNumber,
    DateTime? dateTime,
    List<CartItem>? items,
    double? subtotal,
    double? discount,
    double? tax,
    double? serviceCharge,
    double? total,
    PaymentMethod? paymentMethod,
    TransactionStatus? status,
    String? cashierName,
    String? customerName,
    String? tableNumber,
    double? cashReceived,
    double? cashChange,
    String? referenceNumber,
    String? notes,
  }) {
    return Transaction(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      dateTime: dateTime ?? this.dateTime,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      serviceCharge: serviceCharge ?? this.serviceCharge,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      cashierName: cashierName ?? this.cashierName,
      customerName: customerName ?? this.customerName,
      tableNumber: tableNumber ?? this.tableNumber,
      cashReceived: cashReceived ?? this.cashReceived,
      cashChange: cashChange ?? this.cashChange,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'date_time': dateTime.toIso8601String(),
      'items': items.map((i) => i.toMap()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'tax': tax,
      'service_charge': serviceCharge,
      'total': total,
      'payment_method': paymentMethod.name,
      'status': status.name,
      'cashier_name': cashierName,
      'customer_name': customerName,
      'table_number': tableNumber,
      'cash_received': cashReceived,
      'cash_change': cashChange,
      'reference_number': referenceNumber,
      'notes': notes,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    final rawItems = map['items'];
    List<CartItem> parsedItems = [];
    if (rawItems is List) {
      parsedItems = rawItems
          .whereType<Map>()
          .map((i) => CartItem.fromMap(Map<String, dynamic>.from(i)))
          .toList();
    }

    final pmName =
        map['payment_method'] as String? ?? map['paymentMethod'] as String? ?? PaymentMethod.cash.name;
    final statusName = map['status'] as String? ?? TransactionStatus.completed.name;

    return Transaction(
      id: map['id'] as String? ?? '',
      invoiceNumber:
          map['invoice_number'] as String? ?? map['invoiceNumber'] as String? ?? '',
      dateTime: map['date_time'] != null
          ? DateTime.parse(map['date_time'] as String)
          : map['dateTime'] != null
              ? DateTime.parse(map['dateTime'] as String)
              : DateTime.now(),
      items: parsedItems,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      tax: (map['tax'] as num?)?.toDouble() ?? 0.0,
      serviceCharge: (map['service_charge'] as num?)?.toDouble() ??
          (map['serviceCharge'] as num?)?.toDouble() ??
          0.0,
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == pmName,
        orElse: () => PaymentMethod.cash,
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == statusName,
        orElse: () => TransactionStatus.completed,
      ),
      cashierName: map['cashier_name'] as String? ?? map['cashierName'] as String? ?? '',
      customerName: map['customer_name'] as String? ??
          map['customerName'] as String? ??
          'Pelanggan Umum',
      tableNumber: map['table_number'] as String? ?? map['tableNumber'] as String? ?? '',
      cashReceived: (map['cash_received'] as num?)?.toDouble() ??
          (map['cashReceived'] as num?)?.toDouble() ??
          0.0,
      cashChange: (map['cash_change'] as num?)?.toDouble() ??
          (map['cashChange'] as num?)?.toDouble() ??
          0.0,
      referenceNumber:
          map['reference_number'] as String? ?? map['referenceNumber'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
    );
  }
}

class StockMutation {
  final String id;
  final String productId;
  final String productName;
  final StockMutationType type;
  final int qty;
  final int previousStock;
  final int currentStock;
  final String note;
  final DateTime timestamp;
  final String cashierName;

  const StockMutation({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.qty,
    required this.previousStock,
    required this.currentStock,
    required this.note,
    required this.timestamp,
    required this.cashierName,
  });

  StockMutation copyWith({
    String? id,
    String? productId,
    String? productName,
    StockMutationType? type,
    int? qty,
    int? previousStock,
    int? currentStock,
    String? note,
    DateTime? timestamp,
    String? cashierName,
  }) {
    return StockMutation(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      type: type ?? this.type,
      qty: qty ?? this.qty,
      previousStock: previousStock ?? this.previousStock,
      currentStock: currentStock ?? this.currentStock,
      note: note ?? this.note,
      timestamp: timestamp ?? this.timestamp,
      cashierName: cashierName ?? this.cashierName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'type': type.name,
      'qty': qty,
      'previous_stock': previousStock,
      'current_stock': currentStock,
      'note': note,
      'timestamp': timestamp.toIso8601String(),
      'cashier_name': cashierName,
    };
  }

  factory StockMutation.fromMap(Map<String, dynamic> map) {
    final typeName = map['type'] as String? ?? StockMutationType.inbound.name;
    return StockMutation(
      id: map['id'] as String? ?? '',
      productId: map['product_id'] as String? ?? map['productId'] as String? ?? '',
      productName: map['product_name'] as String? ?? map['productName'] as String? ?? '',
      type: StockMutationType.values.firstWhere(
        (e) => e.name == typeName,
        orElse: () => StockMutationType.inbound,
      ),
      qty: (map['qty'] as num?)?.toInt() ?? 0,
      previousStock: (map['previous_stock'] as num?)?.toInt() ??
          (map['previousStock'] as num?)?.toInt() ??
          0,
      currentStock: (map['current_stock'] as num?)?.toInt() ??
          (map['currentStock'] as num?)?.toInt() ??
          0,
      note: map['note'] as String? ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'] as String)
          : DateTime.now(),
      cashierName: map['cashier_name'] as String? ?? map['cashierName'] as String? ?? '',
    );
  }
}

class Shift {
  final String id;
  final String cashierName;
  final DateTime startTime;
  DateTime? endTime;
  final double startingCash;
  double cashIn;
  double cashOut;
  double cashSales;
  double nonCashSales;
  double actualCash;
  String notes;
  bool isClosed;

  Shift({
    required this.id,
    required this.cashierName,
    required this.startTime,
    this.endTime,
    required this.startingCash,
    this.cashIn = 0.0,
    this.cashOut = 0.0,
    this.cashSales = 0.0,
    this.nonCashSales = 0.0,
    this.actualCash = 0.0,
    this.notes = '',
    this.isClosed = false,
  });

  double get expectedCash => startingCash + cashSales + cashIn - cashOut;
  double get difference => actualCash - expectedCash;
  double get totalSales => cashSales + nonCashSales;

  Shift copyWith({
    String? id,
    String? cashierName,
    DateTime? startTime,
    DateTime? endTime,
    double? startingCash,
    double? cashIn,
    double? cashOut,
    double? cashSales,
    double? nonCashSales,
    double? actualCash,
    String? notes,
    bool? isClosed,
  }) {
    return Shift(
      id: id ?? this.id,
      cashierName: cashierName ?? this.cashierName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      startingCash: startingCash ?? this.startingCash,
      cashIn: cashIn ?? this.cashIn,
      cashOut: cashOut ?? this.cashOut,
      cashSales: cashSales ?? this.cashSales,
      nonCashSales: nonCashSales ?? this.nonCashSales,
      actualCash: actualCash ?? this.actualCash,
      notes: notes ?? this.notes,
      isClosed: isClosed ?? this.isClosed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cashier_name': cashierName,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'starting_cash': startingCash,
      'cash_in': cashIn,
      'cash_out': cashOut,
      'cash_sales': cashSales,
      'non_cash_sales': nonCashSales,
      'actual_cash': actualCash,
      'notes': notes,
      'is_closed': isClosed,
    };
  }

  factory Shift.fromMap(Map<String, dynamic> map) {
    return Shift(
      id: map['id'] as String? ?? '',
      cashierName: map['cashier_name'] as String? ?? map['cashierName'] as String? ?? '',
      startTime: map['start_time'] != null
          ? DateTime.parse(map['start_time'] as String)
          : map['startTime'] != null
              ? DateTime.parse(map['startTime'] as String)
              : DateTime.now(),
      endTime: map['end_time'] != null
          ? DateTime.parse(map['end_time'] as String)
          : map['endTime'] != null
              ? DateTime.parse(map['endTime'] as String)
              : null,
      startingCash: (map['starting_cash'] as num?)?.toDouble() ??
          (map['startingCash'] as num?)?.toDouble() ??
          0.0,
      cashIn: (map['cash_in'] as num?)?.toDouble() ??
          (map['cashIn'] as num?)?.toDouble() ??
          0.0,
      cashOut: (map['cash_out'] as num?)?.toDouble() ??
          (map['cashOut'] as num?)?.toDouble() ??
          0.0,
      cashSales: (map['cash_sales'] as num?)?.toDouble() ??
          (map['cashSales'] as num?)?.toDouble() ??
          0.0,
      nonCashSales: (map['non_cash_sales'] as num?)?.toDouble() ??
          (map['nonCashSales'] as num?)?.toDouble() ??
          0.0,
      actualCash: (map['actual_cash'] as num?)?.toDouble() ??
          (map['actualCash'] as num?)?.toDouble() ??
          0.0,
      notes: map['notes'] as String? ?? '',
      isClosed: map['is_closed'] == true ||
          map['is_closed'] == 1 ||
          map['isClosed'] == true,
    );
  }
}

class UserAccount {
  final String id;
  final String name;
  final UserRole role;
  final String pin;
  final bool isActive;

  const UserAccount({
    required this.id,
    required this.name,
    required this.role,
    required this.pin,
    this.isActive = true,
  });

  String get roleTitle {
    switch (role) {
      case UserRole.owner:
        return 'Owner / Admin';
      case UserRole.manager:
        return 'Manager Toko';
      case UserRole.cashier:
        return 'Kasir';
    }
  }

  UserAccount copyWith({
    String? id,
    String? name,
    UserRole? role,
    String? pin,
    bool? isActive,
  }) {
    return UserAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      pin: pin ?? this.pin,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role.name,
      'pin': pin,
      'is_active': isActive,
    };
  }

  factory UserAccount.fromMap(Map<String, dynamic> map) {
    final roleName = map['role'] as String? ?? UserRole.cashier.name;
    return UserAccount(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == roleName,
        orElse: () => UserRole.cashier,
      ),
      pin: map['pin'] as String? ?? '',
      isActive: map['is_active'] == null ||
          map['is_active'] == true ||
          map['is_active'] == 1 ||
          map['isActive'] == true,
    );
  }
}

class StoreProfile {
  final String name;
  final String tagline;
  final String address;
  final String phone;
  final String headerNote;
  final String footerNote;
  final double taxPercentage;
  final double servicePercentage;
  final bool isTaxEnabled;
  final bool isServiceEnabled;

  const StoreProfile({
    this.name = 'Kopi & Roti Nusantara',
    this.tagline = 'Artisan Bakery & Specialty Coffee',
    this.address = 'Jl. Senopati No. 45, Kebayoran Baru, Jakarta Selatan',
    this.phone = '0812-3456-7890',
    this.headerNote = 'Selamat Menikmati Hidangan Kami',
    this.footerNote = 'Barang yang dibeli tidak dapat ditukar. Terima kasih!',
    this.taxPercentage = 10.0,
    this.servicePercentage = 5.0,
    this.isTaxEnabled = false,
    this.isServiceEnabled = false,
  });

  StoreProfile copyWith({
    String? name,
    String? tagline,
    String? address,
    String? phone,
    String? headerNote,
    String? footerNote,
    double? taxPercentage,
    double? servicePercentage,
    bool? isTaxEnabled,
    bool? isServiceEnabled,
  }) {
    return StoreProfile(
      name: name ?? this.name,
      tagline: tagline ?? this.tagline,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      headerNote: headerNote ?? this.headerNote,
      footerNote: footerNote ?? this.footerNote,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      servicePercentage: servicePercentage ?? this.servicePercentage,
      isTaxEnabled: isTaxEnabled ?? this.isTaxEnabled,
      isServiceEnabled: isServiceEnabled ?? this.isServiceEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'tagline': tagline,
      'address': address,
      'phone': phone,
      'header_note': headerNote,
      'footer_note': footerNote,
      'tax_percentage': taxPercentage,
      'service_percentage': servicePercentage,
      'is_tax_enabled': isTaxEnabled,
      'is_service_enabled': isServiceEnabled,
    };
  }

  factory StoreProfile.fromMap(Map<String, dynamic> map) {
    const defaults = StoreProfile();

    double readDouble(String key, double fallback) {
      final value = map[key];
      return value is num ? value.toDouble() : fallback;
    }

    bool readBool(String key, bool fallback) {
      final value = map[key];
      if (value is bool) return value;
      if (value is num) return value != 0;
      return fallback;
    }

    return StoreProfile(
      name: map['name'] as String? ?? defaults.name,
      tagline: map['tagline'] as String? ?? defaults.tagline,
      address: map['address'] as String? ?? defaults.address,
      phone: map['phone'] as String? ?? defaults.phone,
      headerNote: map['header_note'] as String? ?? defaults.headerNote,
      footerNote: map['footer_note'] as String? ?? defaults.footerNote,
      taxPercentage: readDouble('tax_percentage', defaults.taxPercentage),
      servicePercentage: readDouble('service_percentage', defaults.servicePercentage),
      isTaxEnabled: readBool('is_tax_enabled', defaults.isTaxEnabled),
      isServiceEnabled: readBool('is_service_enabled', defaults.isServiceEnabled),
    );
  }
}

class PrinterSettings {
  final String name;
  final String paperSize;
  final bool isConnected;

  const PrinterSettings({
    this.name = 'RP-58 Bluetooth Thermal (Connected)',
    this.paperSize = '58mm',
    this.isConnected = true,
  });

  PrinterSettings copyWith({
    String? name,
    String? paperSize,
    bool? isConnected,
  }) {
    return PrinterSettings(
      name: name ?? this.name,
      paperSize: paperSize ?? this.paperSize,
      isConnected: isConnected ?? this.isConnected,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'paper_size': paperSize,
      'is_connected': isConnected,
    };
  }

  factory PrinterSettings.fromMap(Map<String, dynamic> map) {
    const defaults = PrinterSettings();
    final connected = map['is_connected'];
    return PrinterSettings(
      name: map['name'] as String? ?? defaults.name,
      paperSize: map['paper_size'] as String? ?? defaults.paperSize,
      isConnected: connected is bool
          ? connected
          : connected is num
              ? connected != 0
              : defaults.isConnected,
    );
  }
}
