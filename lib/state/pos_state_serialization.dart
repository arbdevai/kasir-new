import 'package:flutter/material.dart';

import '../models/models.dart';
import 'pos_state.dart';

/// JSON-safe representation helpers for the active POS state.
///
/// These helpers only create plain maps, lists, strings, numbers and booleans;
/// no live model references are placed in a backup payload.
extension PosStateSerialization on PosState {
  Map<String, dynamic> toBackupMap() => <String, dynamic>{
        'storeProfile': _profileToMap(storeProfile),
        'users': users.map(_userToMap).toList(growable: false),
        'currentUserId': currentUser.id,
        'categories': categories.map(_categoryToMap).toList(growable: false),
        'products': products.map(_productToMap).toList(growable: false),
        'selectedCategoryId': selectedCategoryId,
        'searchQuery': searchQuery,
        'cart': cart.map(_cartItemToMap).toList(growable: false),
        'orderDiscountPercent': orderDiscountPercent,
        'orderDiscountNominal': orderDiscountNominal,
        'activeCustomerName': activeCustomerName,
        'activeTableNumber': activeTableNumber,
        'activeOrderNote': activeOrderNote,
        'transactions': transactions.map(_transactionToMap).toList(growable: false),
        'stockMutations': stockMutations.map(_stockMutationToMap).toList(growable: false),
        'currentShift': currentShift == null ? null : _shiftToMap(currentShift!),
        'pastShifts': pastShifts.map(_shiftToMap).toList(growable: false),
        'selectedPrinterName': selectedPrinterName,
        'selectedPaperSize': selectedPaperSize,
        'isPrinterConnected': isPrinterConnected,
      };

  /// Replaces state only after every value has been decoded successfully.
  void restoreBackupMap(Map<String, dynamic> map) {
    final decoded = _decodeState(map);
    storeProfile = decoded.profile;
    users = decoded.users;
    currentUser = decoded.currentUser;
    categories = decoded.categories;
    products = decoded.products;
    selectedCategoryId = decoded.selectedCategoryId;
    searchQuery = decoded.searchQuery;
    cart = decoded.cart;
    orderDiscountPercent = decoded.orderDiscountPercent;
    orderDiscountNominal = decoded.orderDiscountNominal;
    activeCustomerName = decoded.activeCustomerName;
    activeTableNumber = decoded.activeTableNumber;
    activeOrderNote = decoded.activeOrderNote;
    transactions = decoded.transactions;
    stockMutations = decoded.stockMutations;
    currentShift = decoded.currentShift;
    pastShifts = decoded.pastShifts;
    selectedPrinterName = decoded.selectedPrinterName;
    selectedPaperSize = decoded.selectedPaperSize;
    isPrinterConnected = decoded.isPrinterConnected;
    notifyListeners();
  }
}

Map<String, dynamic> _profileToMap(StoreProfile p) => <String, dynamic>{
      'name': p.name,
      'tagline': p.tagline,
      'address': p.address,
      'phone': p.phone,
      'headerNote': p.headerNote,
      'footerNote': p.footerNote,
      'taxPercentage': p.taxPercentage,
      'servicePercentage': p.servicePercentage,
      'isTaxEnabled': p.isTaxEnabled,
      'isServiceEnabled': p.isServiceEnabled,
    };

StoreProfile _profileFromMap(Map<String, dynamic> m) => StoreProfile(
      name: _string(m, 'name'),
      tagline: _string(m, 'tagline'),
      address: _string(m, 'address'),
      phone: _string(m, 'phone'),
      headerNote: _string(m, 'headerNote'),
      footerNote: _string(m, 'footerNote'),
      taxPercentage: _number(m, 'taxPercentage'),
      servicePercentage: _number(m, 'servicePercentage'),
      isTaxEnabled: _bool(m, 'isTaxEnabled'),
      isServiceEnabled: _bool(m, 'isServiceEnabled'),
    );

Map<String, dynamic> _userToMap(UserAccount u) => <String, dynamic>{
      'id': u.id,
      'name': u.name,
      'role': u.role.name,
      'pin': u.pin,
      'isActive': u.isActive,
    };

