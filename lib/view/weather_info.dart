import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'weather_info2.dart';
import 'weather_info3.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'aqi_details_widget.dart';

class WeatherInfoPage extends StatefulWidget {
  final WeatherViewModel weatherViewModel;
  final String cityName;
  final VoidCallback? onCityEdit;

  WeatherInfoPage({
    required this.weatherViewModel,
    required this.cityName,
    this.onCityEdit,
  });

  @override
  _WeatherInfoPageState createState() => _WeatherInfoPageState();
}

class _WeatherInfoPageState extends State<WeatherInfoPage> with TickerProviderStateMixin {
  late AnimationController _pageController;
  late AnimationController _weatherAnimationController;
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

  Widget _buildWeatherAnimation(String condition, bool isTablet, bool isDesktop) {
    String animationPath = widget.weatherViewModel.getWeatherAnimation(condition);

    // More responsive animation sizing
    double animationSize = isDesktop ? 200 : (isTablet ? 160 : 120);

    return Lottie.asset(
      animationPath,
      width: animationSize,
      height: animationSize,
      fit: BoxFit.contain,
      repeat: true,
      animate: true,
    );
  }

  void _showCityChangeDialog() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;
    final isDesktop = screenWidth > 1024;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Change City',
          style: TextStyle(
            color: Colors.white,
            fontSize: isDesktop ? 22 : (isTablet ? 20 : 18),
          ),
        ),
        content: Text(
          'Go back to change your city location?',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (widget.onCityEdit != null) {
                widget.onCityEdit!();
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF1a1a2e),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 24 : (isTablet ? 20 : 16),
                vertical: isDesktop ? 12 : (isTablet ? 10 : 8),
              ),
            ),
            child: Text(
              'Change City',
              style: TextStyle(
                fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 768;
    final isDesktop = screenWidth > 1024;
    final isLandscape = screenWidth > screenHeight;

    // Enhanced responsive values
    final horizontalPadding = isDesktop ? 60.0 : (isTablet ? 40.0 : 16.0);
    final maxContentWidth = isDesktop ? 900.0 : (isTablet ? 700.0 : double.infinity);
    final verticalSpacing = isDesktop ? 30.0 : (isTablet ? 25.0 : 20.0);

    return ChangeNotifierProvider.value(
      value: widget.weatherViewModel,
      child: Consumer<WeatherViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
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
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: isDesktop ? 4 : (isTablet ? 3 : 2),
                  ),
                ),
              ),
            );
          }

          if (viewModel.error != null) {
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
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: isDesktop ? 80 : (isTablet ? 72 : 64),
                      ),
                      SizedBox(height: isDesktop ? 20 : (isTablet ? 18 : 16)),
                      Text(
                        'Error loading weather data',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isDesktop ? 22 : (isTablet ? 20 : 18),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: isDesktop ? 12 : (isTablet ? 10 : 8)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Text(
                          viewModel.error!,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: isDesktop ? 28 : (isTablet ? 26 : 24)),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 32 : (isTablet ? 28 : 24),
                            vertical: isDesktop ? 16 : (isTablet ? 14 : 12),
                          ),
                        ),
                        child: Text(
                          'Go Back',
                          style: TextStyle(
                            fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final weather = viewModel.weatherData!;

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
                  child: Column(
                    children: [
                      _buildNavigationBar(isTablet, isDesktop),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Center(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: maxContentWidth),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildMainWeatherCard(isTablet, isDesktop, weather, isLandscape),
                                    SizedBox(height: verticalSpacing),
                                    _buildHourlyForecastButton(isTablet, isDesktop),
                                    SizedBox(height: verticalSpacing * 0.7),
                                    _buildWeeklyForecastButton(isTablet, isDesktop),
                                    SizedBox(height: verticalSpacing * 0.7),
                                    // Add AQI Details Widget
                                    AqiDetailsWidget(
                                      airQuality: weather.airQuality,
                                      isTablet: isTablet,
                                    ),
                                    SizedBox(height: verticalSpacing),
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
        },
      ),
    );
  }

  Widget _buildNavigationBar(bool isTablet, bool isDesktop) {
    return Padding(
      padding: EdgeInsets.all(isDesktop ? 40 : (isTablet ? 30 : 20)),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(isDesktop ? 14 : (isTablet ? 12 : 10)),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(isDesktop ? 16 : (isTablet ? 14 : 12)),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: isDesktop ? 26 : (isTablet ? 24 : 22),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Aurora',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isDesktop ? 30 : (isTablet ? 26 : 22),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: _showCityChangeDialog,
            child: Container(
              padding: EdgeInsets.all(isDesktop ? 14 : (isTablet ? 12 : 10)),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(isDesktop ? 16 : (isTablet ? 14 : 12)),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.edit_location,
                color: Colors.white,
                size: isDesktop ? 26 : (isTablet ? 24 : 22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainWeatherCard(bool isTablet, bool isDesktop, weather, bool isLandscape) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 45 : (isTablet ? 35 : 25)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(isDesktop ? 35 : (isTablet ? 30 : 25)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '${weather.cityName}, ${weather.country}',
            style: TextStyle(
              color: Colors.white,
              fontSize: isDesktop ? 32 : (isTablet ? 28 : 24),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isDesktop ? 8 : (isTablet ? 6 : 5)),
          Text(
            DateFormat('EEEE, MMMM d').format(DateTime.now()),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: isDesktop ? 40 : (isTablet ? 35 : 30)),
          _buildWeatherAnimation(weather.mainCondition, isTablet, isDesktop),
          SizedBox(height: isDesktop ? 25 : (isTablet ? 20 : 15)),
          Text(
            '${weather.temperature.round()}°C',
            style: TextStyle(
              color: Colors.white,
              fontSize: isDesktop ? 72 : (isTablet ? 64 : 56),
              fontWeight: FontWeight.w200,
              height: 1.0,
            ),
          ),
          SizedBox(height: isDesktop ? 15 : (isTablet ? 12 : 10)),
          Text(
            weather.description.split(' ').map((word) =>
            word[0].toUpperCase() + word.substring(1)).join(' '),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: isDesktop ? 22 : (isTablet ? 20 : 18),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isDesktop ? 40 : (isTablet ? 35 : 30)),
          // Make weather details responsive for different screen sizes
          isLandscape && !isDesktop
              ? _buildWeatherDetailsRow(weather, isTablet, isDesktop)
              : _buildWeatherDetailsColumn(weather, isTablet, isDesktop),
        ],
      ),
    );
  }

  Widget _buildWeatherDetailsRow(weather, bool isTablet, bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildWeatherDetail(
          'Feels Like',
          '${weather.feelsLike.round()}°C',
          Icons.thermostat,
          Colors.orange,
          isTablet,
          isDesktop,
        ),
        _buildWeatherDetail(
          'Humidity',
          '${weather.humidity}%',
          Icons.water_drop,
          Colors.blue,
          isTablet,
          isDesktop,
        ),
        _buildWeatherDetail(
          'Wind Speed',
          '${weather.windSpeed.toStringAsFixed(1)} km/h',
          Icons.air,
          Colors.green,
          isTablet,
          isDesktop,
        ),
      ],
    );
  }

  Widget _buildWeatherDetailsColumn(weather, bool isTablet, bool isDesktop) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildWeatherDetail(
              'Feels Like',
              '${weather.feelsLike.round()}°C',
              Icons.thermostat,
              Colors.orange,
              isTablet,
              isDesktop,
            ),
            _buildWeatherDetail(
              'Humidity',
              '${weather.humidity}%',
              Icons.water_drop,
              Colors.blue,
              isTablet,
              isDesktop,
            ),
          ],
        ),
        SizedBox(height: isDesktop ? 20 : (isTablet ? 15 : 10)),
        _buildWeatherDetail(
          'Wind Speed',
          '${weather.windSpeed.toStringAsFixed(1)} km/h',
          Icons.air,
          Colors.green,
          isTablet,
          isDesktop,
        ),
      ],
    );
  }

  Widget _buildWeatherDetail(String label, String value, IconData icon, Color color, bool isTablet, bool isDesktop) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isDesktop ? 16 : (isTablet ? 14 : 12)),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(isDesktop ? 16 : (isTablet ? 14 : 12)),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: isDesktop ? 28 : (isTablet ? 24 : 20),
          ),
        ),
        SizedBox(height: isDesktop ? 10 : (isTablet ? 8 : 6)),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: isDesktop ? 6 : (isTablet ? 4 : 3)),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.65),
            fontSize: isDesktop ? 14 : (isTablet ? 12 : 10),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyForecastButton(bool isTablet, bool isDesktop) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WeatherInfo3UpdatedPage(
              weatherViewModel: widget.weatherViewModel,
              cityName: widget.cityName,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isDesktop ? 28 : (isTablet ? 24 : 20)),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(isDesktop ? 24 : (isTablet ? 20 : 18)),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isDesktop ? 16 : (isTablet ? 14 : 12)),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(isDesktop ? 16 : (isTablet ? 14 : 12)),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.access_time,
                color: Colors.blue,
                size: isDesktop ? 28 : (isTablet ? 24 : 20),
              ),
            ),
            SizedBox(width: isDesktop ? 20 : (isTablet ? 18 : 15)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hourly Forecast',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: isDesktop ? 6 : (isTablet ? 5 : 4)),
                  Text(
                    'Real-time hourly weather forecast',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: isDesktop ? 16 : (isTablet ? 14 : 12),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withValues(alpha: 0.6),
              size: isDesktop ? 22 : (isTablet ? 20 : 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyForecastButton(bool isTablet, bool isDesktop) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WeatherInfo2UpdatedPage(
              weatherViewModel: widget.weatherViewModel,
              cityName: widget.cityName,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isDesktop ? 28 : (isTablet ? 24 : 20)),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(isDesktop ? 24 : (isTablet ? 20 : 18)),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isDesktop ? 16 : (isTablet ? 14 : 12)),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(isDesktop ? 16 : (isTablet ? 14 : 12)),
                border: Border.all(
                  color: Colors.purple.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.calendar_view_week,
                color: Colors.purple,
                size: isDesktop ? 28 : (isTablet ? 24 : 20),
              ),
            ),
            SizedBox(width: isDesktop ? 20 : (isTablet ? 18 : 15)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Forecast',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: isDesktop ? 6 : (isTablet ? 5 : 4)),
                  Text(
                    'Real-time 7-day weather forecast',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: isDesktop ? 16 : (isTablet ? 14 : 12),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withValues(alpha: 0.6),
              size: isDesktop ? 22 : (isTablet ? 20 : 18),
            ),
          ],
        ),
      ),
    );
  }
}