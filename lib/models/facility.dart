class Facility {
  final String id;
  final String name;
  final String category;
  final int stock;
  final String? notes;
  final String? imageUrl;

  Facility({
    required this.id,
    required this.name,
    required this.category,
    required this.stock,
    this.notes,
    this.imageUrl,
  });

  factory Facility.fromMap(Map<String, dynamic> map) {
    return Facility(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      stock: map['stock'] as int,
      notes: map['notes'] as String?,
      imageUrl: map['image_url'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'stock': stock,
      'notes': notes,
      'image_url': imageUrl,
    };
  }
}
