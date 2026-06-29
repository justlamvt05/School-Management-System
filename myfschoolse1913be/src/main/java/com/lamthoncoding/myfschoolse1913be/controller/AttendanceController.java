package com.lamthoncoding.myfschoolse1913be.controller;


import com.lamthoncoding.myfschoolse1913be.payload.response.ApiResponse;
import com.lamthoncoding.myfschoolse1913be.payload.response.AttendanceMonthResponse;
import com.lamthoncoding.myfschoolse1913be.payload.response.AttendanceResponse;
import com.lamthoncoding.myfschoolse1913be.security.service.UserDetailsImpl;
import com.lamthoncoding.myfschoolse1913be.service.AttendanceService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/student/attendances")
public class AttendanceController {

    private final AttendanceService attendanceService;

    @GetMapping("/class/{classId}")
    public ApiResponse<List<AttendanceResponse>> getAttendanceByClass(
            @PathVariable Long classId,
            @RequestParam
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
            LocalDate date
    ) {

        return ApiResponse.success(attendanceService.getAttendanceByClass(
                classId,
                date));
    }


    @GetMapping("/class/{classId}/my")
    public ApiResponse<List<AttendanceResponse>> getAttendanceByStudent(
            @PathVariable Long classId,
            @RequestParam Integer year,
            @RequestParam Integer month,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {

        Long studentId = attendanceService.studentId(userDetails.getUserId());
        return ApiResponse.success(attendanceService.getAttendanceByStudent(
                classId,
                studentId,
                year,
                month));
    }

    @GetMapping("/class/{classId}/months")
    public ApiResponse<List<AttendanceMonthResponse>> getAttendanceMonths(
            @PathVariable Long classId,
            @AuthenticationPrincipal UserDetailsImpl userDetails
    ) {

        Long studentId =
                attendanceService.studentId(userDetails.getUserId());

        return ApiResponse.success(
                attendanceService.getAttendanceMonths(
                        classId,
                        studentId
                )
        );
    }

}