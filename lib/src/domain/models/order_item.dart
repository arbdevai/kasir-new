class OrderItem {
  const OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    this.buyPrice = 0.0,
    this.discountAmount = 0.0,
    this.variantName,
    this.notes,
  });

  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final double unitPrice;
  final double quantity;
  final double buyPrice;
  final double discountAmount;
  final String? variantName;
  final String? notes;

  double get subtotal => (unitPrice * quantity) - discountAmount;
  double get profit => subtotal - (buyPrice * quantity);

  OrderItem copyWith({
    String? id,
    String? orderId,
    String? productId,
    String? productName,
    double? unitPrice,
    double? quantity,
    double? buyPrice,
    double? discountAmount,
    String? variantName,
    String? notes,
  }) {
    return OrderItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      buyPrice: buyPrice ?? this.buyPrice,
      discountAmount: discountAmount ?? this.discountAmount,
      variantName: variantName ?? this.variantName,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'unit_price': unitPrice,
      'quantity': quantity,
      'buy_price': buyPrice,
      'discount_amount': discountAmount,
      'variant_name': variantName,
      'notes': notes,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'] as String,
      orderId: map['order_id'] as String,
      productId: map['product_id'] as String,
      productName: map['product_name'] as String,
      unitPrice: (map['unit_price'] as num).toDouble(),
      quantity: (map['quantity'] as num).toDouble(),
      buyPrice: (map['buy_price'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (map['discount_amount'] as num?)?.toDouble() ?? 0.0,
      variantName: map['variant_name'] as String?,
      notes: map['notes'] as String?,
    );
  }
}
