class RedemptionHistory {
  final int id;
  final String type; // 'product' or 'gift'
  final String? name;
  final String? image;
  final int pointsUsed;
  final String? redeemedAt;

  RedemptionHistory({
    required this.id,
    required this.type,
    this.name,
    this.image,
    required this.pointsUsed,
    this.redeemedAt,
  });

  factory RedemptionHistory.fromJson(Map<String, dynamic> json) {
    return RedemptionHistory(
      id: json['id'] ?? 0,
      type: json['type'] ?? 'product',
      name: json['name'],
      image: json['image'],
      pointsUsed: json['points_used'] ?? 0,
      redeemedAt: json['redeemed_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'image': image,
      'points_used': pointsUsed,
      'redeemed_at': redeemedAt,
    };
  }
}