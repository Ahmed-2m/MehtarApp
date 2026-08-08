class Meal {
  final String id;
  final String name;
  final String category; // مثلاً: مشويات، برجر، أكل صحي، إيطالي
  final double price;
  final double rating;
  final String imageUrl;
  final String restaurantName;
  final String mood; // جو الوجبة: خفيف، ثقيل، جمعة، سريع

  Meal({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.rating,
    required this.imageUrl,
    required this.restaurantName,
    required this.mood,
  });
}
