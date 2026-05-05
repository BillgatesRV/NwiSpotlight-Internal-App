import 'dart:io';

import 'package:spotlight/models/api_response.dart';
import 'package:spotlight/models/employee_profile_response.dart';
import 'package:spotlight/models/user_response.dart';

abstract class ProfileBaseService {
  Future<EmployeeProfileResponse> fetchEmployeeProfileDetail();
  Future<EmployeeProfileResponse> fetchOtherEmployeeProfileDetail(String empGuid);
  Future<List<UserResponse>> fetchAllUsers(int pageNumber, int pageSize);
  Future<ApiResponse> addCoverImage(File coverImg);
}