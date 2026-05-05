class LoginResponse {
  String userName;
  String accessToken;
  String userGuid;
  String refreshToken;
  String status;
  String? role;

  LoginResponse({
    required this.userName,
    required this.accessToken,
    required this.userGuid,
    required this.refreshToken,
    required this.status,
    this.role,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
        userName: json["userName"],
        accessToken: json["accessToken"],
        refreshToken: json["refreshToken"],
        userGuid: json["employeeGuid"],
        status: json["status"],
        role: json["role"],
    );
  }
}
