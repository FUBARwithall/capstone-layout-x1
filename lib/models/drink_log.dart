class DrinkLog {
  final String drinkType; // WATER | SWEET
  final double quantity;
  final double sugar;

  DrinkLog({required this.drinkType, required this.quantity, this.sugar = 0});

  Map<String, dynamic> toJson(int userId, String date) {
    return {
      'user_id': userId,
      'log_date': date,
      'drink_type': drinkType,
      'quantity': quantity,
      'sugar': sugar,
    };
  }
}
