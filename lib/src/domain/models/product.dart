class ProductVariant {
  const ProductVariant({
    required this.id,
    required this.productId,
    required this.name,
    required this.priceAdjustment,
    this.sku,
  });

  final String id;
  final String productId;
  final String name;
  final double priceAdjustment;
  final String? sku;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'name': name,
      'price_adjustment': priceAdjustment,
      'sku': sku,
    };
  }

  factory ProductVariant.fromMap(Map<String, dynamic> map) {
    return ProductVariant(
      id: map['id'] as String,
      productId: map['product_id'] as String,
      name: map['name'] as String,
      priceAdjustment: (map['price_adjustment'] as num).toDouble(),
      sku: map['sku'] as String?,
    );
  }
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.sellPrice,
    this.sku = '',
    this.barcode = '',
    this.buyPrice = 0,
    this.wholesalePrice,
    this.stock = 0,
    this.minStockAlert = 5,
    this.unit = 'Pcs',
    this.categoryId,
    this.imageUrl,
    this.hasVariants = false,
    this.variants = const [],
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String sku;
  final String barcode;
  final double buyPrice;
  final double sellPrice;
  final double? wholesalePrice;
  final double stock;
  final double minStockAlert;
  final String unit;
  final String? categoryId;
  final String? imageUrl;
  final bool hasVariants;
  final List<ProductVariant> variants;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isLowStock => stock <= minStockAlert;

  Product copyWith({
    String? id,
    String? name,
    String? sku,
    String? barcode,
    double? buyPrice,
    double? sellPrice,
    double? wholesalePrice,
    double? stock,
    double? minStockAlert,
    String? unit,
    String? categoryId,
    String? imageUrl,
    bool? hasVariants,
    List<ProductVariant>? variants,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      buyPrice: buyPrice ?? this.buyPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      stock: stock ?? this.stock,
      minStockAlert: minStockAlert ?? this.minStockAlert,
      unit: unit ?? this.unit,
      categoryId: categoryId ?? this.categoryId,
      imageUrl: imageUrl ?? this.imageUrl,
      hasVariants: hasVariants ?? this.hasVariants,
      variants: variants ?? this.variants,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'barcode': barcode,
      'buy_price': buyPrice,
      'sell_price': sellPrice,
      'wholesale_price': wholesalePrice,
      'stock': stock,
      'min_stock_alert': minStockAlert,
      'unit': unit,
      'category_id': categoryId,
      'image_url': imageUrl,
      'has_variants': hasVariants ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Product.fromMap(
    Map<String, dynamic> map, {
    List<ProductVariant> variants = const [],
  }) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      sku: (map['sku'] as String?) ?? '',
      barcode: (map['barcode'] as String?) ?? '',
      buyPrice: (map['buy_price'] as num?)?.toDouble() ?? 0.0,
      sellPrice: (map['sell_price'] as num).toDouble(),
      wholesalePrice: (map['wholesale_price'] as num?)?.toDouble(),
      stock: (map['stock'] as num?)?.toDouble() ?? 0.0,
      minStockAlert: (map['min_stock_alert'] as num?)?.toDouble() ?? 5.0,
      unit: (map['unit'] as String?) ?? 'Pcs',
      categoryId: map['category_id'] as String?,
      imageUrl: map['image_url'] as String?,
      hasVariants: map['has_variants'] == 1 || map['has_variants'] == true,
      variants: variants,
      isActive: map['is_active'] == null || map['is_active'] == 1 || map['is_active'] == true,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
