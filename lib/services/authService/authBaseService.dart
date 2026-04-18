import 'package:spotlight/models/loginResponse.dart';

abstract class AuthBaseService {
  Future<LoginResponse> employeeLogin(String email, String password);
}