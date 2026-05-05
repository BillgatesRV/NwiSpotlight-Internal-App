import 'package:flutter/material.dart';
import 'package:spotlight/common_components/tabbar.dart';
import 'package:spotlight/core/Helpers.dart';
import 'package:spotlight/models/login_response.dart';
import 'package:spotlight/services/auth_service/auth_base_service.dart';
import 'package:spotlight/services/auth_service/auth_service.dart';
import 'package:spotlight/services/auth_service/auth_storage.dart';

class LoginProvider extends ChangeNotifier {
  final AuthBaseService _authService = Authservice();
  final AuthStorage _authStorage = AuthStorage();

  bool isLoading = false;
  String? errorMessage;
  LoginResponse? loginResponse;

  Future<void> userLogin(
    BuildContext context,
    String email,
    String password,
  ) async {
    isLoading = true;
    errorMessage = null;

    notifyListeners();

    try {
      Helpers.showLoading(context);
      final response = await _authService.employeeLogin(email, password);

      loginResponse = response;

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
      errorMessage = e.toString();
      final message = e.toString().replaceAll("Exception: ", "");

      errorMessage = message;

      Helpers.showErrorSnackBar(context, message: message);
    }

    isLoading = false;
    notifyListeners();
  }
}
