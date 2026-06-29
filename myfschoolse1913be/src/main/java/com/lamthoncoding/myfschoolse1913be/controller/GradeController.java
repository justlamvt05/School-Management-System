package com.lamthoncoding.myfschoolse1913be.controller;

import com.lamthoncoding.myfschoolse1913be.payload.response.ApiResponse;
import com.lamthoncoding.myfschoolse1913be.service.GradeService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

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
}
