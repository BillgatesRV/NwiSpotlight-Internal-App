class ApiResponse {
  dynamic result;
  bool isSuccess;
  String? message;
  int responseCode;

  ApiResponse({
    required this.result,
    required this.isSuccess,
    this.message,
    required this.responseCode,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      result: json['result'],
      isSuccess: json['isSuccess'],
      message: json['message'] ?? '',
      responseCode: json['responseCode'],
    );
  }
}
