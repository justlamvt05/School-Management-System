package com.lamthoncoding.myfschoolse1913be.controller;

import com.lamthoncoding.myfschoolse1913be.payload.response.ApiResponse;
import com.lamthoncoding.myfschoolse1913be.service.ScheduleService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.DayOfWeek;

@RestController
@RequiredArgsConstructor
@RequestMapping("/student/schedules")
public class ScheduleController {

    private final ScheduleService scheduleService;

    @GetMapping("/class/{classId}")
    public ApiResponse<?> getScheduleByClass(
            @PathVariable Long classId) {

        return ApiResponse.success(
                scheduleService.getScheduleByClass(classId));
    }

    @GetMapping("/class/{classId}/day/{day}")
    public ApiResponse<?> getScheduleByClassAndDay(
            @PathVariable Long classId,
            @PathVariable DayOfWeek day) {

        return ApiResponse.success(
                scheduleService.getScheduleByClassAndDay(classId, day));
    }
}
