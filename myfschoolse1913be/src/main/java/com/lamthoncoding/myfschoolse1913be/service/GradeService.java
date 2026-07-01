package com.lamthoncoding.myfschoolse1913be.service;

import com.lamthoncoding.myfschoolse1913be.payload.response.ClassRoomResponse;
import com.lamthoncoding.myfschoolse1913be.payload.response.GradeResponse;

import java.util.List;

public interface GradeService {

    List<GradeResponse> getStudentGrades(Long studentId);

    List<GradeResponse> getStudentGradesBySemester(Long studentId, Long semesterId);

    List<ClassRoomResponse> getStudentClassHistory(Long studentId);

    List<GradeResponse> getStudentGradesBySchoolYearAndSemester(Long studentId, String schoolYear, Long semesterId);
}
