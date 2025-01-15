import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'histori_belanja.dart'; // Ensure you import the ShoppingHistoryItem class

Future<void> saveShoppingHistory(List<ShoppingHistoryItem> history) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> historyList = history.map((item) => jsonEncode(item.toMap())).toList();
  await prefs.setStringList('shoppingHistory', historyList);
}

Future<List<ShoppingHistoryItem>> loadShoppingHistory() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? historyList = prefs.getStringList('shoppingHistory');
  if (historyList != null) {
    return historyList.map((item) => ShoppingHistoryItem.fromMap(jsonDecode(item))).toList();
  } else {
    return [];
  }
}
