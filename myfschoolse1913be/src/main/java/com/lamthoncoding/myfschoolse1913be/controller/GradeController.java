package com.lamthoncoding.myfschoolse1913be.controller;

import com.lamthoncoding.myfschoolse1913be.payload.response.ApiResponse;
import com.lamthoncoding.myfschoolse1913be.service.GradeService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/student/grades")
public class GradeController {

    private final GradeService gradeService;

    @GetMapping("/{studentId}")
    public ApiResponse<?> getGrades(
            @PathVariable Long studentId) {

        return ApiResponse.success(
                gradeService.getStudentGrades(studentId));
    }

    @GetMapping("/{studentId}/semester/{semesterId}")
    public ApiResponse<?> getGradesBySemester(
            @PathVariable Long studentId,
            @PathVariable Long semesterId) {

        return ApiResponse.success(
                gradeService.getStudentGradesBySemester(studentId, semesterId));
    }

    @GetMapping("/{studentId}/classes")
    public ApiResponse<?> getStudentClassHistory(
            @PathVariable Long studentId) {

        return ApiResponse.success(
                gradeService.getStudentClassHistory(studentId));
    }

    @GetMapping("/{studentId}/school-year/{schoolYear}/semester/{semesterId}")
    public ApiResponse<?> getGradesBySchoolYearAndSemester(
            @PathVariable Long studentId,
            @PathVariable String schoolYear,
            @PathVariable Long semesterId) {

        return ApiResponse.success(
                gradeService.getStudentGradesBySchoolYearAndSemester(studentId, schoolYear, semesterId));
    }
}
