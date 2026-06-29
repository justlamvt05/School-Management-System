package com.lamthoncoding.myfschoolse1913be.service;

import com.lamthoncoding.myfschoolse1913be.payload.response.AttendanceMonthResponse;
import com.lamthoncoding.myfschoolse1913be.payload.response.AttendanceResponse;

import java.time.LocalDate;
import java.util.List;

public interface AttendanceService {

    List<AttendanceResponse> getAttendanceByClass(
            Long classId,
            LocalDate date
    );

    List<AttendanceResponse> getAttendanceByStudent (Long classId, Long studentId, Integer year,
                                                     Integer month);

    List<AttendanceMonthResponse> getAttendanceMonths (
            Long classId,
            Long studentId
    );

    Long studentId (Long userId);
}