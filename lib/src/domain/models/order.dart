import 'order_item.dart';

class Order {
  const Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
    this.subtotal = 0.0,
    this.discountAmount = 0.0,
    this.taxAmount = 0.0,
    this.serviceCharge = 0.0,
    this.totalAmount = 0.0,
    this.amountReceived = 0.0,
    this.changeAmount = 0.0,
    this.customerName,
    this.customerPhone,
    this.cashierId,
    this.note,
  });

  final String id;
  final String orderNumber;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final PaymentMethod paymentMethod;
  final List<OrderItem> items;
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double serviceCharge;
  final double totalAmount;
  final double amountReceived;
  final double changeAmount;
  final String? customerName;
  final String? customerPhone;
  final String? cashierId;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order copyWith({
    String? id,
    String? orderNumber,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    PaymentMethod? paymentMethod,
    List<OrderItem>? items,
    double? subtotal,
    double? discountAmount,
    double? taxAmount,
    double? serviceCharge,
    double? totalAmount,
    double? amountReceived,
    double? changeAmount,
    String? customerName,
    String? customerPhone,
    String? cashierId,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      serviceCharge: serviceCharge ?? this.serviceCharge,
      totalAmount: totalAmount ?? this.totalAmount,
      amountReceived: amountReceived ?? this.amountReceived,
      changeAmount: changeAmount ?? this.changeAmount,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      cashierId: cashierId ?? this.cashierId,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_number': orderNumber,
      'status': status.name,
      'payment_status': paymentStatus.name,
      'payment_method': paymentMethod.name,
      'subtotal': subtotal,
      'discount_amount': discountAmount,
      'tax_amount': taxAmount,
      'service_charge': serviceCharge,
      'total_amount': totalAmount,
      'amount_received': amountReceived,
      'change_amount': changeAmount,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'cashier_id': cashierId,
      'note': note,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Order.fromMap(
    Map<String, dynamic> map, {
    List<OrderItem> items = const [],
  }) {
    return Order(
      id: map['id'] as String,
      orderNumber: map['order_number'] as String,
      status: OrderStatus.values.byName(map['status'] as String),
      paymentStatus: PaymentStatus.values.byName(map['payment_status'] as String),
      paymentMethod: PaymentMethod.values.byName(map['payment_method'] as String),
      items: items,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (map['discount_amount'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (map['tax_amount'] as num?)?.toDouble() ?? 0.0,
      serviceCharge: (map['service_charge'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0.0,
      amountReceived: (map['amount_received'] as num?)?.toDouble() ?? 0.0,
      changeAmount: (map['change_amount'] as num?)?.toDouble() ?? 0.0,
      customerName: map['customer_name'] as String?,
      customerPhone: map['customer_phone'] as String?,
      cashierId: map['cashier_id'] as String?,
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

enum OrderStatus { draft, held, completed, voided, refunded }

enum PaymentStatus { unpaid, partiallyPaid, paid, refunded }

enum PaymentMethod { cash, qris, bankTransfer, eWallet, card, debt, split }
