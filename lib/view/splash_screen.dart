import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'home.dart';
import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.bounceOut,
    ));

    // Start animation
    _animationController.forward();

    // Navigate to login page after 3 seconds
    Timer(Duration(seconds: 3), () {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // User is signed in
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Home()),
        );
      } else {
        // Not signed in
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 768;
    final isDesktop = screenWidth > 1024;

    // Responsive values
    final iconSize = isDesktop ? 160.0 : (isTablet ? 140.0 : 120.0);
    final titleFontSize = isDesktop ? 42.0 : (isTablet ? 36.0 : 32.0);
    final subtitleFontSize = isDesktop ? 20.0 : (isTablet ? 18.0 : 16.0);
    final spacing = isDesktop ? 40.0 : (isTablet ? 35.0 : 30.0);
    final bottomSpacing = isDesktop ? 60.0 : (isTablet ? 55.0 : 50.0);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            // ✅ Use your background
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 80.0 : (isTablet ? 60.0 : 40.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App Icon
                        Container(
                          width: iconSize,
                          height: iconSize,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: isDesktop ? 15 : (isTablet ? 12 : 10),
                                offset: Offset(0, isDesktop ? 8 : (isTablet ? 6 : 5)),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/weather_app_icon.png',
                              width: iconSize * 0.8,
                              height: iconSize * 0.8,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: spacing),
                        Text(
                          'Aurora',
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: isDesktop ? 1.5 : (isTablet ? 1.3 : 1.2),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: isDesktop ? 15 : (isTablet ? 12 : 10)),
                        Text(
                          'Get Real-Time Weather Updates',
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: bottomSpacing),
                        SizedBox(
                          width: isDesktop ? 32 : (isTablet ? 28 : 24),
                          height: isDesktop ? 32 : (isTablet ? 28 : 24),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: isDesktop ? 3.0 : (isTablet ? 2.5 : 2.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}