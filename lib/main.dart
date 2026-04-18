import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotlight/provider/homeProvider.dart';
import 'package:spotlight/provider/loginProvider.dart';
import 'package:spotlight/provider/profileProvider.dart';
import 'package:spotlight/provider/uploadsProvider.dart';
import 'package:spotlight/screens/preLogin/splashScreen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => UploadsProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(child: SplashScreen()),
    );
  }
}
