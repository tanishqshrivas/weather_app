import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class AqiDetailsWidget extends StatelessWidget {
  final AirQualityData? airQuality;
  final bool isTablet;

  const AqiDetailsWidget({
    Key? key,
    required this.airQuality,
    this.isTablet = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (airQuality == null) {
      return Container(
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
          children: [
            Icon(
              Icons.air_outlined,
              color: Colors.grey,
              size: isTablet ? 48 : 40,
            ),
            SizedBox(height: 16),
            Text(
              'Air Quality Data Unavailable',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Unable to fetch air quality information for this location',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: isTablet ? 14 : 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
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
          // Header with AQI value and status
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 16 : 12),
                decoration: BoxDecoration(
                  color: airQuality!.aqiColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.air_outlined,
                  color: airQuality!.aqiColor,
                  size: isTablet ? 32 : 28,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Air Quality Index',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 20 : 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${airQuality!.aqi}',
                          style: TextStyle(
                            color: airQuality!.aqiColor,
                            fontSize: isTablet ? 28 : 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: airQuality!.aqiColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            airQuality!.aqiDescription,
                            style: TextStyle(
                              color: airQuality!.aqiColor,
                              fontSize: isTablet ? 14 : 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          // Health recommendation
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isTablet ? 16 : 12),
            decoration: BoxDecoration(
              color: airQuality!.aqiColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: airQuality!.aqiColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              airQuality!.healthRecommendation,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: isTablet ? 14 : 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          SizedBox(height: 20),

          // Pollutant details
          Text(
            'Pollutant Levels',
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),

          // Primary pollutant highlight
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isTablet ? 12 : 10),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: isTablet ? 20 : 18,
                ),
                SizedBox(width: 8),
                Text(
                  'Primary Pollutant: ${airQuality!.primaryPollutant}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Pollutant grid
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildPollutantItem('PM2.5', '${airQuality!.pm2_5.toStringAsFixed(1)} μg/m³', Colors.red),
              _buildPollutantItem('PM10', '${airQuality!.pm10.toStringAsFixed(1)} μg/m³', Colors.orange),
              _buildPollutantItem('NO₂', '${airQuality!.no2.toStringAsFixed(1)} μg/m³', Colors.blue),
              _buildPollutantItem('O₃', '${airQuality!.o3.toStringAsFixed(1)} μg/m³', Colors.green),
              _buildPollutantItem('SO₂', '${airQuality!.so2.toStringAsFixed(1)} μg/m³', Colors.purple),
              _buildPollutantItem('CO', '${(airQuality!.co / 1000).toStringAsFixed(2)} mg/m³', Colors.brown),
            ],
          ),

          SizedBox(height: 16),

          // Last updated
          Text(
            'Last updated: ${_formatTimestamp(airQuality!.timestamp)}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: isTablet ? 12 : 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPollutantItem(String name, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 12 : 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: TextStyle(
              color: color,
              fontSize: isTablet ? 14 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: isTablet ? 12 : 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}
