class ApiResponse<T> {
  final bool isSuccess;
  final String? message;
  final String? messageAr;
  final T? data;
  final List<String>? errors;

  ApiResponse({required this.isSuccess, this.message, this.messageAr, this.data, this.errors});

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromJsonT) {
    return ApiResponse<T>(
      isSuccess: json['isSuccess'] ?? false,
      message: json['message'],
      messageAr: json['messageAr'],
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : json['data'],
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'isSuccess': isSuccess, 'message': message, 'messageAr': messageAr, 'data': data, 'errors': errors};
  }
}
