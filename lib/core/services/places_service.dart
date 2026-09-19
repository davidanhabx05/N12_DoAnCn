import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PlacesService {
  static final PlacesService _instance = PlacesService._internal();
  factory PlacesService() => _instance;
  PlacesService._internal();

  Future<List<String>> searchNearbyRestaurants(String query) async {
    try {
      final apiKey = dotenv.env['GOOGLE_PLACES_API_KEY'] ?? dotenv.env['GEMINI_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        return ['Nhà hàng Chay An Phúc', 'Quán Ăn Healthy Green', 'Bếp Nhà Mình Restaurant'];
      }

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&key=$apiKey',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List?;
        if (results != null) {
          return results.map((place) => place['name'].toString()).toList();
        }
      }
      return ['Nhà hàng Chay An Phúc', 'Quán Ăn Healthy Green', 'Bếp Nhà Mình Restaurant'];
    } catch (e) {
      return ['Nhà hàng Chay An Phúc', 'Quán Ăn Healthy Green', 'Bếp Nhà Mình Restaurant'];
    }
  }
}
