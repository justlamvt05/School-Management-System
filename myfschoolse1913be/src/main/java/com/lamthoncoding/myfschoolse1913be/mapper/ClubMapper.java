package com.lamthoncoding.myfschoolse1913be.mapper;

import com.lamthoncoding.myfschoolse1913be.entity.Club;
import com.lamthoncoding.myfschoolse1913be.entity.Student;
import com.lamthoncoding.myfschoolse1913be.payload.response.ClubResponse;
import org.mapstruct.Context;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import java.util.Optional;

@Mapper(componentModel = "spring")
public interface ClubMapper {

    @Mapping(target = "joined", expression = "java(isJoined(club, studentOpt))")
    ClubResponse toResponse(Club club, @Context Optional<Student> studentOpt);

    default boolean isJoined(Club club, @Context Optional<Student> studentOpt) {
        if (studentOpt.isPresent() && club.getStudents() != null) {
            Long studentId = studentOpt.get().getId();
            return club.getStudents().stream()
                    .anyMatch(s -> s.getId().equals(studentId));
        }
        return false;
    }
}
