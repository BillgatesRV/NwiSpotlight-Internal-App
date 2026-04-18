import 'package:spotlight/models/employeeProfileResponse.dart';
import 'package:spotlight/models/userResponse.dart';

abstract class ProfileBaseService {
  Future<EmployeeProfileResponse> fetchEmployeeProfileDetail();
  Future<EmployeeProfileResponse> fetchOtherEmployeeProfileDetail(String empGuid);
  Future<List<UserResponse>> fetchAllUsers(int pageNumber, int pageSize);
}