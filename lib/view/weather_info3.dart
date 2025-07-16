import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../viewmodels/weather_viewmodel.dart';

class WeatherInfo3UpdatedPage extends StatefulWidget {
  final WeatherViewModel weatherViewModel;
  final String cityName;

  WeatherInfo3UpdatedPage({
    required this.weatherViewModel,
    required this.cityName,
  });

  @override
  _WeatherInfo3UpdatedPageState createState() => _WeatherInfo3UpdatedPageState();
}

class _WeatherInfo3UpdatedPageState extends State<WeatherInfo3UpdatedPage> with SingleTickerProviderStateMixin {
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

  // Helper method to get responsive dimensions
  double _getResponsiveValue(BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) return mobile;
    if (screenWidth < 1200) return tablet;
    return desktop;
  }

  // Helper method to check device type
  bool _isTablet(BuildContext context) => MediaQuery.of(context).size.width > 600;
  bool _isDesktop(BuildContext context) => MediaQuery.of(context).size.width > 1200;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = _isTablet(context);
    final isDesktop = _isDesktop(context);

    return ChangeNotifierProvider.value(
      value: widget.weatherViewModel,
      child: Consumer<WeatherViewModel>(
        builder: (context, viewModel, child) {
          final weather = viewModel.weatherData!;
          final hourlyForecast = weather.hourlyForecast;

          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.3),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        children: [
                          // Custom App Bar
                          Padding(
                            padding: EdgeInsets.all(
                              _getResponsiveValue(context, mobile: 20, tablet: 30, desktop: 40),
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    padding: EdgeInsets.all(
                                      _getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.arrow_back,
                                      color: Colors.white,
                                      size: _getResponsiveValue(context, mobile: 20, tablet: 24, desktop: 28),
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
                                            fontSize: _getResponsiveValue(context, mobile: 20, tablet: 24, desktop: 28),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          widget.cityName,
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.7),
                                            fontSize: _getResponsiveValue(context, mobile: 14, tablet: 16, desktop: 18),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: _getResponsiveValue(context, mobile: 40, tablet: 48, desktop: 56)),
                              ],
                            ),
                          ),

                          Expanded(
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: SingleChildScrollView(
                                padding: EdgeInsets.symmetric(
                                  horizontal: _getResponsiveValue(context, mobile: 20, tablet: 40, desktop: 60),
                                ),
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: isDesktop ? 800 : (isTablet ? 600 : double.infinity),
                                    ),
                                    child: Column(
                                      children: [
                                        // Current hour highlight
                                        if (hourlyForecast.isNotEmpty)
                                          Container(
                                            width: double.infinity,
                                            margin: EdgeInsets.only(bottom: 20),
                                            padding: EdgeInsets.all(
                                              _getResponsiveValue(context, mobile: 20, tablet: 25, desktop: 30),
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(25),
                                              border: Border.all(
                                                color: Colors.white.withValues(alpha: 0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: isDesktop ?
                                            // Desktop layout - horizontal
                                            Row(
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
                                                          fontSize: _getResponsiveValue(context, mobile: 18, tablet: 20, desktop: 24),
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                      SizedBox(height: 4),
                                                      Text(
                                                        DateFormat('HH:mm').format(hourlyForecast[0].time),
                                                        style: TextStyle(
                                                          color: Colors.white.withValues(alpha: 0.7),
                                                          fontSize: _getResponsiveValue(context, mobile: 14, tablet: 16, desktop: 18),
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
                                                      width: _getResponsiveValue(context, mobile: 60, tablet: 70, desktop: 90),
                                                      height: _getResponsiveValue(context, mobile: 60, tablet: 70, desktop: 90),
                                                      child: Lottie.asset(
                                                        viewModel.getWeatherAnimation(hourlyForecast[0].condition),
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
                                                        '${hourlyForecast[0].temperature.round()}°',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: _getResponsiveValue(context, mobile: 28, tablet: 32, desktop: 36),
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                      Text(
                                                        hourlyForecast[0].condition,
                                                        style: TextStyle(
                                                          color: Colors.white.withValues(alpha: 0.8),
                                                          fontSize: _getResponsiveValue(context, mobile: 14, tablet: 16, desktop: 18),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ) :
                                            // Mobile/Tablet layout - can be vertical for small screens
                                            screenWidth < 480 ?
                                            Column(
                                              children: [
                                                // Time and animation row
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'Now',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: _getResponsiveValue(context, mobile: 18, tablet: 20, desktop: 24),
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                        SizedBox(height: 4),
                                                        Text(
                                                          DateFormat('HH:mm').format(hourlyForecast[0].time),
                                                          style: TextStyle(
                                                            color: Colors.white.withValues(alpha: 0.7),
                                                            fontSize: _getResponsiveValue(context, mobile: 14, tablet: 16, desktop: 18),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      width: _getResponsiveValue(context, mobile: 60, tablet: 70, desktop: 90),
                                                      height: _getResponsiveValue(context, mobile: 60, tablet: 70, desktop: 90),
                                                      child: Lottie.asset(
                                                        viewModel.getWeatherAnimation(hourlyForecast[0].condition),
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 15),
                                                // Temperature and condition row
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          '${hourlyForecast[0].temperature.round()}°',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: _getResponsiveValue(context, mobile: 28, tablet: 32, desktop: 36),
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                        Text(
                                                          hourlyForecast[0].condition,
                                                          style: TextStyle(
                                                            color: Colors.white.withValues(alpha: 0.8),
                                                            fontSize: _getResponsiveValue(context, mobile: 14, tablet: 16, desktop: 18),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ) :
                                            // Regular horizontal layout for tablets
                                            Row(
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
                                                          fontSize: _getResponsiveValue(context, mobile: 18, tablet: 20, desktop: 24),
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                      SizedBox(height: 4),
                                                      Text(
                                                        DateFormat('HH:mm').format(hourlyForecast[0].time),
                                                        style: TextStyle(
                                                          color: Colors.white.withValues(alpha: 0.7),
                                                          fontSize: _getResponsiveValue(context, mobile: 14, tablet: 16, desktop: 18),
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
                                                      width: _getResponsiveValue(context, mobile: 60, tablet: 70, desktop: 90),
                                                      height: _getResponsiveValue(context, mobile: 60, tablet: 70, desktop: 90),
                                                      child: Lottie.asset(
                                                        viewModel.getWeatherAnimation(hourlyForecast[0].condition),
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
                                                        '${hourlyForecast[0].temperature.round()}°',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: _getResponsiveValue(context, mobile: 28, tablet: 32, desktop: 36),
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                      Text(
                                                        hourlyForecast[0].condition,
                                                        style: TextStyle(
                                                          color: Colors.white.withValues(alpha: 0.8),
                                                          fontSize: _getResponsiveValue(context, mobile: 14, tablet: 16, desktop: 18),
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
                                          return Container(
                                            width: double.infinity,
                                            margin: EdgeInsets.only(bottom: 12),
                                            padding: EdgeInsets.all(
                                              _getResponsiveValue(context, mobile: 16, tablet: 20, desktop: 24),
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(18),
                                              border: Border.all(
                                                color: Colors.white.withValues(alpha: 0.2),
                                                width: 1,
                                              ),
                                            ),
                                            child: screenWidth < 480 ?
                                            // Vertical layout for very small screens
                                            Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          DateFormat('h a').format(forecast.time),
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: _getResponsiveValue(context, mobile: 14, tablet: 16, desktop: 18),
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                        SizedBox(height: 2),
                                                        Text(
                                                          DateFormat('HH:mm').format(forecast.time),
                                                          style: TextStyle(
                                                            color: Colors.white.withValues(alpha: 0.6),
                                                            fontSize: _getResponsiveValue(context, mobile: 10, tablet: 12, desktop: 14),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      width: _getResponsiveValue(context, mobile: 35, tablet: 40, desktop: 50),
                                                      height: _getResponsiveValue(context, mobile: 35, tablet: 40, desktop: 50),
                                                      child: Lottie.asset(
                                                        viewModel.getWeatherAnimation(forecast.condition),
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 10),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          forecast.condition,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: _getResponsiveValue(context, mobile: 12, tablet: 14, desktop: 16),
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                        SizedBox(height: 2),
                                                        Text(
                                                          '${forecast.precipitation}% rain',
                                                          style: TextStyle(
                                                            color: Colors.blue.withValues(alpha: 0.8),
                                                            fontSize: _getResponsiveValue(context, mobile: 10, tablet: 12, desktop: 14),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                      children: [
                                                        Text(
                                                          '${forecast.temperature.round()}°',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: _getResponsiveValue(context, mobile: 16, tablet: 18, desktop: 20),
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                        Text(
                                                          '${forecast.feelsLike.round()}°',
                                                          style: TextStyle(
                                                            color: Colors.white.withValues(alpha: 0.6),
                                                            fontSize: _getResponsiveValue(context, mobile: 10, tablet: 12, desktop: 14),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ) :
                                            // Horizontal layout for larger screens
                                            Row(
                                              children: [
                                                // Time
                                                Expanded(
                                                  flex: 1,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        DateFormat('h a').format(forecast.time),
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: _getResponsiveValue(context, mobile: 14, tablet: 16, desktop: 18),
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                      SizedBox(height: 2),
                                                      Text(
                                                        DateFormat('HH:mm').format(forecast.time),
                                                        style: TextStyle(
                                                          color: Colors.white.withValues(alpha: 0.6),
                                                          fontSize: _getResponsiveValue(context, mobile: 10, tablet: 12, desktop: 14),
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
                                                      width: _getResponsiveValue(context, mobile: 40, tablet: 50, desktop: 60),
                                                      height: _getResponsiveValue(context, mobile: 40, tablet: 50, desktop: 60),
                                                      child: Lottie.asset(
                                                        viewModel.getWeatherAnimation(forecast.condition),
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
                                                        forecast.condition,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: _getResponsiveValue(context, mobile: 12, tablet: 14, desktop: 16),
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                      SizedBox(height: 2),
                                                      Text(
                                                        '${forecast.precipitation}% rain',
                                                        style: TextStyle(
                                                          color: Colors.blue.withValues(alpha: 0.8),
                                                          fontSize: _getResponsiveValue(context, mobile: 10, tablet: 12, desktop: 14),
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
                                                        '${forecast.temperature.round()}°',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: _getResponsiveValue(context, mobile: 16, tablet: 18, desktop: 20),
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${forecast.feelsLike.round()}°',
                                                        style: TextStyle(
                                                          color: Colors.white.withValues(alpha: 0.6),
                                                          fontSize: _getResponsiveValue(context, mobile: 10, tablet: 12, desktop: 14),
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
                                          padding: EdgeInsets.all(
                                            _getResponsiveValue(context, mobile: 20, tablet: 25, desktop: 30),
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: Colors.white.withValues(alpha: 0.2),
                                              width: 1,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Current Weather Details',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: _getResponsiveValue(context, mobile: 18, tablet: 20, desktop: 24),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(height: 20),

                                              // Weather details grid - responsive
                                              isDesktop ?
                                              // Desktop: 4 columns
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  _buildDetailItem(
                                                    'Wind Speed',
                                                    '${weather.windSpeed.toStringAsFixed(1)} km/h',
                                                    Icons.air,
                                                    Colors.blue,
                                                    context,
                                                  ),
                                                  _buildDetailItem(
                                                    'Humidity',
                                                    '${weather.humidity}%',
                                                    Icons.water_drop,
                                                    Colors.cyan,
                                                    context,
                                                  ),
                                                  _buildDetailItem(
                                                    'Pressure',
                                                    '${weather.pressure} hPa',
                                                    Icons.speed,
                                                    Colors.orange,
                                                    context,
                                                  ),
                                                  _buildAqiItem(
                                                    'Air Quality',
                                                    weather.aqi ?? 0,
                                                    Icons.air_outlined,
                                                    context,
                                                  ),
                                                ],
                                              ) :
                                              // Mobile/Tablet: 2x2 grid
                                              Column(
                                                children: [
                                                  // First row
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      _buildDetailItem(
                                                        'Wind Speed',
                                                        '${weather.windSpeed.toStringAsFixed(1)} km/h',
                                                        Icons.air,
                                                        Colors.blue,
                                                        context,
                                                      ),
                                                      _buildDetailItem(
                                                        'Humidity',
                                                        '${weather.humidity}%',
                                                        Icons.water_drop,
                                                        Colors.cyan,
                                                        context,
                                                      ),
                                                    ],
                                                  ),

                                                  SizedBox(height: 20),

                                                  // Second row
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      _buildDetailItem(
                                                        'Pressure',
                                                        '${weather.pressure} hPa',
                                                        Icons.speed,
                                                        Colors.orange,
                                                        context,
                                                      ),
                                                      _buildAqiItem(
                                                        'Air Quality',
                                                        weather.aqi ?? 0,
                                                        Icons.air_outlined,
                                                        context,
                                                      ),
                                                    ],
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
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon, Color color, BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(
            _getResponsiveValue(context, mobile: 10, tablet: 12, desktop: 16),
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: _getResponsiveValue(context, mobile: 20, tablet: 24, desktop: 28),
          ),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: _getResponsiveValue(context, mobile: 14, tablet: 16, desktop: 18),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: _getResponsiveValue(context, mobile: 10, tablet: 12, desktop: 14),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAqiItem(String label, int? aqiValue, IconData icon, BuildContext context) {
    final aqiColor = WeatherModel.getAqiColor(aqiValue);
    final aqiCategory = WeatherModel.getAqiCategory(aqiValue);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(
            _getResponsiveValue(context, mobile: 10, tablet: 12, desktop: 16),
          ),
          decoration: BoxDecoration(
            color: aqiColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: aqiColor,
            size: _getResponsiveValue(context, mobile: 20, tablet: 24, desktop: 28),
          ),
        ),
        SizedBox(height: 8),
        Text(
          '${aqiValue ?? 'N/A'}',
          style: TextStyle(
            color: Colors.white,
            fontSize: _getResponsiveValue(context, mobile: 14, tablet: 16, desktop: 18),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2),
        Text(
          aqiCategory,
          style: TextStyle(
            color: aqiColor.withValues(alpha: 0.8),
            fontSize: _getResponsiveValue(context, mobile: 8, tablet: 10, desktop: 12),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: _getResponsiveValue(context, mobile: 10, tablet: 12, desktop: 14),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}