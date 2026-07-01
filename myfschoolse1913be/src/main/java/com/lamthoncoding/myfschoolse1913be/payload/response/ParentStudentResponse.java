package com.lamthoncoding.myfschoolse1913be.payload.response;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Builder
@Getter
@Setter
public class ParentStudentResponse {

    private Long studentId;

    private String studentCode;

    private String fullName;

    private Long classId;

    private String className;

    private String schoolYear;
}