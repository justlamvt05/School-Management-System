import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/api_response.dart';
import '../model/schedule_response.dart';
import '../model/grade_response.dart';
import '../model/club_item.dart';
import '../model/attendance_response.dart';
import '../core/token_manager.dart';
import 'auth_controller.dart';

class StudentController {
  static const String baseUrl = "http://localhost:8080/api/student";

  final String token;

  StudentController({required this.token});

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

  /// Lấy thời khóa biểu theo classId
  Future<ApiResponse<List<ScheduleItem>>> getSchedules(int classId) async {
    final response = await _getWithRetry("$baseUrl/schedules/class/$classId");

    final json = jsonDecode(response.body);

    return ApiResponse<List<ScheduleItem>>.fromJson(
      json,
      (data) => (data as List)
          .map((item) => ScheduleItem.fromJson(item))
          .toList(),
    );
  }

  /// Lấy bảng điểm theo studentId
  Future<ApiResponse<List<GradeItem>>> getGrades(int studentId) async {
    final response = await _getWithRetry("$baseUrl/grades/$studentId");

    final json = jsonDecode(response.body);

    return ApiResponse<List<GradeItem>>.fromJson(
      json,
      (data) => (data as List)
          .map((item) => GradeItem.fromJson(item))
          .toList(),
    );
  }

  /// Lấy danh sách câu lạc bộ
  Future<ApiResponse<List<ClubItem>>> getClubs() async {
    final response = await _getWithRetry("$baseUrl/clubs");

    final json = jsonDecode(response.body);

    return ApiResponse<List<ClubItem>>.fromJson(
      json,
      (data) => (data as List)
          .map((item) => ClubItem.fromJson(item))
          .toList(),
    );
  }

  /// Lấy danh sách tháng điểm danh theo classId
  Future<ApiResponse<List<AttendanceMonth>>> getAttendanceMonths(int classId) async {
    final response = await _getWithRetry("$baseUrl/attendances/class/$classId/months");

    final json = jsonDecode(response.body);

    return ApiResponse<List<AttendanceMonth>>.fromJson(
      json,
      (data) => (data as List)
          .map((item) => AttendanceMonth.fromJson(item))
          .toList(),
    );
  }

  /// Lấy chi tiết điểm danh theo classId, year, month
  Future<ApiResponse<List<AttendanceItem>>> getAttendances(int classId, int year, int month) async {
    final response = await _getWithRetry("$baseUrl/attendances/class/$classId/my?year=$year&month=$month");

    final json = jsonDecode(response.body);

    return ApiResponse<List<AttendanceItem>>.fromJson(
      json,
      (data) => (data as List)
          .map((item) => AttendanceItem.fromJson(item))
          .toList(),
    );
  }
}
