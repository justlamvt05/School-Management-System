package com.lamthoncoding.myfschoolse1913be.service.impl;

import com.lamthoncoding.myfschoolse1913be.contraints.ApplicationStatus;
import com.lamthoncoding.myfschoolse1913be.contraints.ApplicationType;
import com.lamthoncoding.myfschoolse1913be.entity.*;
import com.lamthoncoding.myfschoolse1913be.exception.handlers.AccessDeniedException;
import com.lamthoncoding.myfschoolse1913be.exception.handlers.ApplicationAlreadyReviewedException;
import com.lamthoncoding.myfschoolse1913be.exception.handlers.EntityNotFound;
import com.lamthoncoding.myfschoolse1913be.exception.handlers.InvalidInputException;
import com.lamthoncoding.myfschoolse1913be.payload.request.ApplicationRequest;
import com.lamthoncoding.myfschoolse1913be.payload.request.ReviewRequest;
import com.lamthoncoding.myfschoolse1913be.payload.response.ApplicationResponse;
import com.lamthoncoding.myfschoolse1913be.repository.*;
import com.lamthoncoding.myfschoolse1913be.service.ApplicationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class ApplicationServiceImpl implements ApplicationService {

    private final ApplicationRepository applicationRepository;
    private final StudentRepository studentRepository;
    private final TeacherRepository teacherRepository;
    private final UserRepository userRepository;
    private final NotificationRepository notificationRepository;

    // ==================== STUDENT & TEACHER APIs ====================

    @Override
    @Transactional
    public ApplicationResponse createApplication(ApplicationRequest request, Long currentUserId) {
        log.info("UserId={} is creating an application of type={}", currentUserId, request.getType());

        validateApplicationDate(request);

        Application application = buildApplication(request, currentUserId);
        Application saved = applicationRepository.save(application);

        log.info("Application created successfully with id={}", saved.getId());
        return toResponse(saved);
    }

    private Application buildApplication(ApplicationRequest request, Long currentUserId) {
        Application.ApplicationBuilder builder = baseBuilder(request);

        studentRepository.findByUserId(currentUserId)
                .ifPresentOrElse(
                        builder::student,
                        () -> builder.teacher(getTeacher(currentUserId))
                );

        return builder.build();
    }

    private Application.ApplicationBuilder baseBuilder(ApplicationRequest request) {
        return Application.builder()
                .type(request.getType())
                .fromDate(request.getFromDate())
                .toDate(request.getToDate())
                .reason(request.getReason())
                .attachmentUrl(request.getAttachmentUrl())
                .status(ApplicationStatus.PENDING)
                .createdAt(LocalDateTime.now());
    }

    private Teacher getTeacher(Long userId) {
        return teacherRepository.findByUserId(userId)
                .orElseThrow(() -> new EntityNotFound("Không tìm thấy giáo viên"));
    }

    private void validateApplicationDate(ApplicationRequest request) {
        LocalDate today = LocalDate.now();

        if (request.getFromDate().isBefore(today)) {
            throw new InvalidInputException("Ngày bắt đầu không được trước ngày hiện tại");
        }
        if (request.getFromDate().isAfter(request.getToDate())) {
            throw new InvalidInputException("Ngày bắt đầu không được sau ngày kết thúc");
        }
    }

    @Override
    public List<ApplicationResponse> getMyApplications(Long currentUserId) {
        log.info("UserId={} fetching their applications", currentUserId);

        // Ưu tiên kiểm tra Student trước, nếu không thì Teacher
        Optional<Student> studentOpt = studentRepository.findByUserId(currentUserId);
        if (studentOpt.isPresent()) {
            return applicationRepository.findByStudentIdOrderByCreatedAtDesc(studentOpt.get().getId())
                    .stream()
                    .map(this::toResponse)
                    .toList();
        }

        Teacher teacher = teacherRepository.findByUserId(currentUserId)
                .orElseThrow(() -> new EntityNotFound("Không tìm thấy thông tin người dùng"));

        return applicationRepository.findByTeacherIdOrderByCreatedAtDesc(teacher.getId())
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Override
    public ApplicationResponse getMyApplicationById(Long id, Long currentUserId) {
        log.info("UserId={} fetching application id={}", currentUserId, id);

        Optional<Student> studentOpt = studentRepository.findByUserId(currentUserId);
        if (studentOpt.isPresent()) {
            Application application = applicationRepository
                    .findByIdAndStudentId(id, studentOpt.get().getId())
                    .orElseThrow(() -> new AccessDeniedException("Bạn không có quyền xem đơn này"));
            return toResponse(application);
        }

        Teacher teacher = teacherRepository.findByUserId(currentUserId)
                .orElseThrow(() -> new EntityNotFound("Không tìm thấy thông tin người dùng"));

        Application application = applicationRepository
                .findByIdAndTeacherId(id, teacher.getId())
                .orElseThrow(() -> new AccessDeniedException("Bạn không có quyền xem đơn này"));

        return toResponse(application);
    }

    // ==================== ADMIN APIs ====================

    @Override
    public List<ApplicationResponse> getAllApplications(ApplicationStatus status, ApplicationType type) {
        log.info("Admin fetching all applications, filter: status={}, type={}", status, type);

        List<Application> applications;

        if (status != null && type != null) {
            applications = applicationRepository.findByStatusAndTypeOrderByCreatedAtDesc(status, type);
        } else if (status != null) {
            applications = applicationRepository.findByStatusOrderByCreatedAtDesc(status);
        } else if (type != null) {
            applications = applicationRepository.findByTypeOrderByCreatedAtDesc(type);
        } else {
            applications = applicationRepository.findAllByOrderByCreatedAtDesc();
        }

        return applications.stream()
                .map(this::toResponse)
                .toList();
    }

    @Override
    public ApplicationResponse getApplicationById(Long id) {
        log.info("Admin fetching application id={}", id);
        Application application = applicationRepository.findById(id)
                .orElseThrow(() -> new EntityNotFound("Không tìm thấy đơn yêu cầu với id=" + id));
        return toResponse(application);
    }

    @Override
    @Transactional
    public ApplicationResponse approveApplication(Long id, ReviewRequest request, Long adminUserId) {
        log.info("Admin userId={} approving application id={}", adminUserId, id);

        Application application = getAndValidatePendingApplication(id);
        User admin = getAdmin(adminUserId);

        application.setStatus(ApplicationStatus.APPROVED);
        application.setResponseMessage(request.getResponseMessage());
        application.setReviewedBy(admin);
        application.setReviewedAt(LocalDateTime.now());

        Application saved = applicationRepository.save(application);
        createNotification(saved, true);

        log.info("Application id={} approved", id);
        return toResponse(saved);
    }

    @Override
    @Transactional
    public ApplicationResponse rejectApplication(Long id, ReviewRequest request, Long adminUserId) {
        log.info("Admin userId={} rejecting application id={}", adminUserId, id);

        Application application = getAndValidatePendingApplication(id);
        User admin = getAdmin(adminUserId);

        application.setStatus(ApplicationStatus.REJECTED);
        application.setResponseMessage(request.getResponseMessage());
        application.setReviewedBy(admin);
        application.setReviewedAt(LocalDateTime.now());

        Application saved = applicationRepository.save(application);
        createNotification(saved, false);

        log.info("Application id={} rejected", id);
        return toResponse(saved);
    }

    // ==================== HELPER METHODS ====================

    private Application getAndValidatePendingApplication(Long id) {
        Application application = applicationRepository.findById(id)
                .orElseThrow(() -> new EntityNotFound("Không tìm thấy đơn yêu cầu với id=" + id));

        if (application.getStatus() != ApplicationStatus.PENDING) {
            throw new ApplicationAlreadyReviewedException("Đơn yêu cầu này đã được xử lý");
        }
        return application;
    }

    private User getAdmin(Long adminUserId) {
        return userRepository.findById(adminUserId)
                .orElseThrow(() -> new EntityNotFound("Không tìm thấy quản trị viên"));
    }

    /**
     * Gửi notification cho Student hoặc Teacher tùy theo loại application
     */
    private void createNotification(Application application, boolean approved) {
        User targetUser = resolveApplicantUser(application);
        String typeName = application.getType().name();

        String title = approved ? "Đơn được phê duyệt" : "Đơn bị từ chối";
        String content = approved
                ? "Đơn " + typeName + " của bạn đã được phê duyệt."
                : "Đơn " + typeName + " của bạn đã bị từ chối. Lý do: " + application.getResponseMessage();

        Notification notification = Notification.builder()
                .user(targetUser)
                .title(title)
                .content(content)
                .isRead(false)
                .createdAt(LocalDateTime.now())
                .build();

        notificationRepository.save(notification);
        log.info("Notification sent to userId={} for application id={}", targetUser.getId(), application.getId());
    }

    /**
     * Xác định User của người nộp đơn (Student hoặc Teacher)
     */
    private User resolveApplicantUser(Application application) {
        if (application.getStudent() != null) {
            return application.getStudent().getUser();
        }
        if (application.getTeacher() != null) {
            return application.getTeacher().getUser();
        }
        throw new EntityNotFound("Đơn yêu cầu không được liên kết với học sinh hoặc giáo viên nào");
    }

    private ApplicationResponse toResponse(Application application) {
        // Resolve applicant info (Student hoặc Teacher)
        Long applicantId = null;
        String applicantName = null;

        if (application.getStudent() != null) {
            applicantId = application.getStudent().getId();

            if (application.getStudent().getUser() != null) {
                applicantName = application.getStudent().getUser().getFullName();
            }
        } else if (application.getTeacher() != null) {
            applicantId = application.getTeacher().getId();
            if (application.getTeacher().getUser() != null) {
                applicantName = application.getTeacher().getUser().getFullName();
            }
        }

        String reviewedByName = application.getReviewedBy() != null
                ? application.getReviewedBy().getFullName()
                : null;

        return ApplicationResponse.builder()
                .id(application.getId())
                .studentId(applicantId)           // Giữ tên cũ hoặc đổi thành applicantId
                .studentName(applicantName)        // Giữ tên cũ hoặc đổi thành applicantName
                .type(application.getType())
                .fromDate(application.getFromDate())
                .toDate(application.getToDate())
                .reason(application.getReason())
                .attachmentUrl(application.getAttachmentUrl())
                .status(application.getStatus())
                .responseMessage(application.getResponseMessage())
                .reviewedBy(reviewedByName)
                .createdAt(application.getCreatedAt())
                .reviewedAt(application.getReviewedAt())
                .build();
    }
}