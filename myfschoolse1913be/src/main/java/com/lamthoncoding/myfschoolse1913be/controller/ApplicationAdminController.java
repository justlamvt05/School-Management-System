package com.lamthoncoding.myfschoolse1913be.controller;

import com.lamthoncoding.myfschoolse1913be.contraints.ApplicationStatus;
import com.lamthoncoding.myfschoolse1913be.contraints.ApplicationType;
import com.lamthoncoding.myfschoolse1913be.payload.request.ReviewRequest;
import com.lamthoncoding.myfschoolse1913be.payload.response.ApiResponse;
import com.lamthoncoding.myfschoolse1913be.security.service.UserDetailsImpl;
import com.lamthoncoding.myfschoolse1913be.service.ApplicationService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/admin/applications")
@RequiredArgsConstructor
public class ApplicationAdminController {

    private final ApplicationService applicationService;

    /**
     * GET /admin/applications
     * Lấy toàn bộ đơn. Cho phép filter theo status và type.
     */
    @GetMapping
    public ApiResponse<?> getAllApplications(
            @RequestParam(required = false) ApplicationStatus status,
            @RequestParam(required = false) ApplicationType type) {

        return ApiResponse.success(
                applicationService.getAllApplications(status, type));
    }

    /**
     * GET /admin/applications/{id}
     * Xem chi tiết đơn.
     */
    @GetMapping("/{id}")
    public ApiResponse<?> getApplicationById(@PathVariable Long id) {
        return ApiResponse.success(applicationService.getApplicationById(id));
    }

    /**
     * PUT /admin/applications/{id}/approve
     * Duyệt đơn.
     */
    @PutMapping("/{id}/approve")
    public ApiResponse<?> approveApplication(
            @PathVariable Long id,
            @Valid @RequestBody ReviewRequest request,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {

        return ApiResponse.success(
                applicationService.approveApplication(id, request, userDetails.getUserId()));
    }

    /**
     * PUT /admin/applications/{id}/reject
     * Từ chối đơn.
     */
    @PutMapping("/{id}/reject")
    public ApiResponse<?> rejectApplication(
            @PathVariable Long id,
            @Valid @RequestBody ReviewRequest request,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {

        return ApiResponse.success(
                applicationService.rejectApplication(id, request, userDetails.getUserId()));
    }
}
