import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:spotlight/core/urls.dart';
import 'package:spotlight/models/apiResponse.dart';
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
  Future<EmployeeProfileResponse> fetchOtherEmployeeProfileDetail(
    String empGuid,
  ) async {
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

  @override
  Future<ApiResponse> addCoverImage(File coverImg) async {
    try {
      final url = Uri.parse(
        "${Urls.baseUrl}employee/profile/add-user-cover-image",
      );

      String? token = await _authStorage.getToken();

      if (token == null || token.isEmpty) {
        return ApiResponse(
          result: null,
          isSuccess: false,
          message: "Unauthorized access",
          responseCode: 401,
        );
      }

      var request = http.MultipartRequest("POST", url);

      request.headers["Authorization"] = "Bearer $token";

      request.files.add(
        await http.MultipartFile.fromPath("coverImage", coverImg.path),
      );

      final streamedData = await request.send();
      final response = await http.Response.fromStream(streamedData);

      final data = jsonDecode(response.body);

      if (data["responseCode"] == 201 || data["responseCode"] == 200) {
        return ApiResponse(
          isSuccess: data["isSuccess"],
          message: data["message"] ?? "Cover image uploaded successfully",
          responseCode: data["responseCode"],
          result: data["result"],
        );
      } else {
        return ApiResponse(
          isSuccess: data["isSuccess"],
          message: data["message"] ?? "Failed to upload cover image",
          responseCode: response.statusCode,
          result: null,
        );
      }
    } catch (e) {
      debugPrint("Add Cover Image Error: $e");

      return ApiResponse(
        isSuccess: false,
        message: "Something went wrong",
        responseCode: 500,
        result: null,
      );
    }
  }
}
