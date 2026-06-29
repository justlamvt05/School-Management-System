package com.lamthoncoding.myfschoolse1913be.payload.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDate;
import java.util.List;

@Data
public class TeacherTakeAttendanceRequest {
    @NotNull(message = "ClassRoomId is required")
    private Long classRoomId;

    @NotNull(message = "AttendanceDate is required")
    private LocalDate attendanceDate;

    @NotNull(message = "Period is required")
    private Integer period;
    
    @Valid
    @NotNull(message = "Attendances list is required")
    private List<StudentAttendanceRequest> attendances;

    @Data
    public static class StudentAttendanceRequest {
        @NotNull(message = "StudentId is required")
        private Long studentId;

        @NotNull(message = "Status is required")
        private String status;

        private String note;
    }
}
