package com.lamthoncoding.myfschoolse1913be.entity;

import com.lamthoncoding.myfschoolse1913be.contraints.ApplicationStatus;
import com.lamthoncoding.myfschoolse1913be.contraints.ApplicationType;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "applications")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Application {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Người gửi đơn (student hoặc teacher)
    @ManyToOne
    @JoinColumn(name = "student_id")
    private Student student;

    @ManyToOne
    @JoinColumn(name = "teacher_id")
    private Teacher teacher;

    // Loại đơn
    @Enumerated(EnumType.STRING)
    private ApplicationType type;

    // Từ ngày
    private LocalDate fromDate;

    // Đến ngày
    private LocalDate toDate;

    // Nội dung lý do
    @Column(columnDefinition = "TEXT")
    private String reason;

    // File minh chứng
    private String attachmentUrl;

    // Trạng thái
    @Enumerated(EnumType.STRING)
    private ApplicationStatus status;

    // Phản hồi của người duyệt
    @Column(columnDefinition = "TEXT")
    private String responseMessage;

    // Người duyệt
    @ManyToOne
    @JoinColumn(name = "reviewed_by")
    private User reviewedBy;

    private LocalDateTime createdAt;

    private LocalDateTime reviewedAt;
}
