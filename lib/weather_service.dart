import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _apiKey = "6982fe919f5a80e1a66bac152935d1bc";
  static const String _baseUrl = "https://api.openweathermap.org/data/2.5/weather";

  Future<Map<String, dynamic>> getWeather(String city) async {
    final response = await http.get(Uri.parse("$_baseUrl?q=$city&appid=$_apiKey&units=metric"));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load weather data");
    }
  }
}
