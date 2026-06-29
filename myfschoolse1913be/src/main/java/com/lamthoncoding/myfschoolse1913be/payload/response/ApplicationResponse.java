package com.lamthoncoding.myfschoolse1913be.payload.response;

import com.lamthoncoding.myfschoolse1913be.contraints.ApplicationStatus;
import com.lamthoncoding.myfschoolse1913be.contraints.ApplicationType;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
@Setter
@Builder
public class ApplicationResponse {

    private Long id;
    private Long studentId;
    private String studentName;
    private ApplicationType type;
    private LocalDate fromDate;
    private LocalDate toDate;
    private String reason;
    private String attachmentUrl;
    private ApplicationStatus status;
    private String responseMessage;
    private String reviewedBy;
    private LocalDateTime createdAt;
    private LocalDateTime reviewedAt;
}
