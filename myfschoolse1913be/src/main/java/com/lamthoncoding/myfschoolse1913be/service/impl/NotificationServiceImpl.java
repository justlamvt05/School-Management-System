package com.lamthoncoding.myfschoolse1913be.service.impl;

import com.lamthoncoding.myfschoolse1913be.entity.Notification;
import com.lamthoncoding.myfschoolse1913be.exception.handlers.EntityNotFound;
import com.lamthoncoding.myfschoolse1913be.payload.response.NotificationResponse;
import com.lamthoncoding.myfschoolse1913be.repository.NotificationRepository;
import com.lamthoncoding.myfschoolse1913be.service.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class NotificationServiceImpl implements NotificationService {

    private final NotificationRepository notificationRepository;

    @Override
    public List<NotificationResponse> getMyNotifications(Long currentUserId) {
        log.info("Fetching notifications for userId={}", currentUserId);
        return notificationRepository.findByUserIdOrderByCreatedAtDesc(currentUserId)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Override
    public Map<String, Long> getUnreadCount(Long currentUserId) {
        log.info("Counting unread notifications for userId={}", currentUserId);
        long count = notificationRepository.countByUserIdAndIsRead(currentUserId, false);
        return Map.of("count", count);
    }

    @Override
    @Transactional
    public NotificationResponse markAsRead(Long id, Long currentUserId) {
        log.info("Marking notification id={} as read for userId={}", id, currentUserId);
        Notification notification = notificationRepository.findByIdAndUserId(id, currentUserId)
                .orElseThrow(() -> new EntityNotFound("Không tìm thấy thông báo với id=" + id));
        notification.setIsRead(true);
        return toResponse(notificationRepository.save(notification));
    }

    @Override
    @Transactional
    public void markAllAsRead(Long currentUserId) {
        log.info("Marking all notifications as read for userId={}", currentUserId);
        List<Notification> unread = notificationRepository.findByUserIdAndIsRead(currentUserId, false);
        unread.forEach(n -> n.setIsRead(true));
        notificationRepository.saveAll(unread);
    }

    private NotificationResponse toResponse(Notification notification) {
        return NotificationResponse.builder()
                .id(notification.getId())
                .userId(notification.getUser() != null ? notification.getUser().getId() : null)
                .title(notification.getTitle())
                .content(notification.getContent())
                .isRead(notification.getIsRead())
                .createdAt(notification.getCreatedAt())
                .build();
    }
}
