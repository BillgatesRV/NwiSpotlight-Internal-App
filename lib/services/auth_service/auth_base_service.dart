import 'package:spotlight/models/login_response.dart';

abstract class AuthBaseService {
  Future<LoginResponse> employeeLogin(String email, String password);
}