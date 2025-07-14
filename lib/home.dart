import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'weather_service.dart';
import 'login_page.dart';
import 'weather_info.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  final WeatherService _weatherService = WeatherService();
  final TextEditingController _cityController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool isLoading = false;
  bool isEditingCity = false;
  String? savedCity;
  User? _user;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _user = _auth.currentUser;
    _loadSavedCity();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCity() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedCity = prefs.getString('saved_city');
      if (savedCity != null) {
        _cityController.text = savedCity!;
      }
    });
  }

  Future<void> _saveCityName(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_city', city);
    setState(() {
      savedCity = city;
    });
  }

  void fetchWeather(String city) async {
    setState(() => isLoading = true);
    try {
      final data = await _weatherService.getWeather(city);
      print("Weather API response: $data");
      setState(() => isLoading = false);

      await _saveCityName(city);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WeatherInfoPage(
            weatherData: data,
            cityName: city,
            onCityEdit: () {
              setState(() => isEditingCity = true);
            },
          ),
        ),
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching weather data: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      print('Error fetching weather: $e');
    }
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
      isScrollControlled: true,
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
            Text(
              _user?.displayName ?? 'User',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _user?.email ?? '',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 30),
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

  Widget _buildCityInput() {
    return Container(
      constraints: BoxConstraints(maxWidth: 500),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _cityController,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Enter city name',
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.6),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white.withOpacity(0.6),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildSavedCityDisplay() {
    return Container(
      constraints: BoxConstraints(maxWidth: 500),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your City',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  savedCity!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                isEditingCity = true;
              });
            },
            icon: Icon(
              Icons.edit,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return Container(
      constraints: BoxConstraints(maxWidth: 500),
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () {
          String city = _cityController.text.trim();
          if (city.isNotEmpty) {
            fetchWeather(city);
            setState(() {
              isEditingCity = false;
            });
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1a1a2e),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SpinKitThreeBounce(
          color: Color(0xFF1a1a2e),
          size: 20,
        )
            : Text(
          savedCity != null && !isEditingCity ? 'Get Weather' : 'Save & Get Weather',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Foreground content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Custom App Bar
                  Padding(
                    padding: EdgeInsets.all(isTablet ? 30 : 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Aurora',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 32 : 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: _showUserProfile,
                          child: CircleAvatar(
                            radius: isTablet ? 25 : 20,
                            backgroundImage: _user?.photoURL != null
                                ? NetworkImage(_user!.photoURL!)
                                : null,
                            child: _user?.photoURL == null
                                ? Icon(Icons.person,
                                color: Colors.white,
                                size: isTablet ? 30 : 24)
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 60 : 20,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height - 200,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // House illustration
                            SizedBox(
                              height: isTablet ? 250 : 200,
                              width: isTablet ? 250 : 200,
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/weather_app_icon.png',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            SizedBox(height: 40),

                            // Welcome text
                            Text(
                              'Welcome back, ${_user?.displayName?.split(' ')[0] ?? 'User'}!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet ? 28 : 24,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: 10),

                            Text(
                              savedCity != null && !isEditingCity
                                  ? 'Check the weather in $savedCity'
                                  : 'Enter your city to get started',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: isTablet ? 18 : 16,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: 40),

                            // City input or display
                            if (savedCity == null || isEditingCity)
                              _buildCityInput()
                            else
                              _buildSavedCityDisplay(),

                            SizedBox(height: 30),

                            // Action button
                            _buildActionButton(),

                            // Cancel button for editing
                            if (isEditingCity && savedCity != null) ...[
                              SizedBox(height: 15),
                              Container(
                                constraints: BoxConstraints(maxWidth: 500),
                                width: double.infinity,
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      isEditingCity = false;
                                      _cityController.text = savedCity!;
                                    });
                                  },
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}