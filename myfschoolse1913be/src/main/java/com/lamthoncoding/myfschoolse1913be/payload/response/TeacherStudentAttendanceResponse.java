package com.lamthoncoding.myfschoolse1913be.payload.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TeacherStudentAttendanceResponse {
    private Long studentId;
    private String studentName;
    private String studentCode;
    private String status;
    private String note;
}
