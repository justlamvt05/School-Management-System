package com.lamthoncoding.myfschoolse1913be.mapper;

import com.lamthoncoding.myfschoolse1913be.entity.Grade;
import com.lamthoncoding.myfschoolse1913be.payload.response.GradeResponse;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface GradeMapper {

    @Mapping(source = "subject.subjectName", target = "subjectName")
    @Mapping(source = "semester.semesterName", target = "semesterName")
    @Mapping(source = "semester.schoolYear", target = "schoolYear")
    @Mapping(target = "className", ignore = true)
    GradeResponse toResponse(Grade grade);
}
