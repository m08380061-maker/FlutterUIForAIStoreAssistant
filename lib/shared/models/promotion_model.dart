class PromotionModel {
  final String id;
  final String title;
  final String discount;
  final bool isActive;
  final DateTime expiresAt;
  final DateTime createdAt;

  const PromotionModel({
    required this.id,
    required this.title,
    required this.discount,
    required this.isActive,
    required this.expiresAt,
    required this.createdAt,
  });
}
