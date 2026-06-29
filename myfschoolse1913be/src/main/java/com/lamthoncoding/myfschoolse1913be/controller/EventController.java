package com.lamthoncoding.myfschoolse1913be.controller;

import com.lamthoncoding.myfschoolse1913be.payload.response.ApiResponse;
import com.lamthoncoding.myfschoolse1913be.service.EventService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/events")
@RequiredArgsConstructor
public class EventController {

    private final EventService eventService;

    /**
     * GET /events
     * Lấy tất cả sự kiện (ALL + STUDENT).
     * Endpoint cho tất cả user đã authenticated.
     */
    @GetMapping
    public ApiResponse<?> getEvents() {
        return ApiResponse.success(eventService.getEventsForStudent());
    }

    /**
     * GET /events/all
     * Lấy tất cả sự kiện (bao gồm cả TEACHER-only).
     */
    @GetMapping("/all")
    public ApiResponse<?> getAllEvents() {
        return ApiResponse.success(eventService.getAllEvents());
    }
}
