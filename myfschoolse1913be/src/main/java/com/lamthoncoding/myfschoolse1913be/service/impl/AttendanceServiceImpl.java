package com.lamthoncoding.myfschoolse1913be.service.impl;

import com.lamthoncoding.myfschoolse1913be.entity.Student;
import com.lamthoncoding.myfschoolse1913be.exception.handlers.EntityNotFound;
import com.lamthoncoding.myfschoolse1913be.mapper.AttendanceMapper;
import com.lamthoncoding.myfschoolse1913be.payload.response.AttendanceMonthResponse;
import com.lamthoncoding.myfschoolse1913be.payload.response.AttendanceResponse;
import com.lamthoncoding.myfschoolse1913be.repository.AttendanceRepository;
import com.lamthoncoding.myfschoolse1913be.repository.ClassRoomRepository;
import com.lamthoncoding.myfschoolse1913be.repository.StudentRepository;
import com.lamthoncoding.myfschoolse1913be.service.AttendanceService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class AttendanceServiceImpl implements AttendanceService {

    private final AttendanceRepository attendanceRepository;
    private final StudentRepository studentRepository;
    private final ClassRoomRepository classRoomRepository;
    private final AttendanceMapper attendanceMapper;

    @Override
    public List<AttendanceResponse> getAttendanceByClass(Long classId, LocalDate date) {

        log.info("Getting attendance records for class {} on {}",classId,date);

        classRoomRepository.findById(classId)
                .orElseThrow(() -> new EntityNotFound("Class not found"));

        return attendanceRepository
                .findByClassRoomIdAndAttendanceDate(
                        classId,
                        date
                )
                .stream()
                .map(attendanceMapper::toResponse)
                .toList();
    }

    @Override
    public List<AttendanceResponse> getAttendanceByStudent (Long classId, Long studentId, Integer year,
                                                            Integer month) {

        log.info("Getting attendance records for class {} by student {}",classId, studentId);

        classRoomRepository.findById(classId)
                .orElseThrow(() -> new EntityNotFound("Class not found"));

        LocalDate fromDate = LocalDate.of(year, month, 1);
        LocalDate toDate = fromDate.withDayOfMonth(fromDate.lengthOfMonth());
        return attendanceRepository
                .findAttendanceByMonth(
                        classId,
                        studentId, fromDate, toDate
                )
                .stream()
                .map(attendanceMapper::toResponse)
                .toList();
    }

    @Override
    public List<AttendanceMonthResponse> getAttendanceMonths (
            Long classId,
            Long studentId
    ) {

        return attendanceRepository
                .findAttendanceMonths(classId, studentId)
                .stream()
                .map(row -> new AttendanceMonthResponse(
                        ((Number) row[0]).intValue(),
                        ((Number) row[1]).intValue()
                ))
                .toList();
    }

    @Override
    public Long studentId (Long userId){
        Student studentOptional = studentRepository.findById(userId)
                .orElseThrow(() -> new EntityNotFound("Student not found"));
        return studentOptional.getId();
    }
}