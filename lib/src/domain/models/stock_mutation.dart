enum StockMutationType { inbound, outbound, adjustment, sale, returned }

class StockMutation {
  const StockMutation({
    required this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.stockBefore,
    required this.stockAfter,
    required this.createdAt,
    this.reason,
    this.referenceId,
    this.userId,
  });

  final String id;
  final String productId;
  final StockMutationType type;
  final double quantity;
  final double stockBefore;
  final double stockAfter;
  final String? reason;
  final String? referenceId;
  final String? userId;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'type': type.name,
      'quantity': quantity,
      'stock_before': stockBefore,
      'stock_after': stockAfter,
      'reason': reason,
      'reference_id': referenceId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory StockMutation.fromMap(Map<String, dynamic> map) {
    return StockMutation(
      id: map['id'] as String,
      productId: map['product_id'] as String,
      type: StockMutationType.values.byName(
        (map['type'] as String) == 'return' ? 'returned' : map['type'] as String,
      ),
      quantity: (map['quantity'] as num).toDouble(),
      stockBefore: (map['stock_before'] as num).toDouble(),
      stockAfter: (map['stock_after'] as num).toDouble(),
      reason: map['reason'] as String?,
      referenceId: map['reference_id'] as String?,
      userId: map['user_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