UserAccount _userFromMap(Map<String, dynamic> m) => UserAccount(
      id: _string(m, 'id'),
      name: _string(m, 'name'),
      role: UserRole.values.byName(_string(m, 'role')),
      pin: _string(m, 'pin'),
      isActive: _bool(m, 'isActive'),
    );

Map<String, dynamic> _categoryToMap(Category c) => <String, dynamic>{
      'id': c.id,
      'name': c.name,
      'iconCodePoint': c.icon.codePoint,
      'fontFamily': c.icon.fontFamily,
      'fontPackage': c.icon.fontPackage,
      'color': c.color.value,
    };

Category _categoryFromMap(Map<String, dynamic> m) => Category(
      id: _string(m, 'id'),
      name: _string(m, 'name'),
      icon: IconData(
        _int(m, 'iconCodePoint'),
        fontFamily: m['fontFamily'] as String?,
        fontPackage: m['fontPackage'] as String?,
      ),
      color: Color(_int(m, 'color')),
    );

Map<String, dynamic> _variantToMap(ProductVariant v) => <String, dynamic>{
      'id': v.id,
      'name': v.name,
      'additionalPrice': v.additionalPrice,
    };

ProductVariant _variantFromMap(Map<String, dynamic> m) => ProductVariant(
      id: _string(m, 'id'),
      name: _string(m, 'name'),
      additionalPrice: _number(m, 'additionalPrice'),
    );

Map<String, dynamic> _productToMap(Product p) => <String, dynamic>{
      'id': p.id,
      'name': p.name,
      'sku': p.sku,
      'barcode': p.barcode,
      'price': p.price,
      'costPrice': p.costPrice,
      'stock': p.stock,
      'unit': p.unit,
      'categoryId': p.categoryId,
      'categoryName': p.categoryName,
      'imageUrl': p.imageUrl,
      'variants': p.variants.map(_variantToMap).toList(growable: false),
      'minStockAlert': p.minStockAlert,
    };

Product _productFromMap(Map<String, dynamic> m) => Product(
      id: _string(m, 'id'),
      name: _string(m, 'name'),
      sku: _string(m, 'sku'),
      barcode: _string(m, 'barcode'),
      price: _number(m, 'price'),
      costPrice: _number(m, 'costPrice'),
      stock: _int(m, 'stock'),
      unit: _string(m, 'unit'),
      categoryId: _string(m, 'categoryId'),
      categoryName: _string(m, 'categoryName'),
      imageUrl: m['imageUrl'] as String?,
      variants: _list(m, 'variants').map((v) => _variantFromMap(_map(v))).toList(),
      minStockAlert: _int(m, 'minStockAlert'),
    );

Map<String, dynamic> _cartItemToMap(CartItem i) => <String, dynamic>{
      'id': i.id,
      'productId': i.product.id,
      'product': _productToMap(i.product),
      'quantity': i.quantity,
      'unitPrice': i.unitPrice,
      'note': i.note,
      'discountNominal': i.discountNominal,
      'selectedVariantId': i.selectedVariant?.id,
    };

CartItem _cartItemFromMap(Map<String, dynamic> m, Map<String, Product> products) {
  final productMap = _map(m['product']);
  final product = products[_string(m, 'productId')] ?? _productFromMap(productMap);
  final variantId = m['selectedVariantId'] as String?;
  ProductVariant? variant;
  if (variantId != null) {
    variant = product.variants.cast<ProductVariant?>().firstWhere(
      (v) => v?.id == variantId,
      orElse: () => null,
    );
  }
  return CartItem(
    id: _string(m, 'id'),
    product: product,
    quantity: _int(m, 'quantity'),
    unitPrice: _number(m, 'unitPrice'),
    note: _string(m, 'note'),
    discountNominal: _number(m, 'discountNominal'),
    selectedVariant: variant,
  );
}

