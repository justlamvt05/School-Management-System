class ApiResponse<T> {
  final String code;
  final bool status;
  final String message;
  final T? data;
  final dynamic errors;

  ApiResponse({
    required this.code,
    required this.status,
    required this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json,
      T Function(dynamic)? fromJsonT,
      ) {
    return ApiResponse<T>(
      code: json["code"] ?? "",
      status: json["status"] is bool ? json["status"] : false,
      message: json["message"] ?? "",
      data: json["data"] != null && fromJsonT != null ? fromJsonT(json["data"]): null,
      errors: json["errors"],
    );
  }

}