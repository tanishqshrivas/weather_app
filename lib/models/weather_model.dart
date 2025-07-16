import 'package:flutter/material.dart';

class WeatherModel {
  final String cityName;
  final String country;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String description;
  final String mainCondition;
  final int pressure;
  final double visibility;
  final DateTime sunrise;
  final DateTime sunset;
  final double uvIndex;
  final AirQualityData? airQuality;
  final List<HourlyWeather> hourlyForecast;
  final List<DailyWeather> dailyForecast;

  WeatherModel({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.mainCondition,
    required this.pressure,
    required this.visibility,
    required this.sunrise,
    required this.sunset,
    required this.uvIndex,
    this.airQuality,
    required this.hourlyForecast,
    required this.dailyForecast,
  });

  factory WeatherModel.fromJson(
      Map<String, dynamic> json,
      Map<String, dynamic> forecastJson,
      [Map<String, dynamic>? aqiJson, Map<String, dynamic>? uvJson]
      ) {
    return WeatherModel(
      cityName: json['name'],
      country: json['sys']['country'],
      temperature: json['main']['temp'].toDouble(),
      feelsLike: json['main']['feels_like'].toDouble(),
      humidity: (json['main']['humidity'] as num).toInt(),
      windSpeed: json['wind']['speed'].toDouble() * 3.6, // Convert m/s to km/h
      description: json['weather'][0]['description'],
      mainCondition: json['weather'][0]['main'],
      pressure: (json['main']['pressure'] as num).toInt(),
      visibility: ((json['visibility'] ?? 10000) as num).toDouble() / 1000, // Convert to km
      sunrise: DateTime.fromMillisecondsSinceEpoch(json['sys']['sunrise'] * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch(json['sys']['sunset'] * 1000),
      uvIndex: _parseUvIndex(uvJson),
      airQuality: aqiJson != null ? AirQualityData.fromJson(aqiJson) : null,
      hourlyForecast: _parseHourlyForecast(forecastJson),
      dailyForecast: _parseDailyForecast(forecastJson),
    );
  }

  // Helper method to parse UV Index from OpenWeatherMap UV API response
  static double _parseUvIndex(Map<String, dynamic>? uvJson) {
    try {
      if (uvJson != null && uvJson.containsKey('value')) {
        return (uvJson['value'] as num).toDouble();
      }
    } catch (e) {
      print('Error parsing UV Index: $e');
    }
    return 5.0; // Default UV index
  }

  static List<HourlyWeather> _parseHourlyForecast(Map<String, dynamic> forecastJson) {
    List<HourlyWeather> hourlyList = [];
    List<dynamic> list = forecastJson['list'] ?? [];

    // Take first 24 entries (8 entries per day * 3 hours = 24 hours)
    for (int i = 0; i < list.length && i < 8; i++) {
      hourlyList.add(HourlyWeather.fromJson(list[i]));
    }

    return hourlyList;
  }

  static List<DailyWeather> _parseDailyForecast(Map<String, dynamic> forecastJson) {
    List<DailyWeather> dailyList = [];
    List<dynamic> list = forecastJson['list'] ?? [];

    Map<String, List<dynamic>> groupedByDay = {};

    for (var item in list) {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
      String dayKey = '${date.year}-${date.month}-${date.day}';

      if (!groupedByDay.containsKey(dayKey)) {
        groupedByDay[dayKey] = [];
      }
      groupedByDay[dayKey]!.add(item);
    }

    groupedByDay.forEach((key, dayData) {
      if (dailyList.length < 7) {
        dailyList.add(DailyWeather.fromDayData(dayData));
      }
    });

    return dailyList;
  }

  // Convenience getter for AQI value
  int? get aqi => airQuality?.aqi;

  // Helper method to get AQI color based on AQI value
  static Color getAqiColor(int? aqi) {
    if (aqi == null) return Colors.grey;
    switch (aqi) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.lightGreen;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.orange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Helper method to get AQI category
  static String getAqiCategory(int? aqi) {
    if (aqi == null) return 'Unknown';
    switch (aqi) {
      case 1:
        return 'Good';
      case 2:
        return 'Fair';
      case 3:
        return 'Moderate';
      case 4:
        return 'Poor';
      case 5:
        return 'Very Poor';
      default:
        return 'Unknown';
    }
  }

  // Helper method to get UV Index color
  static Color getUvIndexColor(double uvIndex) {
    if (uvIndex <= 2) return Colors.green;
    if (uvIndex <= 5) return Colors.yellow;
    if (uvIndex <= 7) return Colors.orange;
    if (uvIndex <= 10) return Colors.red;
    return Colors.purple;
  }

  // Helper method to get UV Index category
  static String getUvIndexCategory(double uvIndex) {
    if (uvIndex <= 2) return 'Low';
    if (uvIndex <= 5) return 'Moderate';
    if (uvIndex <= 7) return 'High';
    if (uvIndex <= 10) return 'Very High';
    return 'Extreme';
  }
}

// New AirQualityData class for detailed air quality information
class AirQualityData {
  final int aqi;
  final double co;    // Carbon monoxide (μg/m³)
  final double no;    // Nitric oxide (μg/m³)
  final double no2;   // Nitrogen dioxide (μg/m³)
  final double o3;    // Ozone (μg/m³)
  final double so2;   // Sulphur dioxide (μg/m³)
  final double pm2_5; // Fine particles matter (μg/m³)
  final double pm10;  // Coarse particulate matter (μg/m³)
  final double nh3;   // Ammonia (μg/m³)
  final DateTime timestamp;

  AirQualityData({
    required this.aqi,
    required this.co,
    required this.no,
    required this.no2,
    required this.o3,
    required this.so2,
    required this.pm2_5,
    required this.pm10,
    required this.nh3,
    required this.timestamp,
  });

  factory AirQualityData.fromJson(Map<String, dynamic> json) {
    try {
      if (json.containsKey('list') && json['list'].isNotEmpty) {
        final data = json['list'][0];
        final components = data['components'];

        return AirQualityData(
          aqi: (data['main']['aqi'] as num).toInt(),
          co: (components['co'] as num).toDouble(),
          no: (components['no'] as num).toDouble(),
          no2: (components['no2'] as num).toDouble(),
          o3: (components['o3'] as num).toDouble(),
          so2: (components['so2'] as num).toDouble(),
          pm2_5: (components['pm2_5'] as num).toDouble(),
          pm10: (components['pm10'] as num).toDouble(),
          nh3: (components['nh3'] as num).toDouble(),
          timestamp: DateTime.fromMillisecondsSinceEpoch(data['dt'] * 1000),
        );
      }
    } catch (e) {
      print('Error parsing AQI data: $e');
    }

    // Return default values if parsing fails
    return AirQualityData(
      aqi: 0,
      co: 0,
      no: 0,
      no2: 0,
      o3: 0,
      so2: 0,
      pm2_5: 0,
      pm10: 0,
      nh3: 0,
      timestamp: DateTime.now(),
    );
  }

  // Get the most concerning pollutant
  String get primaryPollutant {
    Map<String, double> pollutants = {
      'PM2.5': pm2_5,
      'PM10': pm10,
      'NO2': no2,
      'O3': o3,
      'SO2': so2,
      'CO': co / 1000, // Convert CO to mg/m³ for comparison
    };

    return pollutants.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  // Get health recommendations based on AQI
  String get healthRecommendation {
    switch (aqi) {
      case 1:
        return 'Air quality is good. Enjoy outdoor activities!';
      case 2:
        return 'Air quality is fair. Sensitive individuals should consider reducing outdoor activities.';
      case 3:
        return 'Air quality is moderate. Limit outdoor activities if you have respiratory conditions.';
      case 4:
        return 'Air quality is poor. Everyone should limit outdoor activities.';
      case 5:
        return 'Air quality is very poor. Avoid outdoor activities.';
      default:
        return 'Air quality data unavailable.';
    }
  }

  // Get AQI description
  String get aqiDescription {
    switch (aqi) {
      case 1:
        return 'Good';
      case 2:
        return 'Fair';
      case 3:
        return 'Moderate';
      case 4:
        return 'Poor';
      case 5:
        return 'Very Poor';
      default:
        return 'Unknown';
    }
  }

  // Get AQI color
  Color get aqiColor {
    switch (aqi) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.lightGreen;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.orange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class HourlyWeather {
  final DateTime time;
  final double temperature;
  final double feelsLike;
  final String condition;
  final String description;
  final int humidity;
  final double windSpeed;
  final int precipitation;

  HourlyWeather({
    required this.time,
    required this.temperature,
    required this.feelsLike,
    required this.condition,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.precipitation,
  });

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    return HourlyWeather(
      time: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temperature: json['main']['temp'].toDouble(),
      feelsLike: json['main']['feels_like'].toDouble(),
      condition: json['weather'][0]['main'],
      description: json['weather'][0]['description'],
      humidity: (json['main']['humidity'] as num).toInt(),
      windSpeed: json['wind']['speed'].toDouble() * 3.6,
      precipitation: (((json['pop'] ?? 0.0) as num).toDouble() * 100).round(),
    );
  }
}

class DailyWeather {
  final DateTime date;
  final double highTemp;
  final double lowTemp;
  final String condition;
  final String description;
  final int humidity;
  final double windSpeed;
  final int precipitation;

  DailyWeather({
    required this.date,
    required this.highTemp,
    required this.lowTemp,
    required this.condition,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.precipitation,
  });

  factory DailyWeather.fromDayData(List<dynamic> dayData) {
    double maxTemp = double.negativeInfinity;
    double minTemp = double.infinity;
    double totalHumidity = 0;
    double totalWindSpeed = 0;
    double totalPrecipitation = 0;
    String condition = dayData[0]['weather'][0]['main'];
    String description = dayData[0]['weather'][0]['description'];
    DateTime date = DateTime.fromMillisecondsSinceEpoch(dayData[0]['dt'] * 1000);

    for (var item in dayData) {
      double temp = item['main']['temp'].toDouble();
      if (temp > maxTemp) maxTemp = temp;
      if (temp < minTemp) minTemp = temp;

      totalHumidity += (item['main']['humidity'] as num).toDouble();
      totalWindSpeed += (item['wind']['speed'] as num).toDouble();
      totalPrecipitation += ((item['pop'] ?? 0.0) as num).toDouble();
    }

    return DailyWeather(
      date: date,
      highTemp: maxTemp,
      lowTemp: minTemp,
      condition: condition,
      description: description,
      humidity: (totalHumidity / dayData.length).round(),
      windSpeed: (totalWindSpeed / dayData.length) * 3.6,
      precipitation: ((totalPrecipitation / dayData.length) * 100).round(),
    );
  }
}
