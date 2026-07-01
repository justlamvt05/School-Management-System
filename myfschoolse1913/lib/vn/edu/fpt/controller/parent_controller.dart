import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/api_response.dart';
import '../model/child_response.dart';
import '../model/attendance_response.dart';
import '../core/token_manager.dart';
import 'auth_controller.dart';

class ParentController {
  static const String baseUrl = "http://localhost:8080/api/parent";
  final String token;

  ParentController({required this.token});

  Map<String, String> get _headers => {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${TokenManager.instance.token.isNotEmpty ? TokenManager.instance.token : token}",
      };

  Future<http.Response> _getWithRetry(String url) async {
    var response = await http.get(Uri.parse(url), headers: _headers);

    if (response.statusCode == 401) {
      final authController = AuthController();
      final refreshResult = await authController.refreshToken(TokenManager.instance.refreshToken);

      if (refreshResult.status && refreshResult.data != null) {
        TokenManager.instance.token = refreshResult.data!.accessToken;
        TokenManager.instance.refreshToken = refreshResult.data!.refreshToken;

        // Retry the request with the new token
        response = await http.get(Uri.parse(url), headers: _headers);
      }
    }
    return response;
  }

  Future<ApiResponse<List<ChildResponse>>> getChildren() async {
    final response = await _getWithRetry("$baseUrl/children");
    final json = jsonDecode(response.body);

    if (json is List) {
      final children = json.map((item) => ChildResponse.fromJson(item)).toList();
      return ApiResponse<List<ChildResponse>>(
        code: "200", 
        status: true, 
        message: "Success", 
        data: children
      );
    }

    return ApiResponse<List<ChildResponse>>.fromJson(
      json,
      (data) => (data as List).map((item) => ChildResponse.fromJson(item)).toList(),
    );
  }

  Future<ApiResponse<List<AttendanceMonth>>> getAttendanceMonths(int studentId, int classId) async {
    final response = await _getWithRetry("$baseUrl/students/$studentId/class/$classId/months");
    final json = jsonDecode(response.body);

    return ApiResponse<List<AttendanceMonth>>.fromJson(
      json,
      (data) => (data as List).map((item) => AttendanceMonth.fromJson(item)).toList(),
    );
  }

  Future<ApiResponse<List<AttendanceItem>>> getAttendances(int studentId, int classId, int year, int month) async {
    // Assuming a similar path for detailed attendances, e.g. /students/{studentId}/class/{classId}/my?year=...&month=...
    // Or we will adapt it if the user specifies later. 
    // Wait, let's check StudentController's getAttendances path: "$baseUrl/attendances/class/$classId/my?year=$year&month=$month"
    // So for parent, maybe it's "$baseUrl/students/$studentId/class/$classId/my?year=$year&month=$month" ?
    final response = await _getWithRetry("$baseUrl/students/$studentId/class/$classId/my?year=$year&month=$month");
    final json = jsonDecode(response.body);

    return ApiResponse<List<AttendanceItem>>.fromJson(
      json,
      (data) => (data as List).map((item) => AttendanceItem.fromJson(item)).toList(),
    );
  }
}
