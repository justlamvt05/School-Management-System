package com.lamthoncoding.myfschoolse1913be.payload.response;

import com.lamthoncoding.myfschoolse1913be.contraints.EventTargetRole;
import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EventResponse {

    private Long id;

    private String title;

    private String description;

    private String location;

    private LocalDateTime startTime;

    private LocalDateTime endTime;

    private EventTargetRole targetRole;

    private String createdByName;
}
