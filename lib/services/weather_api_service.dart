import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherApiService {
  static const String _apiKey = "6982fe919f5a80e1a66bac152935d1bc";
  static const String _baseUrl = "https://api.openweathermap.org/data/2.5";

  Future<WeatherModel> getCompleteWeatherData(String city) async {
    try {
      // Get current weather
      final currentWeatherResponse = await http.get(
          Uri.parse("$_baseUrl/weather?q=$city&appid=$_apiKey&units=metric")
      );

      if (currentWeatherResponse.statusCode != 200) {
        throw Exception("Failed to load current weather data");
      }

      final currentWeatherJson = json.decode(currentWeatherResponse.body);

      // Get coordinates for AQI and UV data
      final lat = currentWeatherJson['coord']['lat'];
      final lon = currentWeatherJson['coord']['lon'];

      // Get forecast data (5 day / 3 hour forecast)
      final forecastResponse = await http.get(
          Uri.parse("$_baseUrl/forecast?q=$city&appid=$_apiKey&units=metric")
      );

      if (forecastResponse.statusCode != 200) {
        throw Exception("Failed to load forecast data");
      }

      final forecastJson = json.decode(forecastResponse.body);

      // Get Air Quality Index data
      Map<String, dynamic>? aqiJson;
      try {
        final aqiResponse = await http.get(
            Uri.parse("$_baseUrl/air_pollution?lat=$lat&lon=$lon&appid=$_apiKey")
        );
        if (aqiResponse.statusCode == 200) {
          aqiJson = json.decode(aqiResponse.body);
        }
      } catch (e) {
        print('Error fetching AQI data: $e');
      }

      // Get UV Index data
      Map<String, dynamic>? uvJson;
      try {
        final uvResponse = await http.get(
            Uri.parse("$_baseUrl/uvi?lat=$lat&lon=$lon&appid=$_apiKey")
        );
        if (uvResponse.statusCode == 200) {
          uvJson = json.decode(uvResponse.body);
        }
      } catch (e) {
        print('Error fetching UV data: $e');
      }

      return WeatherModel.fromJson(currentWeatherJson, forecastJson, aqiJson, uvJson);
    } catch (e) {
      throw Exception("Error fetching weather data: $e");
    }
  }

  Future<Map<String, dynamic>> getCurrentWeather(String city) async {
    final response = await http.get(
        Uri.parse("$_baseUrl/weather?q=$city&appid=$_apiKey&units=metric")
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load weather data");
    }
  }

  // New method to get real-time AQI data
  Future<Map<String, dynamic>?> getAirQualityData(double lat, double lon) async {
    try {
      final response = await http.get(
          Uri.parse("$_baseUrl/air_pollution?lat=$lat&lon=$lon&appid=$_apiKey")
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error fetching AQI data: $e');
    }
    return null;
  }

  // New method to get UV Index data
  Future<Map<String, dynamic>?> getUVIndexData(double lat, double lon) async {
    try {
      final response = await http.get(
          Uri.parse("$_baseUrl/uvi?lat=$lat&lon=$lon&appid=$_apiKey")
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error fetching UV data: $e');
    }
    return null;
  }
}
