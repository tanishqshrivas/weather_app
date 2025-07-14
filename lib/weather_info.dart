import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'weather_info2.dart';
import 'weather_info3.dart';

class WeatherInfoPage extends StatefulWidget {
  final Map<String, dynamic> weatherData;
  final String cityName;
  final VoidCallback? onCityEdit;

  WeatherInfoPage({
    required this.weatherData,
    required this.cityName,
    this.onCityEdit,
  });

  @override
  _WeatherInfoPageState createState() => _WeatherInfoPageState();
}

class _WeatherInfoPageState extends State<WeatherInfoPage> with TickerProviderStateMixin {
  // Animation controllers for different elements
  late AnimationController _pageController;
  late AnimationController _weatherAnimationController;

  // Main page animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _weatherAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Main page animations
    _pageController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _weatherAnimationController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _pageController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _pageController, curve: Curves.easeOutBack));

    _weatherAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _weatherAnimationController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    _pageController.forward();
    _weatherAnimationController.repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _weatherAnimationController.dispose();
    super.dispose();
  }

  // Get weather emoji based on condition
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

  // Build Lottie weather animation
  Widget _buildWeatherAnimation(String condition, bool isTablet) {
    String animationPath = _getAnimationPath(condition);

    return Lottie.asset(
      animationPath,
      width: isTablet ? 180 : 140,
      height: isTablet ? 180 : 140,
      fit: BoxFit.contain,
      repeat: true,
      animate: true,
    );
  }

  String _getAnimationPath(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return 'assets/animations/sunny.json';
      case 'rain':
      case 'drizzle':
        return 'assets/animations/rain.json';
      case 'clouds':
        return 'assets/animations/cloudy.json';
      case 'snow':
        return 'assets/animations/snow.json';
      case 'thunderstorm':
        return 'assets/animations/thunderstorm.json';
      default:
        return 'assets/animations/cloudy.json';
    }
  }

  // Show dialog to confirm city change
  void _showCityChangeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Change City',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Go back to change your city location?',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withOpacity(0.6)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              if (widget.onCityEdit != null) {
                widget.onCityEdit!();
              }
              Navigator.pop(context); // Go back to home
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF1a1a2e),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('Change City'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    // Extract weather data
    final currentTemp = (widget.weatherData['main']['temp'] as double).round();
    final cityName = widget.weatherData['name'];
    final country = widget.weatherData['sys']['country'];
    final weatherDescription = widget.weatherData['weather'][0]['description'];
    final mainWeatherCondition = widget.weatherData['weather'][0]['main'];
    final feelsLikeTemp = (widget.weatherData['main']['feels_like'] as double).round();
    final humidityPercent = widget.weatherData['main']['humidity'];
    final windSpeedKmh = (widget.weatherData['wind']['speed'] * 3.6); // Convert m/s to km/h

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
                // Custom navigation bar
                _buildNavigationBar(isTablet),

                // Main content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 40 : 16,
                    ),
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 600),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Main weather information card
                              _buildMainWeatherCard(
                                isTablet,
                                currentTemp,
                                cityName,
                                country,
                                weatherDescription,
                                mainWeatherCondition,
                                feelsLikeTemp,
                                humidityPercent,
                                windSpeedKmh,
                              ),

                              SizedBox(height: 30),

                              // Hourly forecast navigation button
                              _buildHourlyForecastButton(isTablet),

                              SizedBox(height: 20),

                              // Weekly forecast navigation button
                              _buildWeeklyForecastButton(isTablet),

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

  // Build custom navigation bar
  Widget _buildNavigationBar(bool isTablet) {
    return Padding(
      padding: EdgeInsets.all(isTablet ? 30 : 20),
      child: Row(
        children: [
          // Back button
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

          // Title
          Expanded(
            child: Center(
              child: Text(
                'Aurora',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Edit location button
          GestureDetector(
            onTap: _showCityChangeDialog,
            child: Container(
              padding: EdgeInsets.all(isTablet ? 12 : 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.edit_location,
                color: Colors.white,
                size: isTablet ? 24 : 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build main weather information card
  Widget _buildMainWeatherCard(
      bool isTablet,
      int currentTemp,
      String cityName,
      String country,
      String weatherDescription,
      String mainWeatherCondition,
      int feelsLikeTemp,
      int humidityPercent,
      double windSpeedKmh,
      ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 40 : 30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Location and current date
          Text(
            '$cityName, $country',
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 28 : 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 5),
          Text(
            DateFormat('EEEE, MMMM d').format(DateTime.now()),
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: isTablet ? 18 : 16,
            ),
          ),

          SizedBox(height: 30),

          // Animated weather icon
          _buildWeatherAnimation(mainWeatherCondition, isTablet),

          SizedBox(height: 20),

          // Temperature and description
          Text(
            '${currentTemp}°C',
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 64 : 56,
              fontWeight: FontWeight.w300,
            ),
          ),
          SizedBox(height: 10),
          Text(
            weatherDescription.split(' ').map((word) =>
            word[0].toUpperCase() + word.substring(1)).join(' '),
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.w400,
            ),
          ),

          SizedBox(height: 30),

          // Additional weather details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildWeatherDetail(
                'Feels Like',
                '${feelsLikeTemp}°C',
                Icons.thermostat,
                Colors.orange,
                isTablet,
              ),
              _buildWeatherDetail(
                'Humidity',
                '${humidityPercent}%',
                Icons.water_drop,
                Colors.blue,
                isTablet,
              ),
              _buildWeatherDetail(
                'Wind Speed',
                '${windSpeedKmh.toStringAsFixed(1)} km/h',
                Icons.air,
                Colors.green,
                isTablet,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build weather detail item
  Widget _buildWeatherDetail(String label, String value, IconData icon, Color color, bool isTablet) {
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

  // Build hourly forecast button
  Widget _buildHourlyForecastButton(bool isTablet) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WeatherInfo3Page(
              weatherData: widget.weatherData,
              cityName: widget.cityName,
            ),
          ),
        );
      },
      child: Container(
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
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? 12 : 10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.access_time,
                color: Colors.blue,
                size: isTablet ? 24 : 20,
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hourly Forecast',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '24-hour weather forecast',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: isTablet ? 14 : 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.6),
              size: isTablet ? 20 : 16,
            ),
          ],
        ),
      ),
    );
  }

  // Build weekly forecast button
  Widget _buildWeeklyForecastButton(bool isTablet) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WeatherInfo2Page(
              weatherData: widget.weatherData,
              cityName: widget.cityName,
            ),
          ),
        );
      },
      child: Container(
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
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? 12 : 10),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.calendar_view_week,
                color: Colors.purple,
                size: isTablet ? 24 : 20,
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Forecast',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '7-day weather forecast',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: isTablet ? 14 : 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.6),
              size: isTablet ? 20 : 16,
            ),
          ],
        ),
      ),
    );
  }
}