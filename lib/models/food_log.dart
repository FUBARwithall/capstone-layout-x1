class FoodLog {
  final int foodId;
  final int quantity;

  FoodLog({required this.foodId, required this.quantity});

  Map<String, dynamic> toJson(int userId, String date) {
    return {
      'user_id': userId,
      'food_id': foodId,
      'quantity': quantity,
      'log_date': date,
    };
  }
}
