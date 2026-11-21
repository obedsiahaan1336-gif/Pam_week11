// weather_service.dart
// Service untuk memanggil Third Party API (OpenWeatherMap).
// Alur: UI -> Service -> HTTP Client -> Internet -> Server penyedia API.

import 'dart:convert';

import 'package:http/http.dart' as http;

class WeatherService {
  // API key dibaca dari --dart-define supaya tidak ter-hardcode di source code.
  // Jalankan: flutter run --dart-define=OWM_KEY=API_KEY_ANDA
  static const _apiKey = String.fromEnvironment('OWM_KEY');

  Future<Map<String, dynamic>> fetchWeather(String city) async {
    final uri = Uri.https('api.openweathermap.org', '/data/2.5/weather', {
      'q': city,
      'appid': _apiKey,
      'units': 'metric', // suhu dalam Celsius
    });

    final res = await http.get(uri);

    // Menangani response sesuai status code.
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else if (res.statusCode == 401) {
      throw Exception('API key tidak valid (401)');
    } else if (res.statusCode == 404) {
      throw Exception('Kota tidak ditemukan (404)');
    }
    throw Exception('Gagal memuat data (${res.statusCode})');
  }
}