Map<String, dynamic> _transactionToMap(Transaction t) => <String, dynamic>{
      'id': t.id,
      'invoiceNumber': t.invoiceNumber,
      'dateTime': t.dateTime.toIso8601String(),
      'items': t.items.map(_cartItemToMap).toList(growable: false),
      'subtotal': t.subtotal,
      'discount': t.discount,
      'tax': t.tax,
      'serviceCharge': t.serviceCharge,
      'total': t.total,
      'paymentMethod': t.paymentMethod.name,
      'status': t.status.name,
      'cashierName': t.cashierName,
      'customerName': t.customerName,
      'tableNumber': t.tableNumber,
      'cashReceived': t.cashReceived,
      'cashChange': t.cashChange,
      'referenceNumber': t.referenceNumber,
      'notes': t.notes,
    };

Transaction _transactionFromMap(Map<String, dynamic> m, Map<String, Product> products) => Transaction(
      id: _string(m, 'id'),
      invoiceNumber: _string(m, 'invoiceNumber'),
      dateTime: DateTime.parse(_string(m, 'dateTime')),
      items: _list(m, 'items').map((i) => _cartItemFromMap(_map(i), products)).toList(),
      subtotal: _number(m, 'subtotal'),
      discount: _number(m, 'discount'),
      tax: _number(m, 'tax'),
      serviceCharge: _number(m, 'serviceCharge'),
      total: _number(m, 'total'),
      paymentMethod: PaymentMethod.values.byName(_string(m, 'paymentMethod')),
      status: TransactionStatus.values.byName(_string(m, 'status')),
      cashierName: _string(m, 'cashierName'),
      customerName: _string(m, 'customerName'),
      tableNumber: _string(m, 'tableNumber'),
      cashReceived: _number(m, 'cashReceived'),
      cashChange: _number(m, 'cashChange'),
      referenceNumber: _string(m, 'referenceNumber'),
      notes: _string(m, 'notes'),
    );

Map<String, dynamic> _stockMutationToMap(StockMutation s) => <String, dynamic>{
      'id': s.id,
      'productId': s.productId,
      'productName': s.productName,
      'type': s.type.name,
      'qty': s.qty,
      'previousStock': s.previousStock,
      'currentStock': s.currentStock,
      'note': s.note,
      'timestamp': s.timestamp.toIso8601String(),
      'cashierName': s.cashierName,
    };

StockMutation _stockMutationFromMap(Map<String, dynamic> m) => StockMutation(
      id: _string(m, 'id'),
      productId: _string(m, 'productId'),
      productName: _string(m, 'productName'),
      type: StockMutationType.values.byName(_string(m, 'type')),
      qty: _int(m, 'qty'),
      previousStock: _int(m, 'previousStock'),
      currentStock: _int(m, 'currentStock'),
      note: _string(m, 'note'),
      timestamp: DateTime.parse(_string(m, 'timestamp')),
      cashierName: _string(m, 'cashierName'),
    );

Map<String, dynamic> _shiftToMap(Shift s) => <String, dynamic>{
      'id': s.id,
      'cashierName': s.cashierName,
      'startTime': s.startTime.toIso8601String(),
      'endTime': s.endTime?.toIso8601String(),
      'startingCash': s.startingCash,
      'cashIn': s.cashIn,
      'cashOut': s.cashOut,
      'cashSales': s.cashSales,
      'nonCashSales': s.nonCashSales,
      'actualCash': s.actualCash,
      'notes': s.notes,
      'isClosed': s.isClosed,
    };

Shift _shiftFromMap(Map<String, dynamic> m) => Shift(
      id: _string(m, 'id'),
      cashierName: _string(m, 'cashierName'),
      startTime: DateTime.parse(_string(m, 'startTime')),
      endTime: m['endTime'] == null ? null : DateTime.parse(m['endTime'] as String),
      startingCash: _number(m, 'startingCash'),
      cashIn: _number(m, 'cashIn'),
      cashOut: _number(m, 'cashOut'),
      cashSales: _number(m, 'cashSales'),
      nonCashSales: _number(m, 'nonCashSales'),
      actualCash: _number(m, 'actualCash'),
      notes: _string(m, 'notes'),
      isClosed: _bool(m, 'isClosed'),
    );

