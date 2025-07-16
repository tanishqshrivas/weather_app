import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/services/weather_api_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'login_page.dart';
import 'weather_info.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  final WeatherApiService _weatherService = WeatherApiService();
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

  // Check network connectivity
  Future<bool> _checkNetworkConnectivity() async {
    try {
      final List<ConnectivityResult> connectivityResults = await Connectivity().checkConnectivity();

      // Check if any connection is available
      return connectivityResults.any((result) =>
      result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet
      );
    } catch (e) {
      print('Error checking connectivity: $e');
      return false;
    }
  }

  // Show network error dialog
  void _showNetworkErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.wifi_off,
                color: Colors.red,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'No Internet Connection',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Please check your internet connection and try again. Make sure your WiFi or mobile data is turned on.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
              child: Text(
                'OK',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Show network error snackbar (alternative to dialog)
  void _showNetworkErrorSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.wifi_off,
              color: Colors.white,
              size: 24,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'No internet connection. Please check your WiFi or mobile data.',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void fetchWeather(String city) async {
    // Check network connectivity first
    bool isConnected = await _checkNetworkConnectivity();

    if (!isConnected) {
      // Show network error - you can choose between dialog or snackbar
      _showNetworkErrorDialog(); // or use _showNetworkErrorSnackbar();
      return;
    }

    final weatherViewModel = Provider.of<WeatherViewModel>(context, listen: false);

    setState(() => isLoading = true);

    try {
      await weatherViewModel.fetchWeatherData(city);

      if (weatherViewModel.error != null) {
        throw Exception(weatherViewModel.error);
      }

      setState(() => isLoading = false);
      await _saveCityName(city);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WeatherInfoPage(
            weatherViewModel: weatherViewModel,
            cityName: city,
            onCityEdit: () {
              setState(() => isEditingCity = true);
            },
          ),
        ),
      );
    } catch (e) {
      setState(() => isLoading = false);

      // Check if it's a network-related error
      String errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('network') ||
          errorMessage.contains('connection') ||
          errorMessage.contains('timeout') ||
          errorMessage.contains('failed host lookup')) {
        _showNetworkErrorSnackbar();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching weather data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 768;

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
        padding: EdgeInsets.all(isDesktop ? 32 : (isTablet ? 24 : 20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: isDesktop ? 50 : (isTablet ? 45 : 40),
              backgroundImage: _user?.photoURL != null
                  ? NetworkImage(_user!.photoURL!)
                  : null,
              child: _user?.photoURL == null
                  ? Icon(Icons.person, size: isDesktop ? 50 : (isTablet ? 45 : 40))
                  : null,
            ),
            SizedBox(height: isDesktop ? 20 : 16),
            Text(
              _user?.displayName ?? 'User',
              style: TextStyle(
                fontSize: isDesktop ? 28 : (isTablet ? 26 : 24),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isDesktop ? 12 : 8),
            Text(
              _user?.email ?? '',
              style: TextStyle(
                fontSize: isDesktop ? 18 : (isTablet ? 17 : 16),
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: isDesktop ? 40 : 30),
            Container(
              width: double.infinity,
              constraints: BoxConstraints(maxWidth: isDesktop ? 400 : 350),
              child: ElevatedButton(
                onPressed: _signOut,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: isDesktop ? 16 : (isTablet ? 14 : 12),
                  ),
                ),
                child: Text(
                  'Sign Out',
                  style: TextStyle(fontSize: isDesktop ? 18 : (isTablet ? 17 : 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityInput() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 768;
    final maxWidth = isDesktop ? 600.0 : (isTablet ? 500.0 : double.infinity);

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
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
        style: TextStyle(
          color: Colors.white,
          fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
        ),
        decoration: InputDecoration(
          hintText: 'Enter city name',
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white.withOpacity(0.6),
            size: isDesktop ? 24 : (isTablet ? 22 : 20),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 24 : (isTablet ? 20 : 20),
            vertical: isDesktop ? 20 : (isTablet ? 18 : 15),
          ),
        ),
      ),
    );
  }

  Widget _buildSavedCityDisplay() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 768;
    final maxWidth = isDesktop ? 600.0 : (isTablet ? 500.0 : double.infinity);

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: EdgeInsets.all(isDesktop ? 24 : (isTablet ? 22 : 20)),
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
                    fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  savedCity!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 22 : (isTablet ? 21 : 20),
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
              size: isDesktop ? 26 : (isTablet ? 24 : 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 768;
    final maxWidth = isDesktop ? 600.0 : (isTablet ? 500.0 : double.infinity);

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      width: double.infinity,
      height: isDesktop ? 65 : (isTablet ? 60 : 55),
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
          size: isDesktop ? 24 : (isTablet ? 22 : 20),
        )
            : Text(
          savedCity != null && !isEditingCity ? 'Get Weather' : 'Save & Get Weather',
          style: TextStyle(
            fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WeatherViewModel(),
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 768;
    final isDesktop = screenWidth > 1200;
    final isLargeDesktop = screenWidth > 1600;

    // Enhanced responsive padding and sizing
    final horizontalPadding = isLargeDesktop ? 120.0 : (isDesktop ? 80.0 : (isTablet ? 60.0 : 20.0));
    final verticalPadding = isDesktop ? 40.0 : (isTablet ? 30.0 : 20.0);
    final maxContentWidth = isLargeDesktop ? 1000.0 : (isDesktop ? 800.0 : (isTablet ? 600.0 : double.infinity));

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
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Aurora',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isLargeDesktop ? 40 : (isDesktop ? 36 : (isTablet ? 32 : 28)),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: _showUserProfile,
                          child: CircleAvatar(
                            radius: isLargeDesktop ? 32 : (isDesktop ? 28 : (isTablet ? 25 : 20)),
                            backgroundImage: _user?.photoURL != null
                                ? NetworkImage(_user!.photoURL!)
                                : null,
                            child: _user?.photoURL == null
                                ? Icon(Icons.person,
                                color: Colors.white,
                                size: isLargeDesktop ? 36 : (isDesktop ? 32 : (isTablet ? 30 : 24)))
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: maxContentWidth,
                            minHeight: screenHeight - (isDesktop ? 200 : 150),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // App icon with enhanced responsive sizing
                              Container(
                                height: isLargeDesktop ? 350 : (isDesktop ? 300 : (isTablet ? 250 : 200)),
                                width: isLargeDesktop ? 350 : (isDesktop ? 300 : (isTablet ? 250 : 200)),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: isDesktop ? 25 : 20,
                                      offset: Offset(0, isDesktop ? 12 : 10),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/weather_app_icon.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                              SizedBox(height: isLargeDesktop ? 60 : (isDesktop ? 50 : (isTablet ? 45 : 40))),

                              // Welcome text with enhanced responsive typography
                              Text(
                                'Welcome back, ${_user?.displayName?.split(' ')[0] ?? 'User'}!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isLargeDesktop ? 36 : (isDesktop ? 32 : (isTablet ? 28 : 24)),
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(height: isDesktop ? 15 : 10),

                              Text(
                                savedCity != null && !isEditingCity
                                    ? 'Check the weather in $savedCity'
                                    : 'Enter your city to get started',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: isLargeDesktop ? 22 : (isDesktop ? 20 : (isTablet ? 18 : 16)),
                                ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(height: isLargeDesktop ? 60 : (isDesktop ? 50 : (isTablet ? 45 : 40))),

                              // City input or display
                              if (savedCity == null || isEditingCity)
                                _buildCityInput()
                              else
                                _buildSavedCityDisplay(),

                              SizedBox(height: isDesktop ? 35 : 30),

                              // Action button
                              _buildActionButton(),

                              // Cancel button for editing
                              if (isEditingCity && savedCity != null) ...[
                                SizedBox(height: isDesktop ? 20 : 15),
                                Container(
                                  constraints: BoxConstraints(maxWidth: maxContentWidth),
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
                                        fontSize: isLargeDesktop ? 20 : (isDesktop ? 18 : (isTablet ? 17 : 16)),
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