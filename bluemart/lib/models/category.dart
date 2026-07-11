class ProductCategory {
  final int? id;
  final String name;
  final String iconName;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  ProductCategory({
    this.id,
    required this.name,
    this.iconName = 'laptop',
    this.isActive = true,
    String? createdAt,
    String? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String(),
       updatedAt = updatedAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'iconName': iconName,
    'isActive': isActive ? 1 : 0,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  factory ProductCategory.fromMap(Map<String, dynamic> map) {
    return ProductCategory(
      id: map['id'] as int?,
      name: map['name'] as String,
      iconName: (map['iconName'] as String?) ?? 'laptop',
      isActive: (map['isActive'] as int?) == 1,
      createdAt: map['createdAt'] as String?,
      updatedAt: map['updatedAt'] as String?,
    );
  }

  ProductCategory copyWith({
    int? id,
    String? name,
    String? iconName,
    bool? isActive,
  }) {
    return ProductCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now().toIso8601String(),
    );
  }
}
