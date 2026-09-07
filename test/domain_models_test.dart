import 'package:flutter_test/flutter_test.dart';
import 'package:kasir_new/src/domain/models/category.dart';
import 'package:kasir_new/src/domain/models/order.dart';
import 'package:kasir_new/src/domain/models/order_item.dart';
import 'package:kasir_new/src/domain/models/product.dart';
import 'package:kasir_new/src/domain/models/stock_mutation.dart';
import 'package:kasir_new/src/domain/models/user.dart';

void main() {
  test('Domain models serialization roundtrip', () {
    final now = DateTime.utc(2026, 9, 7, 10, 0, 0);

    final category = Category(id: 'cat_1', name: 'Makanan');
    expect(Category.fromMap(category.toMap()).name, 'Makanan');

    final product = Product(
      id: 'prod_1',
      name: 'Kopi Susu',
      sellPrice: 18000,
      createdAt: now,
      updatedAt: now,
    );
    expect(Product.fromMap(product.toMap()).sellPrice, 18000);

    final item = OrderItem(
      id: 'item_1',
      orderId: 'ord_1',
      productId: 'prod_1',
      productName: 'Kopi Susu',
      unitPrice: 18000,
      quantity: 2,
    );
    expect(item.subtotal, 36000);

    final order = Order(
      id: 'ord_1',
      orderNumber: 'TRX-001',
      status: OrderStatus.completed,
      paymentStatus: PaymentStatus.paid,
      paymentMethod: PaymentMethod.cash,
      items: [item],
      totalAmount: 36000,
      createdAt: now,
      updatedAt: now,
    );
    expect(Order.fromMap(order.toMap(), items: [item]).orderNumber, 'TRX-001');

    final mutation = StockMutation(
      id: 'mut_1',
      productId: 'prod_1',
      type: StockMutationType.inbound,
      quantity: 10,
      stockBefore: 5,
      stockAfter: 15,
      createdAt: now,
    );
    expect(StockMutation.fromMap(mutation.toMap()).type, StockMutationType.inbound);

    final user = User(
      id: 'usr_1',
      name: 'Kasir Satu',
      role: UserRole.cashier,
      createdAt: now,
    );
    expect(User.fromMap(user.toMap()).role, UserRole.cashier);
  });
}
