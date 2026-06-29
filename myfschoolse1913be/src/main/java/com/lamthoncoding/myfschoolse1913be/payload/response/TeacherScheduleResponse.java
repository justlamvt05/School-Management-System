package com.lamthoncoding.myfschoolse1913be.payload.response;

import lombok.*;

import java.time.DayOfWeek;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TeacherScheduleResponse {

    private Long id;

    private String subjectName;

    private String className;

    private DayOfWeek dayOfWeek;

    private Integer periodStart;

    private Integer periodEnd;

    private String room;
}