class _DecodedState {
  const _DecodedState({
    required this.profile,
    required this.users,
    required this.currentUser,
    required this.categories,
    required this.products,
    required this.selectedCategoryId,
    required this.searchQuery,
    required this.cart,
    required this.orderDiscountPercent,
    required this.orderDiscountNominal,
    required this.activeCustomerName,
    required this.activeTableNumber,
    required this.activeOrderNote,
    required this.transactions,
    required this.stockMutations,
    required this.currentShift,
    required this.pastShifts,
    required this.selectedPrinterName,
    required this.selectedPaperSize,
    required this.isPrinterConnected,
  });

  final StoreProfile profile;
  final List<UserAccount> users;
  final UserAccount currentUser;
  final List<Category> categories;
  final List<Product> products;
  final String selectedCategoryId;
  final String searchQuery;
  final List<CartItem> cart;
  final double orderDiscountPercent;
  final double orderDiscountNominal;
  final String activeCustomerName;
  final String activeTableNumber;
  final String activeOrderNote;
  final List<Transaction> transactions;
  final List<StockMutation> stockMutations;
  final Shift? currentShift;
  final List<Shift> pastShifts;
  final String selectedPrinterName;
  final String selectedPaperSize;
  final bool isPrinterConnected;
}

_DecodedState _decodeState(Map<String, dynamic> m) {
  final products = _list(m, 'products').map((p) => _productFromMap(_map(p))).toList();
  final productMap = <String, Product>{for (final p in products) p.id: p};
  final users = _list(m, 'users').map((u) => _userFromMap(_map(u))).toList();
  final currentUserId = _string(m, 'currentUserId');
  final currentUser = users.firstWhere((u) => u.id == currentUserId);
  return _DecodedState(
    profile: _profileFromMap(_map(m['storeProfile'])),
    users: users,
    currentUser: currentUser,
    categories: _list(m, 'categories').map((c) => _categoryFromMap(_map(c))).toList(),
    products: products,
    selectedCategoryId: _string(m, 'selectedCategoryId'),
    searchQuery: _string(m, 'searchQuery'),
    cart: _list(m, 'cart').map((i) => _cartItemFromMap(_map(i), productMap)).toList(),
    orderDiscountPercent: _number(m, 'orderDiscountPercent'),
    orderDiscountNominal: _number(m, 'orderDiscountNominal'),
    activeCustomerName: _string(m, 'activeCustomerName'),
    activeTableNumber: _string(m, 'activeTableNumber'),
    activeOrderNote: _string(m, 'activeOrderNote'),
    transactions: _list(m, 'transactions').map((t) => _transactionFromMap(_map(t), productMap)).toList(),
    stockMutations: _list(m, 'stockMutations').map((s) => _stockMutationFromMap(_map(s))).toList(),
    currentShift: m['currentShift'] == null ? null : _shiftFromMap(_map(m['currentShift'])),
    pastShifts: _list(m, 'pastShifts').map((s) => _shiftFromMap(_map(s))).toList(),
    selectedPrinterName: _string(m, 'selectedPrinterName'),
    selectedPaperSize: _string(m, 'selectedPaperSize'),
    isPrinterConnected: _bool(m, 'isPrinterConnected'),
  );
}

Map<String, dynamic> _map(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((key, value) => MapEntry(key.toString(), value));
  throw const FormatException('Expected JSON object');
}

List<dynamic> _list(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is List) return value;
  throw FormatException('Expected list for $key');
}

String _string(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is String) return value;
  throw FormatException('Expected string for $key');
}

double _number(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is num && value.isFinite) return value.toDouble();
  throw FormatException('Expected number for $key');
}

int _int(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is num && value.isFinite) return value.toInt();
  throw FormatException('Expected integer for $key');
}

bool _bool(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is bool) return value;
  throw FormatException('Expected boolean for $key');
}
