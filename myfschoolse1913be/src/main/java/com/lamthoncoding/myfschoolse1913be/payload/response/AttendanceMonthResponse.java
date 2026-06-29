package com.lamthoncoding.myfschoolse1913be.payload.response;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class AttendanceMonthResponse {

    private Integer year;
    private Integer month;
}