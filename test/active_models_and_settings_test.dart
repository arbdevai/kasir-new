import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasir_new/data/settings_repository.dart';
import 'package:kasir_new/models/models.dart';
import 'package:kasir_new/state/pos_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('active domain models serialize and deserialize correctly', () {
    const category = Category(
      id: 'cat_test',
      name: 'Minuman',
      icon: Icons.local_drink_rounded,
      color: Color(0xFF34C759),
    );
    final categoryMap = category.toMap();
    final restoredCategory = Category.fromMap(categoryMap);
    expect(restoredCategory.id, category.id);
    expect(restoredCategory.name, category.name);
    expect(restoredCategory.color.value, category.color.value);

    const variant = ProductVariant(
      id: 'var_1',
      name: 'Large',
      additionalPrice: 5000.0,
    );
    final restoredVariant = ProductVariant.fromMap(variant.toMap());
    expect(restoredVariant.name, 'Large');
    expect(restoredVariant.additionalPrice, 5000.0);

    const product = Product(
      id: 'prod_1',
      name: 'Espresso',
      sku: 'ESP-01',
      barcode: '12345678',
      price: 20000.0,
      costPrice: 8000.0,
      stock: 50,
      unit: 'Cup',
      categoryId: 'cat_test',
      categoryName: 'Minuman',
      variants: [variant],
      minStockAlert: 5,
    );
    final restoredProduct = Product.fromMap(product.toMap());
    expect(restoredProduct.id, 'prod_1');
    expect(restoredProduct.price, 20000.0);
    expect(restoredProduct.variants.length, 1);
    expect(restoredProduct.variants.first.name, 'Large');

    final cartItem = CartItem(
      id: 'item_1',
      product: product,
      quantity: 2,
      unitPrice: 25000.0,
      selectedVariant: variant,
      note: 'Less ice',
    );
    final restoredCartItem = CartItem.fromMap(cartItem.toMap());
    expect(restoredCartItem.id, 'item_1');
    expect(restoredCartItem.quantity, 2);
    expect(restoredCartItem.subtotal, 50000.0);
    expect(restoredCartItem.selectedVariant?.name, 'Large');

    final now = DateTime(2026, 9, 7, 12, 0, 0);
    final transaction = Transaction(
      id: 'tx_1',
      invoiceNumber: 'INV/20260907/001',
      dateTime: now,
      items: [cartItem],
      subtotal: 50000.0,
      discount: 5000.0,
      tax: 4500.0,
      serviceCharge: 0.0,
      total: 49500.0,
      paymentMethod: PaymentMethod.qris,
      status: TransactionStatus.completed,
      cashierName: 'Budi',
    );
    final restoredTx = Transaction.fromMap(transaction.toMap());
    expect(restoredTx.invoiceNumber, 'INV/20260907/001');
    expect(restoredTx.items.length, 1);
    expect(restoredTx.total, 49500.0);
    expect(restoredTx.paymentMethod, PaymentMethod.qris);
    expect(restoredTx.status, TransactionStatus.completed);

    final mutation = StockMutation(
      id: 'sm_1',
      productId: 'prod_1',
      productName: 'Espresso',
      type: StockMutationType.sale,
      qty: -2,
      previousStock: 50,
      currentStock: 48,
      note: 'Penjualan',
      timestamp: now,
      cashierName: 'Budi',
    );
    final restoredMutation = StockMutation.fromMap(mutation.toMap());
    expect(restoredMutation.productId, 'prod_1');
    expect(restoredMutation.qty, -2);
    expect(restoredMutation.type, StockMutationType.sale);

    final shift = Shift(
      id: 'sh_1',
      cashierName: 'Budi',
      startTime: now,
      startingCash: 100000.0,
      cashSales: 50000.0,
    );
    final restoredShift = Shift.fromMap(shift.toMap());
    expect(restoredShift.cashierName, 'Budi');
    expect(restoredShift.startingCash, 100000.0);

    const user = UserAccount(
      id: 'u1',
      name: 'Budi',
      role: UserRole.owner,
      pin: '1234',
    );
    final restoredUser = UserAccount.fromMap(user.toMap());
    expect(restoredUser.role, UserRole.owner);
    expect(restoredUser.pin, '1234');
  });

  test('createPosState loads persisted settings and updates persist asynchronously', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = SettingsRepository(await SharedPreferences.getInstance());

    const persistedProfile = StoreProfile(
      name: 'Kedai Sukses',
      tagline: 'Kopi & Roti Enak',
      address: 'Jl. Melati No. 10',
      isTaxEnabled: true,
      isServiceEnabled: true,
    );
    const persistedPrinter = PrinterSettings(
      name: 'Printer Dapur 80mm',
      paperSize: '80mm',
      isConnected: false,
    );

    await repository.saveStoreProfile(persistedProfile);
    await repository.savePrinterSettings(persistedPrinter);

    final state = createPosState(repository);
    expect(state.storeProfile.name, 'Kedai Sukses');
    expect(state.storeProfile.isTaxEnabled, isTrue);
    expect(state.selectedPrinterName, 'Printer Dapur 80mm');
    expect(state.selectedPaperSize, '80mm');
    expect(state.isPrinterConnected, isFalse);

    // Update settings via PosState
    state.updateStoreProfile(persistedProfile.copyWith(name: 'Kedai Sukses Updated'));
    state.updatePrinterSettings(name: 'Printer Bluetooth Baru', isConnected: true);

    // Verify repository receives updates
    await pumpEventQueue();
    expect(repository.loadStoreProfile().name, 'Kedai Sukses Updated');
    expect(repository.loadPrinterSettings().name, 'Printer Bluetooth Baru');
    expect(repository.loadPrinterSettings().isConnected, isTrue);
  });
}
