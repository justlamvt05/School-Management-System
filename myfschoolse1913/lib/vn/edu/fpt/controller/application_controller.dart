import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/api_response.dart';
import '../model/application_request.dart';
import '../model/application_item.dart';
import '../core/token_manager.dart';
import 'auth_controller.dart';

class ApplicationController {
  static const String baseUrl = "http://localhost:8080/api/applications";

  final String token;

  ApplicationController({required this.token});

  Map<String, String> get _headers => {
    "Content-Type": "application/json",
    "Authorization": "Bearer ${TokenManager.instance.token.isNotEmpty ? TokenManager.instance.token : token}",
  };

  /// Decode JSON từ response và chuẩn hóa field `errors`.
  /// API luôn decode mảng thành `List<dynamic>`, nhưng phía UI lại
  /// dùng `res.errors` như `List<String>`. Ép kiểu ngay tại đây để
  /// tránh lỗi runtime "List<dynamic> is not a subtype of List<String>"
  /// mà KHÔNG cần sửa model ApiResponse.
  Map<String, dynamic> _decodeBody(http.Response response) {
    final json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    if (json['errors'] != null && json['errors'] is List) {
      json['errors'] = List<String>.from(
        (json['errors'] as List).map((e) => e.toString()),
      );
    }

    return json;
  }

  Future<http.Response> _requestWithRetry(
      String method,
      String url, {
        Map<String, dynamic>? body,
      }) async {
    http.Response response;
    final uri = Uri.parse(url);

    if (method == 'POST') {
      response = await http.post(uri, headers: _headers, body: jsonEncode(body));
    } else if (method == 'PUT') {
      response = await http.put(uri, headers: _headers, body: jsonEncode(body));
    } else {
      response = await http.get(uri, headers: _headers);
    }

    if (response.statusCode == 401) {
      final authController = AuthController();
      final refreshResult = await authController.refreshToken(TokenManager.instance.refreshToken);

      if (refreshResult.status && refreshResult.data != null) {
        TokenManager.instance.token = refreshResult.data!.accessToken;
        TokenManager.instance.refreshToken = refreshResult.data!.refreshToken;

        // Retry the request with the new token
        if (method == 'POST') {
          response = await http.post(uri, headers: _headers, body: jsonEncode(body));
        } else if (method == 'PUT') {
          response = await http.put(uri, headers: _headers, body: jsonEncode(body));
        } else {
          response = await http.get(uri, headers: _headers);
        }
      }
    }
    return response;
  }

  /// Tạo đơn mới (Student)
  Future<ApiResponse<ApplicationItem>> createApplication(ApplicationRequest request) async {
    final response = await _requestWithRetry('POST', baseUrl, body: request.toJson());
    final json = _decodeBody(response);

    return ApiResponse<ApplicationItem>.fromJson(
      json,
          (data) => ApplicationItem.fromJson(data),
    );
  }

  /// Lấy danh sách đơn của tôi (Student)
  Future<ApiResponse<List<ApplicationItem>>> getMyApplications() async {
    final response = await _requestWithRetry('GET', "$baseUrl/my");
    final json = _decodeBody(response);

    return ApiResponse<List<ApplicationItem>>.fromJson(
      json,
          (data) => (data as List).map((item) => ApplicationItem.fromJson(item)).toList(),
    );
  }

  /// Xem chi tiết đơn của tôi (Student)
  Future<ApiResponse<ApplicationItem>> getMyApplicationById(int id) async {
    final response = await _requestWithRetry('GET', "$baseUrl/my/$id");
    final json = _decodeBody(response);

    return ApiResponse<ApplicationItem>.fromJson(
      json,
          (data) => ApplicationItem.fromJson(data),
    );
  }

  // ==================== ADMIN APIs ====================
  // Lưu ý: Các API dưới đây gọi đến endpoint /api/admin/applications
  static const String adminBaseUrl = "http://localhost:8080/api/admin/applications";

  /// Lấy toàn bộ đơn (Admin)
  Future<ApiResponse<List<ApplicationItem>>> getAllApplications({String? status, String? type}) async {
    String url = adminBaseUrl;
    List<String> queryParams = [];
    if (status != null) queryParams.add("status=$status");
    if (type != null) queryParams.add("type=$type");
    if (queryParams.isNotEmpty) {
      url += "?${queryParams.join('&')}";
    }

    final response = await _requestWithRetry('GET', url);
    final json = _decodeBody(response);

    return ApiResponse<List<ApplicationItem>>.fromJson(
      json,
          (data) => (data as List).map((item) => ApplicationItem.fromJson(item)).toList(),
    );
  }

  /// Xem chi tiết đơn (Admin)
  Future<ApiResponse<ApplicationItem>> getApplicationById(int id) async {
    final response = await _requestWithRetry('GET', "$adminBaseUrl/$id");
    final json = _decodeBody(response);

    return ApiResponse<ApplicationItem>.fromJson(
      json,
          (data) => ApplicationItem.fromJson(data),
    );
  }

  /// Duyệt đơn (Admin)
  Future<ApiResponse<ApplicationItem>> approveApplication(int id, String responseMessage) async {
    final response = await _requestWithRetry('PUT', "$adminBaseUrl/$id/approve", body: {
      "responseMessage": responseMessage,
    });
    final json = _decodeBody(response);

    return ApiResponse<ApplicationItem>.fromJson(
      json,
          (data) => ApplicationItem.fromJson(data),
    );
  }

  /// Từ chối đơn (Admin)
  Future<ApiResponse<ApplicationItem>> rejectApplication(int id, String responseMessage) async {
    final response = await _requestWithRetry('PUT', "$adminBaseUrl/$id/reject", body: {
      "responseMessage": responseMessage,
    });
    final json = _decodeBody(response);

    return ApiResponse<ApplicationItem>.fromJson(
      json,
          (data) => ApplicationItem.fromJson(data),
    );
  }
}