enum FoodType { veg, egg, nonVeg }

/// Menu dish item model.
class DishModel {
  const DishModel({
    required this.id,
    required this.name,
    required this.category,
    required this.subtitle,
    required this.price,
    required this.foodType,
    this.isAvailable = true,
  });

  final String id;
  final String name;
  final String category;
  final String subtitle;
  final double price;
  final FoodType foodType;
  final bool isAvailable;

  String get formattedPrice => '₹${price.toStringAsFixed(2)}';
}
