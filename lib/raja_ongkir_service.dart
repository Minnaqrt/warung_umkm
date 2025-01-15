import 'dart:convert';
import 'package:http/http.dart' as http;
import './model/model_kota.dart';

class RajaOngkirService {
  final String apiKey = 'fd234fab7ac889c6a12de13ca6a3c857';

  Future<List<ModelKota>> getProvinces() async {
    final response = await http.get(
      Uri.parse('https://api.rajaongkir.com/starter/province'),
      headers: {'key': apiKey},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['rajaongkir']['results'];
      return ModelKota.fromJsonList(data);
    } else {
      throw Exception('Failed to load provinces');
    }
  }

  Future<List<ModelKota>> getCities(int provinceId) async {
    final response = await http.get(
      Uri.parse('https://api.rajaongkir.com/starter/city?province=$provinceId'),
      headers: {'key': apiKey},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['rajaongkir']['results'];
      return ModelKota.fromJsonList(data);
    } else {
      throw Exception('Failed to load cities');
    }
  }

  Future<List<ModelKota>> getAllCities() async {
    final response = await http.get(
      Uri.parse('https://api.rajaongkir.com/starter/city'),
      headers: {'key': apiKey},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['rajaongkir']['results'];
      return ModelKota.fromJsonList(data);
    } else {
      throw Exception('Failed to load cities');
    }
  }

  Future<int> calculateShippingCost({
    required String originCityId,
    required int destinationCityId,
    required int weight,
    required String courier,
  }) async {
    // Convert the courier value to lowercase
    courier = courier.toLowerCase();

    final response = await http.post(
      Uri.parse('https://api.rajaongkir.com/starter/cost'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'key': apiKey,
      },
      body: {
        'origin': originCityId,
        'destination': destinationCityId.toString(),
        'weight': weight.toString(),
        'courier': courier,
      },
    );

    print("Request body: ${{
      'origin': originCityId,
      'destination': destinationCityId.toString(),
      'weight': weight.toString(),
      'courier': courier,
    }}");

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Data received: ${data['rajaongkir']}");
      if (data['rajaongkir']['results'].isNotEmpty &&
          data['rajaongkir']['results'][0]['costs'].isNotEmpty &&
          data['rajaongkir']['results'][0]['costs'][0]['cost'].isNotEmpty) {
        return data['rajaongkir']['results'][0]['costs'][0]['cost'][0]['value'];
      } else {
        print('Error: No cost data available');
        return 0;
      }
    } else {
      print('Error response: ${response.body}');
      return 0;
    }
  }
}
