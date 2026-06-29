package com.lamthoncoding.myfschoolse1913be.controller;

import com.lamthoncoding.myfschoolse1913be.payload.request.TeacherApplicationRequest;
import com.lamthoncoding.myfschoolse1913be.payload.request.TeacherGradeRequest;
import com.lamthoncoding.myfschoolse1913be.payload.response.ApiResponse;
import com.lamthoncoding.myfschoolse1913be.security.service.UserDetailsImpl;
import com.lamthoncoding.myfschoolse1913be.service.TeacherService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.DayOfWeek;
import java.time.LocalDate;

@RestController
@RequestMapping("/teacher")
@RequiredArgsConstructor
public class TeacherController {

    private final TeacherService teacherService;

    // ==================== LỊCH DẠY ====================

    /**
     * GET /teacher/schedules
     * Lấy toàn bộ lịch dạy của giáo viên hiện tại.
     */
    @GetMapping("/schedules")
    public ApiResponse<?> getMySchedule(
            @AuthenticationPrincipal UserDetailsImpl userDetails) {

        return ApiResponse.success(
                teacherService.getMySchedule(userDetails.getUserId()));
    }

    /**
     * GET /teacher/schedules/day/{day}
     * Lấy lịch dạy theo ngày trong tuần.
     */
    @GetMapping("/schedules/day/{day}")
    public ApiResponse<?> getMyScheduleByDay(
            @PathVariable DayOfWeek day,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {

        return ApiResponse.success(
                teacherService.getMyScheduleByDay(userDetails.getUserId(), day));
    }

    // ==================== ĐIỂM LỚP CHỦ NHIỆM ====================

    /**
     * GET /teacher/homeroom/grades
     * Xem điểm tất cả học sinh trong lớp chủ nhiệm.
     */
    @GetMapping("/homeroom/grades")
    public ApiResponse<?> getHomeroomClassGrades(
            @AuthenticationPrincipal UserDetailsImpl userDetails) {

        return ApiResponse.success(
                teacherService.getHomeroomClassGrades(userDetails.getUserId()));
    }

    /**
     * GET /teacher/homeroom/grades/semester/{semesterId}
     * Xem điểm lớp chủ nhiệm theo học kỳ.
     */
    @GetMapping("/homeroom/grades/semester/{semesterId}")
    public ApiResponse<?> getHomeroomClassGradesBySemester(
            @PathVariable Long semesterId,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {

        return ApiResponse.success(
                teacherService.getHomeroomClassGradesBySemester(
                        userDetails.getUserId(), semesterId));
    }

    // ==================== LỚP GIẢNG DẠY ====================

    /**
     * GET /teacher/classes
     * Lấy danh sách các lớp mà giáo viên giảng dạy.
     */
    @GetMapping("/classes")
    public ApiResponse<?> getTeachingClasses(
            @AuthenticationPrincipal UserDetailsImpl userDetails) {

        return ApiResponse.success(
                teacherService.getTeachingClasses(userDetails.getUserId()));
    }

    /**
     * GET /teacher/classes/{classId}/students?semesterId={semesterId}
     * Lấy danh sách học sinh của một lớp kèm theo điểm của môn giáo viên dạy trong học kỳ.
     */
    @GetMapping("/classes/{classId}/students")
    public ApiResponse<?> getStudentsGradesByClassAndSemester(
            @PathVariable Long classId,
            @RequestParam Long semesterId,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {

        return ApiResponse.success(
                teacherService.getStudentsGradesByClassAndSemester(
                        userDetails.getUserId(), classId, semesterId));
    }

    // ==================== ĐƠN ====================

    /**
     * POST /teacher/applications
     * Giáo viên tạo đơn mới.
     */
    @PostMapping("/applications")
    public ApiResponse<?> createApplication(
            @Valid @RequestBody TeacherApplicationRequest request,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {

        return ApiResponse.create(
                teacherService.createApplication(request, userDetails.getUserId()));
    }

    /**
     * GET /teacher/applications
     * Lấy danh sách đơn của giáo viên hiện tại.
     */
    @GetMapping("/applications")
    public ApiResponse<?> getMyApplications(
            @AuthenticationPrincipal UserDetailsImpl userDetails) {

        return ApiResponse.success(
                teacherService.getMyApplications(userDetails.getUserId()));
    }

    /**
     * GET /teacher/applications/{id}
     * Xem chi tiết đơn của giáo viên.
     */
    @GetMapping("/applications/{id}")
    public ApiResponse<?> getMyApplicationById(
            @PathVariable Long id,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {

        return ApiResponse.success(
                teacherService.getMyApplicationById(id, userDetails.getUserId()));
    }

    // ==================== SỰ KIỆN ====================

    /**
     * GET /teacher/events
     * Xem các sự kiện (ALL + TEACHER).
     */
    @GetMapping("/events")
    public ApiResponse<?> getEvents() {

        return ApiResponse.success(
                teacherService.getEvents());
    }

    // ==================== NHẬP ĐIỂM ====================

    /**
     * POST /teacher/grades
     * Nhập điểm cho học sinh (chỉ môn GV dạy).
     */
    @PostMapping("/grades")
    public ApiResponse<?> inputGrade(
            @Valid @RequestBody TeacherGradeRequest request,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {

        return ApiResponse.create(
                teacherService.inputGrade(request, userDetails.getUserId()));
    }

    /**
     * PUT /teacher/grades/{id}
     * Cập nhật điểm đã nhập (chỉ môn GV dạy).
     */
    @PutMapping("/grades/{id}")
    public ApiResponse<?> updateGrade(
            @PathVariable Long id,
            @Valid @RequestBody TeacherGradeRequest request,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {

        return ApiResponse.success(
                teacherService.updateGrade(id, request, userDetails.getUserId()));
    }

    // ==================== ĐIỂM DANH ====================

    /**
     * GET /teacher/attendances/classes/{classId}
     * Lấy danh sách học sinh của lớp để điểm danh (kèm trạng thái đã điểm danh nếu có)
     */
    @GetMapping("/attendances/classes/{classId}")
    public ApiResponse<?> getStudentsForAttendance(
            @PathVariable Long classId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            @RequestParam Integer period,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {

        return ApiResponse.success(
                teacherService.getStudentsForAttendance(userDetails.getUserId(), classId, date, period));
    }

    /**
     * POST /teacher/attendances
     * Gửi danh sách điểm danh
     */
    @PostMapping("/attendances")
    public ApiResponse<?> takeAttendance(
            @Valid @RequestBody com.lamthoncoding.myfschoolse1913be.payload.request.TeacherTakeAttendanceRequest request,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {

        teacherService.takeAttendance(userDetails.getUserId(), request);
        return ApiResponse.success("Attendance saved successfully");
    }
}
