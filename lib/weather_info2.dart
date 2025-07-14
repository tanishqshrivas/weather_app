import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class WeatherInfo2Page extends StatefulWidget {
  final Map<String, dynamic> weatherData;
  final String cityName;

  WeatherInfo2Page({
    required this.weatherData,
    required this.cityName,
  });

  @override
  _WeatherInfo2PageState createState() => _WeatherInfo2PageState();
}

class _WeatherInfo2PageState extends State<WeatherInfo2Page> with SingleTickerProviderStateMixin {
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


  List<Map<String, dynamic>> _generateWeeklyForecast() {
    final now = DateTime.now();
    final baseTemp = widget.weatherData['main']['temp'] as double;
    final conditions = ['Clear', 'Clouds', 'Rain', 'Clear', 'Drizzle', 'Clouds', 'Clear'];

    return List.generate(7, (index) {
      final date = now.add(Duration(days: index));
      final highTemp = (baseTemp + (index % 3 == 0 ? 2 : -1) + (index * 0.3)).round();
      final lowTemp = (highTemp - 8 - (index % 2)).round();

      return {
        'day': index == 0 ? 'Today' : DateFormat('EEEE').format(date),
        'date': DateFormat('MMM d').format(date),
        'condition': conditions[index],
        'icon': _getLottieAsset(conditions[index]),
        'highTemp': highTemp,
        'lowTemp': lowTemp,
        'precipitation': (index * 15) % 60,
        'humidity': 45 + (index * 5),
        'windSpeed': 3.5 + (index * 0.5),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final weeklyForecast = _generateWeeklyForecast();

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
                                'Weekly Forecast',
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
                      SizedBox(width: isTablet ? 48 : 40), // Balance the back button
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
                              // Weekly forecast cards
                              ...weeklyForecast.map((forecast) {
                                final isToday = forecast['day'] == 'Today';

                                return Container(
                                  width: double.infinity,
                                  margin: EdgeInsets.only(bottom: 15),
                                  padding: EdgeInsets.all(isTablet ? 25 : 20),
                                  decoration: BoxDecoration(
                                    color: isToday
                                        ? Colors.white.withOpacity(0.15)
                                        : Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isToday
                                          ? Colors.white.withOpacity(0.3)
                                          : Colors.white.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Day and date
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              forecast['day'],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: isTablet ? 18 : 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              forecast['date'],
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.7),
                                                fontSize: isTablet ? 14 : 12,
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
                                            width: isTablet ? 60 : 50,
                                            height: isTablet ? 60 : 50,
                                            child: Lottie.asset(
                                              forecast['icon'],
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Weather details
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              forecast['condition'],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: isTablet ? 16 : 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              '${forecast['precipitation']}% rain',
                                              style: TextStyle(
                                                color: Colors.blue.withOpacity(0.8),
                                                fontSize: isTablet ? 14 : 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Temperature
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${forecast['highTemp']}°',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: isTablet ? 20 : 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              '${forecast['lowTemp']}°',
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.6),
                                                fontSize: isTablet ? 16 : 14,
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

                              // Additional weather info
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
                                      'Weather Details',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isTablet ? 20 : 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 20),

                                    // Current weather details
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildDetailItem(
                                          'UV Index',
                                          '6',
                                          Icons.wb_sunny,
                                          Colors.orange,
                                          isTablet,
                                        ),
                                        _buildDetailItem(
                                          'Visibility',
                                          '10 km',
                                          Icons.visibility,
                                          Colors.blue,
                                          isTablet,
                                        ),
                                        _buildDetailItem(
                                          'Pressure',
                                          '1013 hPa',
                                          Icons.speed,
                                          Colors.green,
                                          isTablet,
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 20),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildDetailItem(
                                          'Sunrise',
                                          '06:30',
                                          Icons.wb_sunny_outlined,
                                          Colors.yellow,
                                          isTablet,
                                        ),
                                        _buildDetailItem(
                                          'Sunset',
                                          '18:45',
                                          Icons.brightness_3,
                                          Colors.purple,
                                          isTablet,
                                        ),
                                        _buildDetailItem(
                                          'Moon Phase',
                                          '🌒',
                                          Icons.brightness_2,
                                          Colors.grey,
                                          isTablet,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 30),

                              // Air quality card
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
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Air Quality Index',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isTablet ? 20 : 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(0.7),
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          child: Text(
                                            'Good',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: isTablet ? 14 : 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 15),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'AQI: 45',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isTablet ? 24 : 20,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          'PM2.5: 12 μg/m³',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.7),
                                            fontSize: isTablet ? 16 : 14,
                                          ),
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