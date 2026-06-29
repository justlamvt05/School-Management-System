package com.lamthoncoding.myfschoolse1913be.payload.response;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@Builder
public class NotificationResponse {

    private Long id;
    private Long userId;
    private String title;
    private String content;
    private Boolean isRead;
    private LocalDateTime createdAt;
}
