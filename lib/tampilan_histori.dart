import 'package:flutter/material.dart';

import 'histori_belanja.dart';

class ShoppingHistoryScreen extends StatelessWidget {
  final List<ShoppingHistoryItem> history;

  const ShoppingHistoryScreen({Key? key, required this.history}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping History'),
      ),
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          final item = history[index];
          return ListTile(
            title: Text(item.itemName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quantity: ${item.quantity}'),
                Text('Shipping Cost: Rp ${item.shippingCost}'),
                Text('Total Price: Rp ${item.totalPrice}'),
                Text('Date: ${item.date}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
