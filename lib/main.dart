import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:weather_app/view/splash_screen.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'viewmodels/weather_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => WeatherViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}
