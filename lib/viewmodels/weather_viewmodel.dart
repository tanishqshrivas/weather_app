import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_api_service.dart';

class WeatherViewModel extends ChangeNotifier {
  final WeatherApiService _weatherService = WeatherApiService();

  WeatherModel? _weatherData;
  bool _isLoading = false;
  String? _error;

  WeatherModel? get weatherData => _weatherData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchWeatherData(String city) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _weatherData = await _weatherService.getCompleteWeatherData(city);
      _error = null;

      // Log AQI data for debugging
      if (_weatherData?.airQuality != null) {
        print('AQI Data loaded: ${_weatherData!.airQuality!.aqi} - ${_weatherData!.airQuality!.aqiDescription}');
        print('Primary pollutant: ${_weatherData!.airQuality!.primaryPollutant}');
      } else {
        print('No AQI data available');
      }
    } catch (e) {
      _error = e.toString();
      _weatherData = null;
      print('Error in WeatherViewModel: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to refresh only AQI data
  Future<void> refreshAirQualityData() async {
    if (_weatherData == null) return;

    try {
      // This would require coordinates, which we can get from the current weather data
      // For now, we'll refetch all data to get updated AQI
      final cityName = _weatherData!.cityName;
      await fetchWeatherData(cityName);
    } catch (e) {
      print('Error refreshing AQI data: $e');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String getWeatherAnimation(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return 'assets/animations/sunny.json';
      case 'clouds':
        return 'assets/animations/cloudy.json';
      case 'rain':
        return 'assets/animations/rain.json';
      case 'snow':
        return 'assets/animations/snow.json';
      case 'thunderstorm':
        return 'assets/animations/thunderstorm.json';
      case 'drizzle':
        return 'assets/animations/drizzle.json';
      case 'mist':
      case 'fog':
        return 'assets/animations/fog.json';
      default:
        return 'assets/animations/cloudy.json';
    }
  }

  String getWeatherEmoji(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return '☀️';
      case 'clouds':
        return '☁️';
      case 'rain':
        return '🌧️';
      case 'snow':
        return '❄️';
      case 'thunderstorm':
        return '⛈️';
      case 'drizzle':
        return '🌦️';
      case 'mist':
      case 'fog':
        return '🌫️';
      default:
        return '🌤️';
    }
  }

  // Get AQI status message
  String getAqiStatusMessage() {
    if (_weatherData?.airQuality == null) {
      return 'Air quality data unavailable';
    }

    final aqi = _weatherData!.airQuality!;
    return '${aqi.aqiDescription} - ${aqi.healthRecommendation}';
  }
}
