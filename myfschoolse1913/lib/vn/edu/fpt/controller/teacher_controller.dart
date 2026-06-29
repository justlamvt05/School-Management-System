import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/token_manager.dart';
import '../model/api_response.dart';
import '../model/application_item.dart';
import '../model/event_item.dart';
import '../model/class_grade_response.dart';
import '../model/classroom_response.dart';
import '../model/teacher_grade_request.dart';
import '../model/schedule_response.dart';
import '../model/teacher_student_attendance_response.dart';
import '../model/teacher_take_attendance_request.dart';
import 'auth_controller.dart';

class TeacherController {
  static const String baseUrl = "http://localhost:8080/api/teacher";

  final String token;

  TeacherController({required this.token});

  Map<String, String> get _headers => {
    "Content-Type": "application/json",
    "Authorization":
    "Bearer ${TokenManager.instance.token.isNotEmpty ? TokenManager.instance.token : token}",
  };

  Future<http.Response> _getWithRetry(String url) async {
    var response = await http.get(
      Uri.parse(url),
      headers: _headers,
    );

    if (response.statusCode == 401) {
      final authController = AuthController();

      final refresh = await authController.refreshToken(
        TokenManager.instance.refreshToken,
      );

      if (refresh.status && refresh.data != null) {
        TokenManager.instance.token = refresh.data!.accessToken;
        TokenManager.instance.refreshToken = refresh.data!.refreshToken;

        response = await http.get(
          Uri.parse(url),
          headers: _headers,
        );
      }
    }

    return response;
  }

  Future<http.Response> _postWithRetry(
      String url,
      Map<String, dynamic> body,
      ) async {
    var response = await http.post(
      Uri.parse(url),
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      final authController = AuthController();

      final refresh = await authController.refreshToken(
        TokenManager.instance.refreshToken,
      );

      if (refresh.status && refresh.data != null) {
        TokenManager.instance.token = refresh.data!.accessToken;
        TokenManager.instance.refreshToken = refresh.data!.refreshToken;

        response = await http.post(
          Uri.parse(url),
          headers: _headers,
          body: jsonEncode(body),
        );
      }
    }

    return response;
  }

  Future<http.Response> _putWithRetry(
      String url,
      Map<String, dynamic> body,
      ) async {
    var response = await http.put(
      Uri.parse(url),
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      final authController = AuthController();

      final refresh = await authController.refreshToken(
        TokenManager.instance.refreshToken,
      );

      if (refresh.status && refresh.data != null) {
        TokenManager.instance.token = refresh.data!.accessToken;
        TokenManager.instance.refreshToken = refresh.data!.refreshToken;

        response = await http.put(
          Uri.parse(url),
          headers: _headers,
          body: jsonEncode(body),
        );
      }
    }

    return response;
  }

  // ========================= Schedule =========================

  Future<ApiResponse<List<ScheduleItem>>> getSchedules() async {
    final response = await _getWithRetry("$baseUrl/schedules");

    return ApiResponse<List<ScheduleItem>>.fromJson(
      jsonDecode(response.body),
          (data) => (data as List)
          .map((e) => ScheduleItem.fromJson(e))
          .toList(),
    );
  }

  Future<ApiResponse<List<ScheduleItem>>> getSchedulesByDay(
      String day) async {
    final response = await _getWithRetry(
      "$baseUrl/schedules/day/$day",
    );

    return ApiResponse<List<ScheduleItem>>.fromJson(
      jsonDecode(response.body),
          (data) => (data as List)
          .map((e) => ScheduleItem.fromJson(e))
          .toList(),
    );
  }

  // ========================= Homeroom Grades =========================
  
  Future<ApiResponse<List<ClassGradeResponse>>> getHomeroomGrades() async {
    final response = await _getWithRetry(
      "$baseUrl/homeroom/grades",
    );
  
    return ApiResponse<List<ClassGradeResponse>>.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)),
          (data) => (data as List)
          .map((e) => ClassGradeResponse.fromJson(e))
          .toList(),
    );
  }
  
  Future<ApiResponse<List<ClassGradeResponse>>> getHomeroomGradesBySemester(
      int semesterId) async {
    final response = await _getWithRetry(
      "$baseUrl/homeroom/grades/semester/$semesterId",
    );
  
    return ApiResponse<List<ClassGradeResponse>>.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)),
          (data) => (data as List)
          .map((e) => ClassGradeResponse.fromJson(e))
          .toList(),
    );
  }

  // ========================= Classes =========================
  
  Future<ApiResponse<List<ClassRoomResponse>>> getTeachingClasses() async {
    final response = await _getWithRetry(
      "$baseUrl/classes",
    );
  
    return ApiResponse<List<ClassRoomResponse>>.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)),
          (data) => (data as List)
          .map((e) => ClassRoomResponse.fromJson(e))
          .toList(),
    );
  }

  Future<ApiResponse<List<ClassGradeResponse>>> getStudentsGradesByClassAndSemester(
      int classId, int semesterId) async {
    final response = await _getWithRetry(
      "$baseUrl/classes/$classId/students?semesterId=$semesterId",
    );
  
    return ApiResponse<List<ClassGradeResponse>>.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)),
          (data) => (data as List)
          .map((e) => ClassGradeResponse.fromJson(e))
          .toList(),
    );
  }
  
  // ========================= Grade =========================
  
  Future<ApiResponse<dynamic>> inputGrade(
      TeacherGradeRequest request) async {
    final response = await _postWithRetry(
      "$baseUrl/grades",
      request.toJson(),
    );
  
    return ApiResponse<dynamic>.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)),
          (data) => data,
    );
  }
  
  Future<ApiResponse<dynamic>> updateGrade(
      int id,
      TeacherGradeRequest request,
      ) async {
    final response = await _putWithRetry(
      "$baseUrl/grades/$id",
      request.toJson(),
    );
  
    return ApiResponse<dynamic>.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)),
          (data) => data,
    );
  }

  // ========================= Attendance =========================

  Future<ApiResponse<List<TeacherStudentAttendanceResponse>>> getStudentsForAttendance(
      int classId, String date, int period) async {
    final response = await _getWithRetry(
      "$baseUrl/attendances/classes/$classId?date=$date&period=$period",
    );

    return ApiResponse<List<TeacherStudentAttendanceResponse>>.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)),
          (data) => (data as List)
          .map((e) => TeacherStudentAttendanceResponse.fromJson(e))
          .toList(),
    );
  }

  Future<ApiResponse<dynamic>> takeAttendance(
      TeacherTakeAttendanceRequest request) async {
    final response = await _postWithRetry(
      "$baseUrl/attendances",
      request.toJson(),
    );

    return ApiResponse<dynamic>.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)),
          (data) => data,
    );
  }
}