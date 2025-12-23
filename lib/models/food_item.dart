class FoodItem {
  final int id;
  final String name;

  FoodItem({required this.id, required this.name});

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(id: json['id'], name: json['name']);
  }
}
