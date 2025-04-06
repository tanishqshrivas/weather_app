import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'weather_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> with SingleTickerProviderStateMixin {
  final WeatherService _weatherService = WeatherService();
  final TextEditingController _cityController = TextEditingController();
  Map<String, dynamic>? weatherData;
  bool isLoading = false;
  double _temperature = 0.0;
  DateTime? sunrise;
  DateTime? sunset;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  void fetchWeather(String city) async {
    setState(() => isLoading = true);
    try {
      final data = await _weatherService.getWeather(city);
      setState(() {
        weatherData = data;
        _temperature = data['main']['temp'];
        sunrise = DateTime.fromMillisecondsSinceEpoch(data['sys']['sunrise'] * 1000);
        sunset = DateTime.fromMillisecondsSinceEpoch(data['sys']['sunset'] * 1000);
      });
      _controller.forward(from: 0);
    } catch (e) {
      print(e);
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Weather App")),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // 🔍 City input
              TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: "Enter city",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),

              // 📥 Button
              ElevatedButton(
                onPressed: () {
                  String city = _cityController.text.trim();
                  if (city.isNotEmpty) {
                    fetchWeather(city);
                  }
                },
                child: Text("Get Weather"),
              ),
              SizedBox(height: 20),

              // ⏳ Loading or Weather Display
              isLoading
                  ? SpinKitFadingCircle(color: Colors.blue, size: 50.0)
                  : weatherData != null
                  ? FadeTransition(
                opacity: _fadeAnimation,
                child: AnimatedContainer(
                  duration: Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "${weatherData!['name']}, ${weatherData!['sys']['country']}",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text("${_temperature.toStringAsFixed(1)}°C",
                          style: TextStyle(fontSize: 40)),
                      Text(weatherData!['weather'][0]['description'],
                          style: TextStyle(fontSize: 18)),
                      SizedBox(height: 20),

                      // 🌅 Sunrise and Sunset
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Image.asset("assets/images/sunrise.jpg", height: 40),
                              SizedBox(height: 4),
                              Text(
                                sunrise != null
                                    ? "Sunrise\n${TimeOfDay.fromDateTime(sunrise!).format(context)}"
                                    : "",
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Image.asset("assets/images/sunset.jpg", height: 40),
                              SizedBox(height: 4),
                              Text(
                                sunset != null
                                    ? "Sunset\n${TimeOfDay.fromDateTime(sunset!).format(context)}"
                                    : "",
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
                  : Text("Enter a city and press 'Get Weather'"),
            ],
          ),
        ),
      ),
    );
  }
}
