class Redeemable {
  final int id;
  final String type; // 'product' or 'gift'
  final String? name;
  final String? image;
  final int pointsRequired;
  final int userPoints;
  final bool canRedeem;

  Redeemable({
    required this.id,
    required this.type,
    this.name,
    this.image,
    required this.pointsRequired,
    required this.userPoints,
    required this.canRedeem,
  });

  factory Redeemable.fromJson(Map<String, dynamic> json) {
    return Redeemable(
      id: json['id'] ?? 0,
      type: json['type'] ?? 'product',
      name: json['name'],
      image: json['image'],
      pointsRequired: json['points_required'] ?? 0,
      userPoints: json['user_points'] ?? 0,
      canRedeem: json['can_redeem'] == true || json['can_redeem'] == 1,
    );
  }

  String get displayName => name ?? 'Unknown Item';

  String? get displayImage => image;
}