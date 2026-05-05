class UserResponse {
  String employeeGuid;
  String employeeName;
  String profileImage;
  int points;
  int totalCount;

  UserResponse({
    required this.employeeGuid,
    required this.employeeName,
    required this.profileImage,
    required this.points,
    required this.totalCount,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      employeeGuid: json['employeeGuid'],
      employeeName: json['employeeName'],
      profileImage: json['profileImage'],
      points: json['points'],
      totalCount: json['totalCount'],
    );
  }
}