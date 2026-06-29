package com.lamthoncoding.myfschoolse1913be.service;

import com.lamthoncoding.myfschoolse1913be.payload.response.ScheduleResponse;

import java.time.DayOfWeek;
import java.util.List;

public interface ScheduleService {

    List<ScheduleResponse> getScheduleByClass(Long classId);

    List<ScheduleResponse> getScheduleByClassAndDay(Long classId, DayOfWeek dayOfWeek);
}
