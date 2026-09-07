class Category {
  const Category({
    required this.id,
    required this.name,
    this.colorHex = '#FF6B00',
    this.iconName = 'tag',
  });

  final String id;
  final String name;
  final String colorHex;
  final String iconName;

  Category copyWith({
    String? id,
    String? name,
    String? colorHex,
    String? iconName,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      iconName: iconName ?? this.iconName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color_hex': colorHex,
      'icon_name': iconName,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      colorHex: (map['color_hex'] as String?) ?? '#FF6B00',
      iconName: (map['icon_name'] as String?) ?? 'tag',
    );
  }
}
