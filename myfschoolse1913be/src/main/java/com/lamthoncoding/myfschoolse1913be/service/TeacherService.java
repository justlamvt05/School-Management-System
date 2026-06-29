package com.lamthoncoding.myfschoolse1913be.service;

import com.lamthoncoding.myfschoolse1913be.payload.request.TeacherApplicationRequest;
import com.lamthoncoding.myfschoolse1913be.payload.request.TeacherGradeRequest;
import com.lamthoncoding.myfschoolse1913be.payload.request.TeacherTakeAttendanceRequest;
import com.lamthoncoding.myfschoolse1913be.payload.response.*;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.List;

public interface TeacherService {

    // Lịch dạy
    List<TeacherScheduleResponse> getMySchedule(Long currentUserId);

    List<TeacherScheduleResponse> getMyScheduleByDay(Long currentUserId, DayOfWeek day);

    // Điểm lớp chủ nhiệm
    List<ClassGradeResponse> getHomeroomClassGrades(Long currentUserId);

    List<ClassGradeResponse> getHomeroomClassGradesBySemester(Long currentUserId, Long semesterId);

    // Lớp giảng dạy
    List<ClassRoomResponse> getTeachingClasses(Long currentUserId);

    List<ClassGradeResponse> getStudentsGradesByClassAndSemester(Long currentUserId, Long classId, Long semesterId);

    // Đơn
    ApplicationResponse createApplication(TeacherApplicationRequest request, Long currentUserId);

    List<ApplicationResponse> getMyApplications(Long currentUserId);

    ApplicationResponse getMyApplicationById(Long id, Long currentUserId);

    // Sự kiện
    List<EventResponse> getEvents();

    // Nhập điểm
    GradeResponse inputGrade(TeacherGradeRequest request, Long currentUserId);

    GradeResponse updateGrade(Long gradeId, TeacherGradeRequest request, Long currentUserId);

    // Điểm danh
    List<TeacherStudentAttendanceResponse> getStudentsForAttendance(Long currentUserId, Long classId, LocalDate date, Integer period);

    void takeAttendance(Long currentUserId, TeacherTakeAttendanceRequest request);
}
