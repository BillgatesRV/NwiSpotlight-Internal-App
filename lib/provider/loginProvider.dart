import 'package:flutter/material.dart';
import 'package:spotlight/common_components/tabbar.dart';
import 'package:spotlight/core/Helpers.dart';
import 'package:spotlight/models/loginResponse.dart';
import 'package:spotlight/services/authService/authBaseService.dart';
import 'package:spotlight/services/authService/authService.dart';
import 'package:spotlight/services/authService/authStorage.dart';

class LoginProvider extends ChangeNotifier {
  final AuthBaseService _authService = Authservice();
  final AuthStorage _authStorage = AuthStorage();

  LoginProvider();

  bool _isLoading = false;
  String? _errorMessage;
  LoginResponse? _loginResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LoginResponse? get loginResponse => _loginResponse;

  Future<void> userLogin(
    BuildContext context,
    String email,
    String password,
  ) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      Helpers.showLoading(context);
      final response = await _authService.employeeLogin(email, password);

      _loginResponse = response;

      Navigator.of(context, rootNavigator: true).pop();

      if (response.status.toLowerCase() == "active") {
        await _authStorage.saveLoginData(
          response.accessToken,
          response.refreshToken,
          response.userGuid,
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => GlassBottomNav()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Login Failed",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.black,
            margin: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      _errorMessage = e.toString();
      final message = e.toString().replaceAll("Exception: ", "");

      _errorMessage = message;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.black,
          margin: EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: Duration(seconds: 1),
        ),
      );
    }

    _isLoading = false;
    notifyListeners();
  }
}
