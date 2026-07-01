package com.lamthoncoding.myfschoolse1913be.controller;

import com.lamthoncoding.myfschoolse1913be.payload.response.ApiResponse;
import com.lamthoncoding.myfschoolse1913be.payload.response.AttendanceMonthResponse;
import com.lamthoncoding.myfschoolse1913be.payload.response.AttendanceResponse;
import com.lamthoncoding.myfschoolse1913be.payload.response.ParentStudentResponse;
import com.lamthoncoding.myfschoolse1913be.security.service.UserDetailsImpl;
import com.lamthoncoding.myfschoolse1913be.service.AttendanceService;
import com.lamthoncoding.myfschoolse1913be.service.GradeService;
import com.lamthoncoding.myfschoolse1913be.service.ParentService;
import com.lamthoncoding.myfschoolse1913be.service.ScheduleService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/parent")
@RequiredArgsConstructor
public class ParentController {

    private final ParentService parentService;
    private final GradeService gradeService;
    private final AttendanceService attendanceService;
    private final ScheduleService scheduleService;

    /**
     * Danh sách con của phụ huynh
     */
    @GetMapping("/children")
    public List<ParentStudentResponse> getMyChildren (
            @AuthenticationPrincipal UserDetailsImpl userDetails
    ) {
        return parentService.getMyChildren(userDetails.getUserId());
    }

    @GetMapping("/students/{studentId}/class/{classId}/months")
    public ApiResponse<List<AttendanceMonthResponse>> getAttendanceMonths(
            @PathVariable Long studentId,
            @PathVariable Long classId,
            @AuthenticationPrincipal UserDetailsImpl userDetails
    ) {

        return ApiResponse.success(
                attendanceService.getAttendanceMonths(classId, studentId)
        );
    }

    @GetMapping("/students/{studentId}/class/{classId}/my")
    public ApiResponse<List<AttendanceResponse>> getAttendanceByStudent(
            @PathVariable Long studentId,
            @PathVariable Long classId,
            @RequestParam Integer year,
            @RequestParam Integer month,
            @AuthenticationPrincipal UserDetailsImpl userDetails
    ) {
        return ApiResponse.success(
                attendanceService.getAttendanceByStudent(classId, studentId, year, month)
        );
    }
}