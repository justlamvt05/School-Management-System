package com.lamthoncoding.myfschoolse1913be.mapper;


import com.lamthoncoding.myfschoolse1913be.entity.Attendance;
import com.lamthoncoding.myfschoolse1913be.payload.response.AttendanceResponse;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface AttendanceMapper {

    @Mapping(target = "studentId", source = "student.id")
    @Mapping(target = "studentCode", source = "student.studentCode")
    @Mapping(target = "studentName", source = "student.user.fullName")
    AttendanceResponse toResponse(Attendance attendance);
}