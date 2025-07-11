import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'weather_service.dart';
import 'login_page.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  final WeatherService _weatherService = WeatherService();
  final TextEditingController _cityController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Map<String, dynamic>? weatherData;
  bool isLoading = false;
  double _temperature = 0.0;
  DateTime? sunrise;
  DateTime? sunset;
  User? _user;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _user = _auth.currentUser;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching weather data. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      print(e);
    }
    setState(() => isLoading = false);
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  void _showUserProfile() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 40,
              backgroundImage: _user?.photoURL != null
                  ? NetworkImage(_user!.photoURL!)
                  : null,
              child: _user?.photoURL == null
                  ? Icon(Icons.person, size: 40)
                  : null,
            ),
            SizedBox(height: 16),
            // User Name
            Text(
              _user?.displayName ?? 'User',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            // User Email
            Text(
              _user?.email ?? '',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 30),
            // Sign Out Button
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _signOut,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Sign Out',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Weather App"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          // User Profile Button
          GestureDetector(
            onTap: _showUserProfile,
            child: Container(
              margin: EdgeInsets.only(right: 16),
              child: CircleAvatar(
                backgroundImage: _user?.photoURL != null
                    ? NetworkImage(_user!.photoURL!)
                    : null,
                child: _user?.photoURL == null
                    ? Icon(Icons.person, color: Colors.white)
                    : null,
              ),
            ),
          ),
        ],
      ),
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
              // Welcome Message
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  'Welcome, ${_user?.displayName?.split(' ')[0] ?? 'User'}!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // 🔍 City input
              TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: "Enter city",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),
                  prefixIcon: Icon(Icons.location_city),
                ),
              ),
              SizedBox(height: 10),

              // 📥 Button
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    String city = _cityController.text.trim();
                    if (city.isNotEmpty) {
                      fetchWeather(city);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    "Get Weather",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
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
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      Text(
                        "${_temperature.toStringAsFixed(1)}°C",
                        style: TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        weatherData!['weather'][0]['description'],
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: 20),

                      // 🌅 Sunrise and Sunset
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Image.asset(
                                "assets/images/sunrise.jpg",
                                height: 40,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.wb_sunny,
                                      size: 40, color: Colors.orange);
                                },
                              ),
                              SizedBox(height: 4),
                              Text(
                                sunrise != null
                                    ? "Sunrise\n${TimeOfDay.fromDateTime(sunrise!).format(context)}"
                                    : "",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Image.asset(
                                "assets/images/sunset.jpg",
                                height: 40,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.wb_sunny_outlined,
                                      size: 40, color: Colors.deepOrange);
                                },
                              ),
                              SizedBox(height: 4),
                              Text(
                                sunset != null
                                    ? "Sunset\n${TimeOfDay.fromDateTime(sunset!).format(context)}"
                                    : "",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
                  : Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  "Enter a city and press 'Get Weather'",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}