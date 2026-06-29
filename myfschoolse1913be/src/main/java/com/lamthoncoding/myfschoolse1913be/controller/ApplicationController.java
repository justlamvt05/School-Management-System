package com.lamthoncoding.myfschoolse1913be.controller;

import com.lamthoncoding.myfschoolse1913be.payload.request.ApplicationRequest;
import com.lamthoncoding.myfschoolse1913be.payload.response.ApiResponse;
import com.lamthoncoding.myfschoolse1913be.security.service.UserDetailsImpl;
import com.lamthoncoding.myfschoolse1913be.service.ApplicationService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/applications")
@RequiredArgsConstructor
public class ApplicationController {

    private final ApplicationService applicationService;

    /**
     * POST /applications
     */
    @PostMapping
    public ApiResponse<?> createApplication(
            @Valid @RequestBody ApplicationRequest request,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {

        return ApiResponse.create(
                applicationService.createApplication(request, userDetails.getUserId()));
    }

    /**
     * GET /applications/my
     */
    @GetMapping("/my")
    public ApiResponse<?> getMyApplications(
            @AuthenticationPrincipal UserDetailsImpl userDetails) {

        return ApiResponse.success(
                applicationService.getMyApplications(userDetails.getUserId()));
    }

    /**
     * GET /applications/my/{id}
     */
    @GetMapping("/my/{id}")
    public ApiResponse<?> getMyApplicationById(
            @PathVariable Long id,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {

        return ApiResponse.success(
                applicationService.getMyApplicationById(id, userDetails.getUserId()));
    }
}
