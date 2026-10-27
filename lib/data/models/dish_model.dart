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

  factory DishModel.fromJson(Map<String, dynamic> json) {
    FoodType type = FoodType.veg;
    final foodTypeStr = (json['foodType'] as String?)?.toLowerCase();
    if (foodTypeStr == 'egg') type = FoodType.egg;
    if (foodTypeStr == 'nonveg' || foodTypeStr == 'non_veg') type = FoodType.nonVeg;

    return DishModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      foodType: type,
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'subtitle': subtitle,
    'price': price,
    'foodType': foodType.name,
    'isAvailable': isAvailable,
  };
}
