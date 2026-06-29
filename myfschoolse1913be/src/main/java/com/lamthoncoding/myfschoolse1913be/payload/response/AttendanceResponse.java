package com.lamthoncoding.myfschoolse1913be.payload.response;

import com.lamthoncoding.myfschoolse1913be.contraints.AttendanceStatus;
import lombok.Data;

import java.time.LocalDate;

@Data
public class AttendanceResponse {

    private Long id;

    private Long studentId;

    private String studentCode;

    private String studentName;

    private LocalDate attendanceDate;

    private Integer period;

    private AttendanceStatus status;

    private String note;
}