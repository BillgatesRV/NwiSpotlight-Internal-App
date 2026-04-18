class ApiResponse<T> {
  T? result;
  bool isSuccess;
  String message;
  int responseCode;

  ApiResponse({
    this.result,
    required this.isSuccess,
    required this.message,
    required this.responseCode
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    return ApiResponse<T>(
      result: json['result'] != null ? fromJsonT(json['result']) : null,
      isSuccess: json['isSuccess'],
      message: json['message'] ?? '',
      responseCode: json['responseCode'],
    );
  }
}