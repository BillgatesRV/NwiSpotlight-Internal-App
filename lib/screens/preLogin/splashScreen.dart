import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spotlight/common_components/tabbar.dart';
import 'package:spotlight/screens/preLogin/login_page.dart';
import 'package:spotlight/services/authService/authStorage.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SplashScreen();
}

class _SplashScreen extends State<SplashScreen> {
  final AuthStorage _storage = AuthStorage();

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  void _checkLogin() async {
    await Future.delayed(Duration(seconds: 2));

    String? token = await _storage.getToken();

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GlassBottomNav()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Image.asset(
              "assets/images/splash_icon.png",
              height: 80,
              width: 80,
            ),
          ),
        ),
      ),
    );
  }
}
