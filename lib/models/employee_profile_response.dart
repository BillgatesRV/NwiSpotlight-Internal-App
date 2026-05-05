class EmployeeProfileResponse {
  String employeeGuid;
  String employeeId;
  String employeeName;
  String designation;
  String emailId;
  String mobile;
  String profileImage;
  int uploadPoints;
  String dojInYears;
  String? coverImgGuid;
  String? coverImageUrl;
  DateTime? addedOn;

  EmployeeProfileResponse({
    required this.employeeGuid,
    required this.employeeId,
    required this.employeeName,
    required this.designation,
    required this.emailId,
    required this.mobile,
    required this.profileImage,
    required this.uploadPoints,
    required this.dojInYears,
    this.coverImgGuid,
    this.coverImageUrl,
    this.addedOn,
  });

  factory EmployeeProfileResponse.fromJson(Map<String, dynamic> json) {  
    return EmployeeProfileResponse (
      employeeGuid : json['employeeGuid'],
      employeeId : json['employeeId'],
      employeeName : json['employeeName'],
      designation : json['designation'],
      emailId : json['emailId'],
      mobile : json['mobile'],
      profileImage : json['profileImage'],
      uploadPoints : json['uploadPoints'],
      coverImgGuid : json['coverImgGuid'],
      coverImageUrl : json['coverImageUrl'],
      dojInYears : json['doj'],
      addedOn : json['addedOn'] = DateTime.parse(json['addedOn']),
    );
  }
}