import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../viewmodels/weather_viewmodel.dart';

class WeatherInfo2UpdatedPage extends StatefulWidget {
  final WeatherViewModel weatherViewModel;
  final String cityName;

  WeatherInfo2UpdatedPage({
    required this.weatherViewModel,
    required this.cityName,
  });

  @override
  _WeatherInfo2UpdatedPageState createState() => _WeatherInfo2UpdatedPageState();
}

class _WeatherInfo2UpdatedPageState extends State<WeatherInfo2UpdatedPage> with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isLargeTablet = screenWidth > 900;
    final isDesktop = screenWidth > 1200;

    // Responsive sizing
    final horizontalPadding = isDesktop ? 60.0 : (isLargeTablet ? 50.0 : (isTablet ? 40.0 : 20.0));
    final cardPadding = isDesktop ? 30.0 : (isLargeTablet ? 28.0 : (isTablet ? 25.0 : 20.0));
    final maxWidth = isDesktop ? 800.0 : (isLargeTablet ? 700.0 : 600.0);

    return ChangeNotifierProvider.value(
      value: widget.weatherViewModel,
      child: Consumer<WeatherViewModel>(
        builder: (context, viewModel, child) {
          final weather = viewModel.weatherData!;
          final dailyForecast = weather.dailyForecast;

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
                      // Custom App Bar
                      Padding(
                        padding: EdgeInsets.all(horizontalPadding),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: EdgeInsets.all(isDesktop ? 14 : (isTablet ? 12 : 8)),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: isDesktop ? 26 : (isTablet ? 24 : 20),
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
                                        fontSize: isDesktop ? 28 : (isTablet ? 24 : 20),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      widget.cityName,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.7),
                                        fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: isDesktop ? 54 : (isTablet ? 48 : 40)),
                          ],
                        ),
                      ),

                      Expanded(
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: maxWidth),
                                child: Column(
                                  children: [
                                    // Weekly forecast cards
                                    ...dailyForecast.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final forecast = entry.value;
                                      final isToday = index == 0;

                                      return Container(
                                        width: double.infinity,
                                        margin: EdgeInsets.only(bottom: isDesktop ? 20 : 15),
                                        padding: EdgeInsets.all(cardPadding),
                                        decoration: BoxDecoration(
                                          color: isToday
                                              ? Colors.white.withValues(alpha: 0.15)
                                              : Colors.white.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: isToday
                                                ? Colors.white.withValues(alpha: 0.3)
                                                : Colors.white.withValues(alpha: 0.2),
                                            width: 1,
                                          ),
                                        ),
                                        child: _buildForecastCard(forecast, isToday, isDesktop, isTablet),
                                      );
                                    }).toList(),

                                    SizedBox(height: isDesktop ? 40 : 30),

                                    // Additional weather info
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(cardPadding),
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
                                            'Weather Details',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: isDesktop ? 24 : (isTablet ? 20 : 18),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(height: isDesktop ? 25 : 20),

                                          _buildWeatherDetailsGrid(weather, isDesktop, isTablet),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: isDesktop ? 30 : 20),
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

  Widget _buildForecastCard(dynamic forecast, bool isToday, bool isDesktop, bool isTablet) {
    if (isDesktop) {
      return Row(
        children: [
          // Day and date
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isToday ? 'Today' : DateFormat('EEEE').format(forecast.date),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  DateFormat('MMM d').format(forecast.date),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 16,
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
                width: 70,
                height: 70,
                child: Lottie.asset(
                  widget.weatherViewModel.getWeatherAnimation(forecast.condition),
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
                  forecast.condition,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '${forecast.precipitation}% rain',
                  style: TextStyle(
                    color: Colors.blue.withValues(alpha: 0.8),
                    fontSize: 16,
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
                  '${forecast.highTemp.round()}°',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${forecast.lowTemp.round()}°',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          // Day and date
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isToday ? 'Today' : DateFormat('EEEE').format(forecast.date),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  DateFormat('MMM d').format(forecast.date),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
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
                  widget.weatherViewModel.getWeatherAnimation(forecast.condition),
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
                  forecast.condition,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${forecast.precipitation}% rain',
                  style: TextStyle(
                    color: Colors.blue.withValues(alpha: 0.8),
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
                  '${forecast.highTemp.round()}°',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 20 : 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${forecast.lowTemp.round()}°',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget _buildWeatherDetailsGrid(dynamic weather, bool isDesktop, bool isTablet) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = isDesktop ? 3 : (screenWidth > 500 ? 3 : 2);
    final childAspectRatio = isDesktop ? 1.2 : (isTablet ? 1.1 : 1.0);

    final detailItems = [
      _buildDetailItem(
        'UV Index',
        '${weather.uvIndex.round()}',
        Icons.wb_sunny,
        Colors.orange,
        isDesktop,
        isTablet,
      ),
      _buildDetailItem(
        'Visibility',
        '${weather.visibility.toStringAsFixed(1)} km',
        Icons.visibility,
        Colors.blue,
        isDesktop,
        isTablet,
      ),
      _buildAqiDetailItem(
        'Air Quality',
        weather.aqi,
        Icons.air_outlined,
        isDesktop,
        isTablet,
      ),
      _buildDetailItem(
        'Sunrise',
        DateFormat('HH:mm').format(weather.sunrise),
        Icons.wb_sunny_outlined,
        Colors.yellow,
        isDesktop,
        isTablet,
      ),
      _buildDetailItem(
        'Sunset',
        DateFormat('HH:mm').format(weather.sunset),
        Icons.brightness_3,
        Colors.purple,
        isDesktop,
        isTablet,
      ),
      _buildDetailItem(
        'Humidity',
        '${weather.humidity}%',
        Icons.water_drop,
        Colors.cyan,
        isDesktop,
        isTablet,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: isDesktop ? 20 : 15,
        mainAxisSpacing: isDesktop ? 20 : 15,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: detailItems.length,
      itemBuilder: (context, index) => detailItems[index],
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon, Color color, bool isDesktop, bool isTablet) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(isDesktop ? 16 : (isTablet ? 12 : 10)),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: isDesktop ? 28 : (isTablet ? 24 : 20),
          ),
        ),
        SizedBox(height: isDesktop ? 12 : 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: isDesktop ? 6 : 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: isDesktop ? 14 : (isTablet ? 12 : 10),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAqiDetailItem(String label, int? aqiValue, IconData icon, bool isDesktop, bool isTablet) {
    final aqiColor = WeatherModel.getAqiColor(aqiValue);
    final aqiCategory = WeatherModel.getAqiCategory(aqiValue);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(isDesktop ? 16 : (isTablet ? 12 : 10)),
          decoration: BoxDecoration(
            color: aqiColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: aqiColor,
            size: isDesktop ? 28 : (isTablet ? 24 : 20),
          ),
        ),
        SizedBox(height: isDesktop ? 12 : 8),
        Text(
          aqiValue != null ? '$aqiValue' : 'N/A',
          style: TextStyle(
            color: Colors.white,
            fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: isDesktop ? 4 : 2),
        Text(
          aqiCategory,
          style: TextStyle(
            color: aqiColor.withValues(alpha: 0.8),
            fontSize: isDesktop ? 12 : (isTablet ? 10 : 8),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isDesktop ? 4 : 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: isDesktop ? 14 : (isTablet ? 12 : 10),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}