package com.lamthoncoding.myfschoolse1913be.mapper;

import com.lamthoncoding.myfschoolse1913be.entity.Schedule;
import com.lamthoncoding.myfschoolse1913be.payload.response.ScheduleResponse;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface ScheduleMapper {

    @Mapping(source = "subject.subjectName", target = "subjectName")
    ScheduleResponse toResponse(Schedule schedule);
}
