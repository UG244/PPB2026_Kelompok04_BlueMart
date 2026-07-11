class Product {
  final int? id;
  final String name;
  final String description;
  final String category;
  final double price;
  final int stock;
  final String? photoPath;
  final int? supplierId;
  final bool isActive;
  final double weight;
  final double discountPercent;
  final String createdAt;
  final String updatedAt;

  Product({
    this.id,
    required this.name,
    this.description = '',
    required this.category,
    required this.price,
    required this.stock,
    this.photoPath,
    this.supplierId,
    this.isActive = false,
    this.weight = 0,
    this.discountPercent = 0,
    String? createdAt,
    String? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String(),
       updatedAt = updatedAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'stock': stock,
      'photoPath': photoPath,
      'supplierId': supplierId,
      'isActive': isActive ? 1 : 0,
      'weight': weight,
      'discountPercent': discountPercent,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: (map['description'] as String?) ?? '',
      category: map['category'] as String,
      price: (map['price'] as num).toDouble(),
      stock: map['stock'] as int,
      photoPath: map['photoPath'] as String?,
      supplierId: map['supplierId'] as int?,
      isActive: (map['isActive'] as int?) == 1,
      weight: (map['weight'] as num?)?.toDouble() ?? 0,
      discountPercent: (map['discountPercent'] as num?)?.toDouble() ?? 0,
      createdAt: map['createdAt'] as String?,
      updatedAt: map['updatedAt'] as String?,
    );
  }

  Product copyWith({
    int? id,
    String? name,
    String? description,
    String? category,
    double? price,
    int? stock,
    String? photoPath,
    int? supplierId,
    bool? isActive,
    double? weight,
    double? discountPercent,
    String? createdAt,
    String? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      photoPath: photoPath ?? this.photoPath,
      supplierId: supplierId ?? this.supplierId,
      isActive: isActive ?? this.isActive,
      weight: weight ?? this.weight,
      discountPercent: discountPercent ?? this.discountPercent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now().toIso8601String(),
    );
  }
}
