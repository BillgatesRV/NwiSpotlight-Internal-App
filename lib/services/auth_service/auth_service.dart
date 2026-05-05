import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:spotlight/core/urls.dart';
import 'package:spotlight/models/login_response.dart';
import 'package:http/http.dart' as http;
import 'package:spotlight/services/auth_service/auth_base_service.dart';

class Authservice extends AuthBaseService {
  @override
  Future<LoginResponse> employeeLogin(String email, String password) async {
    try {
      final url = Uri.parse("${Urls.baseUrl}employee/auth/login");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": email, "password": password}),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        final result = data["result"];
        
        if (result == null) { 
          throw Exception("Invalid response structure");
        }

        return LoginResponse.fromJson(result);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error["message"] ?? "Login failed");
      }
    } catch (e) {
      debugPrint("Login Error: $e");
      throw Exception(e.toString()); 
    }
  }
}
