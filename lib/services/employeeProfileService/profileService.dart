import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:spotlight/core/urls.dart';
import 'package:spotlight/models/employeeProfileResponse.dart';
import 'package:spotlight/models/userResponse.dart';
import 'package:spotlight/services/authService/authStorage.dart';
import 'package:spotlight/services/employeeProfileService/profileBaseService.dart';

class ProfileService extends ProfileBaseService {
  final AuthStorage _authStorage = AuthStorage();

  @override
  Future<EmployeeProfileResponse> fetchEmployeeProfileDetail() async {
    try {
      final url = Uri.parse(
        "${Urls.baseUrl}employee/profile/get-emp-basic-profile-details",
      );

      String? token = await _authStorage.getToken();

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData["result"] != null) {
          return EmployeeProfileResponse.fromJson(responseData["result"]);
        } else {
          throw Exception(
            responseData["message"] ?? "failed to fetch employee details",
          );
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error["message"] ?? "Fetching detail failed");
      }
    } catch (e) {
      debugPrint("User data retrival Error: $e");
      throw Exception(e.toString());
    }
  }

  @override
  Future<EmployeeProfileResponse> fetchOtherEmployeeProfileDetail(String empGuid) async {
    try {
      final url = Uri.parse(
        "${Urls.baseUrl}employee/common/get-other-emp-profile-details?empGuid=$empGuid",
      );

      String? token = await _authStorage.getToken();

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData["result"] != null) {
          return EmployeeProfileResponse.fromJson(responseData["result"]);
        } else {
          throw Exception(
            responseData["message"] ?? "failed to fetch employee details",
          );
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error["message"] ?? "Fetching detail failed");
      }
    } catch (e) {
      debugPrint("User data retrival Error: $e");
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<UserResponse>> fetchAllUsers(int pageNumber, int pageSize) async {
    try {
      final url = Uri.parse(
        "${Urls.baseUrl}employee/leaderboard/get-leaderboard-list-with-points?pageNumber=$pageNumber&pageSize=$pageSize",
      );

      String? token = await _authStorage.getToken();

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData["result"] != null) {
          return List<UserResponse>.from(
            responseData["result"].map((x) => UserResponse.fromJson(x)),
          );
        } else {
          return [];
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error["message"] ?? "fetching users failed");
      }
    } catch (e) {
      debugPrint("Error fetching Users: $e");
      throw Exception(e.toString());
    }
  }
}
