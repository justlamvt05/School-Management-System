package com.lamthoncoding.myfschoolse1913be.payload.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GradeResponse {

    private String subjectName;

    private Double oralScore;

    private Double score15Min;

    private Double score1Period;

    private Double finalExam;

    private Double averageScore;

    private String semesterName;

    private String schoolYear;

    private String className;
}
