package com.lamthoncoding.myfschoolse1913be.payload.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.DayOfWeek;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ScheduleResponse {

    private Long id;

    private String subjectName;

    private DayOfWeek dayOfWeek;

    private Integer periodStart;

    private Integer periodEnd;

    private String room;
}
