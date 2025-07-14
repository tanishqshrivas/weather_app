import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class WeatherInfo3Page extends StatefulWidget {
  final Map<String, dynamic> weatherData;
  final String cityName;

  WeatherInfo3Page({
    required this.weatherData,
    required this.cityName,
  });

  @override
  _WeatherInfo3PageState createState() => _WeatherInfo3PageState();
}

class _WeatherInfo3PageState extends State<WeatherInfo3Page> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getLottieAsset(String condition) {
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
        return 'assets/animations/partly_cloudy.json';
    }
  }

  String _getWeatherEmoji(String condition) {
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

  List<Map<String, dynamic>> _generateHourlyForecast() {
    final now = DateTime.now();
    final baseTemp = widget.weatherData['main']['temp'] as double;
    final conditions = ['Clear', 'Clouds', 'Rain', 'Clear', 'Drizzle', 'Clouds', 'Clear', 'Thunderstorm', 'Mist', 'Clear', 'Clouds', 'Rain'];
    final mainCondition = widget.weatherData['weather'][0]['main'];

    return List.generate(24, (index) {
      final forecastTime = now.add(Duration(hours: index));
      final tempVariation = (index % 3 == 0 ? -2 : 1) + (index * 0.2) - (index > 12 ? 3 : 0);
      final temperature = (baseTemp + tempVariation).round();
      final condition = index < 3 ? mainCondition : conditions[index % conditions.length];

      return {
        'time': DateFormat('h a').format(forecastTime),
        'fullTime': DateFormat('HH:mm').format(forecastTime),
        'temperature': temperature,
        'condition': condition,
        'emoji': _getWeatherEmoji(condition),
        'icon': _getLottieAsset(condition),
        'precipitation': (index * 8) % 70,
        'humidity': 40 + (index * 3) % 40,
        'windSpeed': 2.5 + (index * 0.3) % 8,
        'feelsLike': temperature + (index % 2 == 0 ? 2 : -1),
        'uvIndex': index >= 6 && index <= 18 ? ((index - 6) * 0.8).round() : 0,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final hourlyForecast = _generateHourlyForecast();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: EdgeInsets.all(isTablet ? 30 : 20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(isTablet ? 12 : 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: isTablet ? 24 : 20,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                'Hourly Forecast',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isTablet ? 24 : 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                widget.cityName,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: isTablet ? 16 : 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: isTablet ? 48 : 40),
                    ],
                  ),
                ),

                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 40 : 20,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 600),
                          child: Column(
                            children: [
                              // Current hour highlight
                              Container(
                                width: double.infinity,
                                margin: EdgeInsets.only(bottom: 20),
                                padding: EdgeInsets.all(isTablet ? 30 : 25),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Current time and temperature
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Now',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: isTablet ? 20 : 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            hourlyForecast[0]['fullTime'],
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.7),
                                              fontSize: isTablet ? 16 : 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Weather animation
                                    Expanded(
                                      flex: 1,
                                      child: Center(
                                        child: SizedBox(
                                          width: isTablet ? 80 : 70,
                                          height: isTablet ? 80 : 70,
                                          child: Lottie.asset(
                                            hourlyForecast[0]['icon'],
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Temperature and details
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${hourlyForecast[0]['temperature']}°',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: isTablet ? 32 : 28,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            hourlyForecast[0]['condition'],
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.8),
                                              fontSize: isTablet ? 16 : 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Hourly forecast list
                              ...hourlyForecast.skip(1).map((forecast) {
                                final index = hourlyForecast.indexOf(forecast);

                                return Container(
                                  width: double.infinity,
                                  margin: EdgeInsets.only(bottom: 12),
                                  padding: EdgeInsets.all(isTablet ? 20 : 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Time
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              forecast['time'],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: isTablet ? 16 : 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              forecast['fullTime'],
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.6),
                                                fontSize: isTablet ? 12 : 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Weather icon
                                      Expanded(
                                        flex: 1,
                                        child: Center(
                                          child: SizedBox(
                                            width: isTablet ? 50 : 40,
                                            height: isTablet ? 50 : 40,
                                            child: Lottie.asset(
                                              forecast['icon'],
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Weather condition and precipitation
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              forecast['condition'],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: isTablet ? 14 : 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              '${forecast['precipitation']}% rain',
                                              style: TextStyle(
                                                color: Colors.blue.withOpacity(0.8),
                                                fontSize: isTablet ? 12 : 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Temperature and feels like
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${forecast['temperature']}°',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: isTablet ? 18 : 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              '${forecast['feelsLike']}°',
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.6),
                                                fontSize: isTablet ? 12 : 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),

                              SizedBox(height: 30),

                              // Additional hourly details
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(isTablet ? 25 : 20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Hourly Details',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isTablet ? 20 : 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 20),

                                    // Detail items
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildDetailItem(
                                          'Wind Speed',
                                          '${hourlyForecast[0]['windSpeed'].toStringAsFixed(1)} km/h',
                                          Icons.air,
                                          Colors.blue,
                                          isTablet,
                                        ),
                                        _buildDetailItem(
                                          'Humidity',
                                          '${hourlyForecast[0]['humidity']}%',
                                          Icons.water_drop,
                                          Colors.cyan,
                                          isTablet,
                                        ),
                                        _buildDetailItem(
                                          'UV Index',
                                          '${hourlyForecast[0]['uvIndex']}',
                                          Icons.wb_sunny,
                                          Colors.orange,
                                          isTablet,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon, Color color, bool isTablet) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isTablet ? 12 : 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: isTablet ? 24 : 20,
          ),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: isTablet ? 16 : 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: isTablet ? 12 : 10,
          ),
        ),
      ],
    );
  }
}