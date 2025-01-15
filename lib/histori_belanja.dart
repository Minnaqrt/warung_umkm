class ShoppingHistoryItem {
  final String itemName;
  final int quantity;
  final double price;
  final DateTime date;
  final double shippingCost;
  final double totalPrice;

  ShoppingHistoryItem({
    required this.itemName,
    required this.quantity,
    required this.price,
    required this.date,
    required this.shippingCost,
    required this.totalPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'itemName': itemName,
      'quantity': quantity,
      'price': price,
      'date': date.toIso8601String(),
      'shippingCost': shippingCost,
      'totalPrice': totalPrice,
    };
  }

  factory ShoppingHistoryItem.fromMap(Map<String, dynamic> map) {
    return ShoppingHistoryItem(
      itemName: map['itemName'],
      quantity: map['quantity'],
      price: map['price'],
      date: DateTime.parse(map['date']),
      shippingCost: map['shippingCost'],
      totalPrice: map['totalPrice'],
    );
  }
}
