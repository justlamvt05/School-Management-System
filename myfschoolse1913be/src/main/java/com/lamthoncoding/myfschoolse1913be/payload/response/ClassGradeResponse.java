package com.lamthoncoding.myfschoolse1913be.payload.response;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ClassGradeResponse {

    private Long studentId;

    private Long gradeId;

    private String studentName;

    private String studentCode;

    private Long subjectId;

    private String subjectName;

    private Double oralScore;

    private Double score15Min;

    private Double score1Period;

    private Double finalExam;

    private Double averageScore;

    private String semesterName;

    private String schoolYear;
}
