import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_keys.dart';

class BreedInfo {
  final String name;
  final String temperament;
  final String lifeSpan;
  final String origin;

  const BreedInfo({
    required this.name,
    this.temperament = '',
    this.lifeSpan = '',
    this.origin = '',
  });
}

class BreedService {
  static Future<List<BreedInfo>> fetchBreeds(String petType) async {
    try {
      if (petType == 'Dog') {
        return _fetch('https://api.thedogapi.com/v1/breeds', kDogApiKey);
      }
      if (petType == 'Cat') {
        return _fetch('https://api.thecatapi.com/v1/breeds', kCatApiKey);
      }
    } catch (_) {}
    return [];
  }

  static Future<List<BreedInfo>> _fetch(String url, String apiKey) async {
    final res = await http.get(
      Uri.parse(url),
      headers: {'x-api-key': apiKey},
    );
    if (res.statusCode != 200) return [];
    final List data = jsonDecode(res.body);
    return data
        .map((b) => BreedInfo(
              name: (b['name'] ?? '').toString(),
              temperament: (b['temperament'] ?? '').toString(),
              lifeSpan: (b['life_span'] ?? '').toString(),
              origin: (b['origin'] ?? '').toString(),
            ))
        .where((b) => b.name.isNotEmpty)
        .toList();
  }
}
