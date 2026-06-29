package com.lamthoncoding.myfschoolse1913be.service.impl;

import com.lamthoncoding.myfschoolse1913be.contraints.ApplicationStatus;
import com.lamthoncoding.myfschoolse1913be.contraints.EventTargetRole;
import com.lamthoncoding.myfschoolse1913be.entity.*;
import com.lamthoncoding.myfschoolse1913be.exception.handlers.AccessDeniedException;
import com.lamthoncoding.myfschoolse1913be.exception.handlers.EntityNotFound;
import com.lamthoncoding.myfschoolse1913be.exception.handlers.InvalidInputException;
import com.lamthoncoding.myfschoolse1913be.payload.request.TeacherApplicationRequest;
import com.lamthoncoding.myfschoolse1913be.payload.request.TeacherGradeRequest;
import com.lamthoncoding.myfschoolse1913be.payload.request.TeacherTakeAttendanceRequest;
import com.lamthoncoding.myfschoolse1913be.payload.response.*;
import com.lamthoncoding.myfschoolse1913be.repository.*;
import com.lamthoncoding.myfschoolse1913be.service.TeacherService;
import com.lamthoncoding.myfschoolse1913be.contraints.AttendanceStatus;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.chrono.ChronoLocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class TeacherServiceImpl implements TeacherService {

    private final TeacherRepository teacherRepository;
    private final ScheduleRepository scheduleRepository;
    private final GradeRepository gradeRepository;
    private final ApplicationRepository applicationRepository;
    private final EventRepository eventRepository;
    private final StudentRepository studentRepository;
    private final SemesterRepository semesterRepository;
    private final AttendanceRepository attendanceRepository;
    private final ClassRoomRepository classRoomRepository;

    // ==================== HELPER ====================

    private Teacher getTeacherByUserId(Long userId) {
        return teacherRepository.findByUserId(userId)
                .orElseThrow(() -> new EntityNotFound("Teacher information not found"));
    }

    // ==================== LỊCH DẠY ====================

    @Override
    public List<TeacherScheduleResponse> getMySchedule(Long currentUserId) {
        log.info("Teacher userId={} fetching schedule", currentUserId);
        Teacher teacher = getTeacherByUserId(currentUserId);

        return scheduleRepository.findByTeacherId(teacher.getId())
                .stream()
                .map(this::toTeacherScheduleResponse)
                .toList();
    }

    @Override
    public List<TeacherScheduleResponse> getMyScheduleByDay(Long currentUserId, DayOfWeek day) {
        log.info("Teacher userId={} fetching schedule for day={}", currentUserId, day);
        Teacher teacher = getTeacherByUserId(currentUserId);

        return scheduleRepository.findByTeacherIdAndDayOfWeek(teacher.getId(), day)
                .stream()
                .map(this::toTeacherScheduleResponse)
                .toList();
    }

    // ==================== ĐIỂM LỚP CHỦ NHIỆM ====================

    @Override
    public List<ClassGradeResponse> getHomeroomClassGrades(Long currentUserId) {
        log.info("Teacher userId={} fetching homeroom class grades", currentUserId);
        Teacher teacher = getTeacherByUserId(currentUserId);

        if (teacher.getHomeroomClass() == null) {
            throw new AccessDeniedException("You are not the homeroom teacher of any class");
        }

        return gradeRepository.findByStudentClassRoomId(teacher.getHomeroomClass().getId())
                .stream()
                .map(this::toClassGradeResponse)
                .toList();
    }

    @Override
    public List<ClassGradeResponse> getHomeroomClassGradesBySemester(Long currentUserId, Long semesterId) {
        log.info("Teacher userId={} fetching homeroom class grades for semester={}", currentUserId, semesterId);
        Teacher teacher = getTeacherByUserId(currentUserId);

        if (teacher.getHomeroomClass() == null) {
            throw new AccessDeniedException("You are not the homeroom teacher of any class");
        }

        semesterRepository.findById(semesterId)
                .orElseThrow(() -> new EntityNotFound("Semester not found"));

        return gradeRepository.findByStudentClassRoomIdAndSemesterId(
                        teacher.getHomeroomClass().getId(), semesterId)
                .stream()
                .map(this::toClassGradeResponse)
                .toList();
    }

    // ==================== LỚP GIẢNG DẠY ====================

    @Override
    public List<ClassRoomResponse> getTeachingClasses(Long currentUserId) {
        log.info("Teacher userId={} fetching teaching classes", currentUserId);
        Teacher teacher = getTeacherByUserId(currentUserId);

        return scheduleRepository.findByTeacherId(teacher.getId())
                .stream()
                .map(Schedule::getClassRoom)
                .distinct()
                .map(cr -> ClassRoomResponse.builder()
                        .id(cr.getId())
                        .name(cr.getClassName())
                        .schoolYear(cr.getSchoolYear())
                        .build())
                .toList();
    }

    @Override
    public List<ClassGradeResponse> getStudentsGradesByClassAndSemester(Long currentUserId, Long classId, Long semesterId) {
        log.info("Teacher userId={} fetching students grades for classId={}, semesterId={}", currentUserId, classId, semesterId);
        Teacher teacher = getTeacherByUserId(currentUserId);

        // Verify if teacher actually teaches this class
        boolean teachesClass = scheduleRepository.findByTeacherId(teacher.getId())
                .stream()
                .anyMatch(s -> s.getClassRoom().getId().equals(classId));
        if (!teachesClass) {
            throw new AccessDeniedException("You are not assigned to teach this class");
        }

        Semester semester = semesterRepository.findById(semesterId)
                .orElseThrow(() -> new EntityNotFound("Semester not found"));

        List<Student> students = studentRepository.findByClassRoomId(classId);

        return students.stream().map(student -> {
            ClassGradeResponse response = ClassGradeResponse.builder()
                    .studentId(student.getId())
                    .studentName(student.getUser().getFullName())
                    .studentCode(student.getStudentCode())
                    .subjectId(teacher.getSubject().getId())
                    .subjectName(teacher.getSubject().getSubjectName())
                    .semesterName(semester.getSemesterName())
                    .build();

            gradeRepository.findByStudentIdAndSubjectIdAndSemesterId(student.getId(), teacher.getSubject().getId(), semesterId)
                    .ifPresent(grade -> {
                        response.setGradeId(grade.getId());
                        response.setOralScore(grade.getOralScore());
                        response.setScore15Min(grade.getScore15Min());
                        response.setScore1Period(grade.getScore1Period());
                        response.setFinalExam(grade.getFinalExam());
                        response.setAverageScore(grade.getAverageScore());
                    });

            return response;
        }).toList();
    }

    // ==================== ĐƠN ====================

    @Override
    @Transactional
    public ApplicationResponse createApplication(TeacherApplicationRequest request, Long currentUserId) {
        log.info("Teacher userId={} creating application type={}", currentUserId, request.getType());
        Teacher teacher = getTeacherByUserId(currentUserId);

        if (request.getFromDate().isBefore(ChronoLocalDate.from(LocalDate.now().atStartOfDay()))) {
            throw new InvalidInputException("The start date cannot be earlier than today");
        }

        if (request.getFromDate().isAfter(request.getToDate())) {
            throw  new InvalidInputException("The start date cannot be later than the end date");
        }

        Application application = Application.builder()
                .teacher(teacher)
                .type(request.getType())
                .fromDate(request.getFromDate())
                .toDate(request.getToDate())
                .reason(request.getReason())
                .attachmentUrl(request.getAttachmentUrl())
                .status(ApplicationStatus.PENDING)
                .createdAt(LocalDateTime.now())
                .build();

        Application saved = applicationRepository.save(application);
        log.info("Teacher application created with id={}", saved.getId());
        return toApplicationResponse(saved);
    }

    @Override
    public List<ApplicationResponse> getMyApplications(Long currentUserId) {
        log.info("Teacher userId={} fetching applications", currentUserId);
        Teacher teacher = getTeacherByUserId(currentUserId);

        return applicationRepository.findByTeacherId(teacher.getId())
                .stream()
                .map(this::toApplicationResponse)
                .toList();
    }

    @Override
    public ApplicationResponse getMyApplicationById(Long id, Long currentUserId) {
        log.info("Teacher userId={} fetching application id={}", currentUserId, id);
        Teacher teacher = getTeacherByUserId(currentUserId);

        Application application = applicationRepository.findByIdAndTeacherId(id, teacher.getId())
                .orElseThrow(() -> new AccessDeniedException("You are not authorized to view this application"));

        return toApplicationResponse(application);
    }

    // ==================== SỰ KIỆN ====================

    @Override
    public List<EventResponse> getEvents() {
        log.info("Teacher fetching events");
        List<EventTargetRole> roles = List.of(EventTargetRole.ALL, EventTargetRole.TEACHER);

        return eventRepository.findByTargetRoleInOrderByStartTimeDesc(roles)
                .stream()
                .map(this::toEventResponse)
                .toList();
    }

    // ==================== NHẬP ĐIỂM ====================

    @Override
    @Transactional
    public GradeResponse inputGrade(TeacherGradeRequest request, Long currentUserId) {
        log.info("Teacher userId={} inputting grade for student={}, subject={}, semester={}",
                currentUserId, request.getStudentId(), request.getSubjectId(), request.getSemesterId());

        Teacher teacher = getTeacherByUserId(currentUserId);

        // Kiểm tra học sinh tồn tại
        Student student = studentRepository.findById(request.getStudentId())
                .orElseThrow(() -> new EntityNotFound("Student not found"));

        // Kiểm tra học kỳ tồn tại
        Semester semester = semesterRepository.findById(request.getSemesterId())
                .orElseThrow(() -> new EntityNotFound("Semester not found"));

        // Kiểm tra GV có dạy môn này cho lớp của HS không
        List<Schedule> teacherSchedules = scheduleRepository
                .findByTeacherIdAndClassRoomIdAndSubjectId(
                        teacher.getId(),
                        student.getClassRoom().getId(),
                        request.getSubjectId());

        if (teacherSchedules.isEmpty()) {
            throw new AccessDeniedException(
                    "You are not assigned to teach this subject for this student's class");
        }

        // Kiểm tra đã có điểm chưa
        gradeRepository.findByStudentIdAndSubjectIdAndSemesterId(
                request.getStudentId(), request.getSubjectId(), request.getSemesterId()
        ).ifPresent(g -> {
            throw new InvalidInputException("A grade already exists. Please use the update grade function instead");
        });

        Subject subject = teacherSchedules.get(0).getSubject();

        // Tính điểm trung bình
        Double averageScore = calculateAverage(
                request.getOralScore(), request.getScore15Min(),
                request.getScore1Period(), request.getFinalExam());

        Grade grade = Grade.builder()
                .student(student)
                .subject(subject)
                .semester(semester)
                .oralScore(request.getOralScore())
                .score15Min(request.getScore15Min())
                .score1Period(request.getScore1Period())
                .finalExam(request.getFinalExam())
                .averageScore(averageScore)
                .build();

        Grade saved = gradeRepository.save(grade);
        log.info("Grade created with id={}", saved.getId());

        return toGradeResponse(saved);
    }

    @Override
    @Transactional
    public GradeResponse updateGrade(Long gradeId, TeacherGradeRequest request, Long currentUserId) {
        log.info("Teacher userId={} updating grade id={}", currentUserId, gradeId);

        Teacher teacher = getTeacherByUserId(currentUserId);

        Grade grade = gradeRepository.findById(gradeId)
                .orElseThrow(() -> new EntityNotFound("Grade record not found"));

        // Kiểm tra GV có dạy môn này cho lớp của HS không
        List<Schedule> teacherSchedules = scheduleRepository
                .findByTeacherIdAndClassRoomIdAndSubjectId(
                        teacher.getId(),
                        grade.getStudent().getClassRoom().getId(),
                        grade.getSubject().getId());

        if (teacherSchedules.isEmpty()) {
            throw new AccessDeniedException(
                    "User is unauthorized");
        }

        // Cập nhật điểm
        if (request.getOralScore() != null) grade.setOralScore(request.getOralScore());
        if (request.getScore15Min() != null) grade.setScore15Min(request.getScore15Min());
        if (request.getScore1Period() != null) grade.setScore1Period(request.getScore1Period());
        if (request.getFinalExam() != null) grade.setFinalExam(request.getFinalExam());

        // Tính lại điểm trung bình
        grade.setAverageScore(calculateAverage(
                grade.getOralScore(), grade.getScore15Min(),
                grade.getScore1Period(), grade.getFinalExam()));

        Grade saved = gradeRepository.save(grade);
        log.info("Grade id={} updated", gradeId);

        return toGradeResponse(saved);
    }

    // ==================== ĐIỂM DANH ====================

    private void validateTeacherScheduleForAttendance(Teacher teacher, Long classId, LocalDate date, Integer period) {
        DayOfWeek dayOfWeek = date.getDayOfWeek();

        // Kiểm tra xem giáo viên có lịch dạy lớp này vào thứ này không
        List<Schedule> schedules = scheduleRepository.findByTeacherIdAndClassRoomIdAndDayOfWeek(
                teacher.getId(), classId, dayOfWeek);

        if (schedules.isEmpty()) {
            throw new AccessDeniedException("You are not assigned to teach this class on " + dayOfWeek);
        }

        // Kiểm tra xem tiết học có nằm trong lịch dạy không
        boolean validPeriod = schedules.stream()
                .anyMatch(s -> s.getPeriodStart() <= period && s.getPeriodEnd() >= period);

        if (!validPeriod) {
            throw new AccessDeniedException("You are not assigned to teach this class at period " + period);
        }
    }

    @Override
    public List<TeacherStudentAttendanceResponse> getStudentsForAttendance(Long currentUserId, Long classId, LocalDate date, Integer period) {
        log.info("Teacher userId={} getting students for attendance classId={}, date={}, period={}", currentUserId, classId, date, period);
        Teacher teacher = getTeacherByUserId(currentUserId);

        classRoomRepository.findById(classId)
                .orElseThrow(() -> new EntityNotFound("Class not found"));

        validateTeacherScheduleForAttendance(teacher, classId, date, period);

        List<Student> students = studentRepository.findByClassRoomId(classId);

        List<Attendance> existingAttendances = attendanceRepository.findByClassRoomIdAndAttendanceDateAndPeriod(
                classId, date, period);

        return students.stream().map(student -> {
            TeacherStudentAttendanceResponse response = TeacherStudentAttendanceResponse.builder()
                    .studentId(student.getId())
                    .studentName(student.getUser().getFullName())
                    .studentCode(student.getStudentCode())
                    .build();

            existingAttendances.stream()
                    .filter(a -> a.getStudent().getId().equals(student.getId()))
                    .findFirst()
                    .ifPresent(a -> {
                        response.setStatus(a.getStatus().name());
                        response.setNote(a.getNote());
                    });

            return response;
        }).toList();
    }

    @Override
    @Transactional
    public void takeAttendance(Long currentUserId, TeacherTakeAttendanceRequest request) {
        log.info("Teacher userId={} taking attendance for classId={}, date={}, period={}",
                currentUserId, request.getClassRoomId(), request.getAttendanceDate(), request.getPeriod());

        Teacher teacher = getTeacherByUserId(currentUserId);
        
        ClassRoom classRoom = classRoomRepository.findById(request.getClassRoomId())
                .orElseThrow(() -> new EntityNotFound("Class not found"));

        validateTeacherScheduleForAttendance(teacher, classRoom.getId(), request.getAttendanceDate(), request.getPeriod());

        List<Attendance> existingAttendances = attendanceRepository.findByClassRoomIdAndAttendanceDateAndPeriod(
                classRoom.getId(), request.getAttendanceDate(), request.getPeriod());

        for (TeacherTakeAttendanceRequest.StudentAttendanceRequest attRequest : request.getAttendances()) {
            Student student = studentRepository.findById(attRequest.getStudentId())
                    .orElseThrow(() -> new EntityNotFound("Student not found: " + attRequest.getStudentId()));

            if (!student.getClassRoom().getId().equals(classRoom.getId())) {
                throw new InvalidInputException("Student " + student.getId() + " is not in class " + classRoom.getId());
            }

            AttendanceStatus status;
            try {
                status = AttendanceStatus.valueOf(attRequest.getStatus());
            } catch (IllegalArgumentException e) {
                throw new InvalidInputException("Invalid attendance status: " + attRequest.getStatus());
            }

            Attendance existingAttendance = existingAttendances.stream()
                    .filter(a -> a.getStudent().getId().equals(student.getId()))
                    .findFirst()
                    .orElse(null);

            if (existingAttendance != null) {
                // Update
                existingAttendance.setStatus(status);
                existingAttendance.setNote(attRequest.getNote());
                attendanceRepository.save(existingAttendance);
            } else {
                // Insert
                Attendance newAttendance = Attendance.builder()
                        .student(student)
                        .classRoom(classRoom)
                        .attendanceDate(request.getAttendanceDate())
                        .period(request.getPeriod())
                        .status(status)
                        .note(attRequest.getNote())
                        .build();
                attendanceRepository.save(newAttendance);
            }
        }
    }

    // ==================== MAPPING HELPERS ====================

    private Double calculateAverage(Double oral, Double min15, Double period1, Double finalExam) {
        // Hệ số: miệng 1, 15 phút 1, 1 tiết 2, cuối kỳ 3
        double total = 0;
        int count = 0;

        if (oral != null) { total += oral * 1; count += 1; }
        if (min15 != null) { total += min15 * 1; count += 1; }
        if (period1 != null) { total += period1 * 2; count += 2; }
        if (finalExam != null) { total += finalExam * 3; count += 3; }

        if (count == 0) return null;
        return Math.round((total / count) * 100.0) / 100.0;
    }

    private TeacherScheduleResponse toTeacherScheduleResponse(Schedule schedule) {
        return TeacherScheduleResponse.builder()
                .id(schedule.getId())
                .subjectName(schedule.getSubject() != null ? schedule.getSubject().getSubjectName() : null)
                .className(schedule.getClassRoom() != null ? schedule.getClassRoom().getClassName() : null)
                .dayOfWeek(schedule.getDayOfWeek())
                .periodStart(schedule.getPeriodStart())
                .periodEnd(schedule.getPeriodEnd())
                .room(schedule.getRoom())
                .build();
    }

    private ClassGradeResponse toClassGradeResponse(Grade grade) {
        return ClassGradeResponse.builder()
                .studentId(grade.getStudent() != null ? grade.getStudent().getId() : null)
                .studentName(grade.getStudent() != null && grade.getStudent().getUser() != null
                        ? grade.getStudent().getUser().getFullName() : null)
                .studentCode(grade.getStudent() != null ? grade.getStudent().getStudentCode() : null)
                .subjectName(grade.getSubject() != null ? grade.getSubject().getSubjectName() : null)
                .oralScore(grade.getOralScore())
                .score15Min(grade.getScore15Min())
                .score1Period(grade.getScore1Period())
                .finalExam(grade.getFinalExam())
                .averageScore(grade.getAverageScore())
                .semesterName(grade.getSemester() != null ? grade.getSemester().getSemesterName() : null)
                .build();
    }

    private ApplicationResponse toApplicationResponse(Application application) {
        String applicantName = null;
        Long studentId = null;

        if (application.getStudent() != null) {
            studentId = application.getStudent().getId();
            if (application.getStudent().getUser() != null) {
                applicantName = application.getStudent().getUser().getFullName();
            }
        } else if (application.getTeacher() != null && application.getTeacher().getUser() != null) {
            applicantName = application.getTeacher().getUser().getFullName();
        }

        String reviewedByName = null;
        if (application.getReviewedBy() != null) {
            reviewedByName = application.getReviewedBy().getFullName();
        }

        return ApplicationResponse.builder()
                .id(application.getId())
                .studentId(studentId)
                .studentName(applicantName)
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

    private EventResponse toEventResponse(Event event) {
        return EventResponse.builder()
                .id(event.getId())
                .title(event.getTitle())
                .description(event.getDescription())
                .location(event.getLocation())
                .startTime(event.getStartTime())
                .endTime(event.getEndTime())
                .targetRole(event.getTargetRole())
                .createdByName(event.getCreatedBy() != null ? event.getCreatedBy().getFullName() : null)
                .build();
    }

    private GradeResponse toGradeResponse(Grade grade) {
        return GradeResponse.builder()
                .subjectName(grade.getSubject() != null ? grade.getSubject().getSubjectName() : null)
                .oralScore(grade.getOralScore())
                .score15Min(grade.getScore15Min())
                .score1Period(grade.getScore1Period())
                .finalExam(grade.getFinalExam())
                .averageScore(grade.getAverageScore())
                .semesterName(grade.getSemester() != null ? grade.getSemester().getSemesterName() : null)
                .build();
    }
}
