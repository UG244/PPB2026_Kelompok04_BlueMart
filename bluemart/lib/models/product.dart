class Product {
  final int? id;
  final String name;
  final String category;
  final double price;
  final double? originalPrice;
  final int stock;
  final String? photoPath;
  final int? supplierId;
  final bool isActive;
  final int? discountPercent;
  final double? rating;
  final int? reviewCount;
  final double? weight;
  final String createdAt;
  final String updatedAt;

  Product({
    this.id,
    required this.name,
    required this.category,
    required this.price,
    this.originalPrice,
    required this.stock,
    this.photoPath,
    this.supplierId,
    this.isActive = false,
    this.discountPercent,
    this.rating,
    this.reviewCount,
    this.weight,
    String? createdAt,
    String? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String(),
       updatedAt = updatedAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'category': category,
      'price': price,
      'originalPrice': originalPrice,
      'stock': stock,
      'photoPath': photoPath,
      'supplierId': supplierId,
      'isActive': isActive ? 1 : 0,
      'discountPercent': discountPercent,
      'rating': rating,
      'reviewCount': reviewCount,
      'weight': weight,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      category: map['category'] as String,
      price: (map['price'] as num).toDouble(),
      originalPrice: (map['originalPrice'] as num?)?.toDouble(),
      stock: map['stock'] as int,
      photoPath: map['photoPath'] as String?,
      supplierId: map['supplierId'] as int?,
      isActive: (map['isActive'] as int?) == 1,
      discountPercent: map['discountPercent'] as int?,
      rating: (map['rating'] as num?)?.toDouble(),
      reviewCount: map['reviewCount'] as int?,
      weight: (map['weight'] as num?)?.toDouble(),
      createdAt: map['createdAt'] as String?,
      updatedAt: map['updatedAt'] as String?,
    );
  }

  Product copyWith({
    int? id,
    String? name,
    String? category,
    double? price,
    double? originalPrice,
    int? stock,
    String? photoPath,
    int? supplierId,
    bool? isActive,
    int? discountPercent,
    double? rating,
    int? reviewCount,
    double? weight,
    String? createdAt,
    String? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      stock: stock ?? this.stock,
      photoPath: photoPath ?? this.photoPath,
      supplierId: supplierId ?? this.supplierId,
      isActive: isActive ?? this.isActive,
      discountPercent: discountPercent ?? this.discountPercent,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      weight: weight ?? this.weight,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now().toIso8601String(),
    );
  }
}
