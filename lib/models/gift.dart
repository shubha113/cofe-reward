class Gift {
  final int id;
  final String name;
  final double? price;
  final String? photo;
  final bool isActive;

  Gift({
    required this.id,
    required this.name,
    this.price,
    this.photo,
    required this.isActive,
  });

  factory Gift.fromJson(Map<String, dynamic> json) {
    return Gift(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : null,
      photo: json['photo'],
      isActive: json['is_active'] == 1 || json['is_active'] == true, // Fix: Handle both int and bool
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'photo': photo,
      'is_active': isActive,
    };
  }
}