package com.lamthoncoding.myfschoolse1913be.service;

import com.lamthoncoding.myfschoolse1913be.payload.response.NotificationResponse;

import java.util.List;
import java.util.Map;

public interface NotificationService {

    List<NotificationResponse> getMyNotifications(Long currentUserId);

    Map<String, Long> getUnreadCount(Long currentUserId);

    NotificationResponse markAsRead(Long id, Long currentUserId);

    void markAllAsRead(Long currentUserId);
}
