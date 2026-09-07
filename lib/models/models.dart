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
}
