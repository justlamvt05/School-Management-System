package com.lamthoncoding.myfschoolse1913be.controller;

import com.lamthoncoding.myfschoolse1913be.payload.response.ApiResponse;
import com.lamthoncoding.myfschoolse1913be.security.service.UserDetailsImpl;
import com.lamthoncoding.myfschoolse1913be.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    /**
     * GET /notifications/my
     * Lấy tất cả notification của user hiện tại, sắp xếp mới nhất trước.
     */
    @GetMapping("/my")
    public ApiResponse<?> getMyNotifications(
            @AuthenticationPrincipal UserDetailsImpl userDetails) {

        return ApiResponse.success(
                notificationService.getMyNotifications(userDetails.getUserId()));
    }

    /**
     * GET /notifications/unread-count
     * Trả về số lượng notification chưa đọc.
     */
    @GetMapping("/unread-count")
    public ApiResponse<?> getUnreadCount(
            @AuthenticationPrincipal UserDetailsImpl userDetails) {

        return ApiResponse.success(
                notificationService.getUnreadCount(userDetails.getUserId()));
    }

    /**
     * PUT /notifications/{id}/read
     * Đánh dấu một notification đã đọc.
     */
    @PutMapping("/{id}/read")
    public ApiResponse<?> markAsRead(
            @PathVariable Long id,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {

        return ApiResponse.success(
                notificationService.markAsRead(id, userDetails.getUserId()));
    }

    /**
     * PUT /notifications/read-all
     * Đánh dấu tất cả notification đã đọc.
     */
    @PutMapping("/read-all")
    public ApiResponse<?> markAllAsRead(
            @AuthenticationPrincipal UserDetailsImpl userDetails) {

        notificationService.markAllAsRead(userDetails.getUserId());
        return ApiResponse.success();
    }
}
