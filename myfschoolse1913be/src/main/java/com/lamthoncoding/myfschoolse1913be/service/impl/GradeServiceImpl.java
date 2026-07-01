package com.lamthoncoding.myfschoolse1913be.service.impl;

import com.lamthoncoding.myfschoolse1913be.entity.StudentClassRoom;
import com.lamthoncoding.myfschoolse1913be.exception.handlers.EntityNotFound;
import com.lamthoncoding.myfschoolse1913be.mapper.GradeMapper;
import com.lamthoncoding.myfschoolse1913be.payload.response.ClassRoomResponse;
import com.lamthoncoding.myfschoolse1913be.payload.response.GradeResponse;
import com.lamthoncoding.myfschoolse1913be.repository.GradeRepository;
import com.lamthoncoding.myfschoolse1913be.repository.SemesterRepository;
import com.lamthoncoding.myfschoolse1913be.repository.StudentClassRoomRepository;
import com.lamthoncoding.myfschoolse1913be.repository.StudentRepository;
import com.lamthoncoding.myfschoolse1913be.service.GradeService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class GradeServiceImpl implements GradeService {

    private final GradeRepository gradeRepository;
    private final StudentRepository studentRepository;
    private final SemesterRepository semesterRepository;
    private final StudentClassRoomRepository studentClassRoomRepository;
    private final GradeMapper gradeMapper;

    @Override
    public List<GradeResponse> getStudentGrades(Long studentId) {

        log.info("Get grades of student {}", studentId);

        studentRepository.findById(studentId)
                .orElseThrow(() -> new EntityNotFound("Không tìm thấy học sinh"));

        return gradeRepository.findByStudentId(studentId)
                .stream()
                .map(grade -> {
                    GradeResponse response = gradeMapper.toResponse(grade);
                    // Set className from student's class history for that school year
                    String schoolYear = grade.getSemester().getSchoolYear();
                    studentClassRoomRepository.findByStudentIdAndClassRoom_SchoolYear(studentId, schoolYear)
                            .ifPresent(sc -> response.setClassName(sc.getClassRoom().getClassName()));
                    // Fallback: use current class if no history found
                    if (response.getClassName() == null && grade.getStudent().getClassRoom() != null) {
                        response.setClassName(grade.getStudent().getClassRoom().getClassName());
                    }
                    return response;
                })
                .toList();
    }

    @Override
    public List<GradeResponse> getStudentGradesBySemester(Long studentId, Long semesterId) {

        log.info("Get grades of student {} in semester {}", studentId, semesterId);

        studentRepository.findById(studentId)
                .orElseThrow(() -> new EntityNotFound("Không tìm thấy học sinh"));

        semesterRepository.findById(semesterId)
                .orElseThrow(() -> new EntityNotFound("Không tìm thấy học kỳ"));

        return gradeRepository.findByStudentIdAndSemesterId(studentId, semesterId)
                .stream()
                .map(grade -> {
                    GradeResponse response = gradeMapper.toResponse(grade);
                    String schoolYear = grade.getSemester().getSchoolYear();
                    studentClassRoomRepository.findByStudentIdAndClassRoom_SchoolYear(studentId, schoolYear)
                            .ifPresent(sc -> response.setClassName(sc.getClassRoom().getClassName()));
                    if (response.getClassName() == null && grade.getStudent().getClassRoom() != null) {
                        response.setClassName(grade.getStudent().getClassRoom().getClassName());
                    }
                    return response;
                })
                .toList();
    }

    @Override
    public List<ClassRoomResponse> getStudentClassHistory(Long studentId) {
        log.info("Get class history for student {}", studentId);

        studentRepository.findById(studentId)
                .orElseThrow(() -> new EntityNotFound("Không tìm thấy học sinh"));

        List<StudentClassRoom> history = studentClassRoomRepository.findByStudentId(studentId);

        var student = studentRepository.findById(studentId).get();

        List<ClassRoomResponse> result = history.stream()
                .map(sc -> ClassRoomResponse.builder()
                        .id(sc.getClassRoom().getId())
                        .name(sc.getClassRoom().getClassName())
                        .schoolYear(sc.getClassRoom().getSchoolYear())
                        .build())
                .collect(java.util.stream.Collectors.toCollection(java.util.ArrayList::new));

        // If current class is not in history, add it
        if (student.getClassRoom() != null) {
            boolean alreadyExists = result.stream()
                    .anyMatch(cr -> cr.getId().equals(student.getClassRoom().getId()));
            if (!alreadyExists) {
                result.add(ClassRoomResponse.builder()
                        .id(student.getClassRoom().getId())
                        .name(student.getClassRoom().getClassName())
                        .schoolYear(student.getClassRoom().getSchoolYear())
                        .build());
            }
        }

        return result;
    }

    @Override
    public List<GradeResponse> getStudentGradesBySchoolYearAndSemester(Long studentId, String schoolYear, Long semesterId) {
        log.info("Get grades of student {} for schoolYear={}, semester={}", studentId, schoolYear, semesterId);

        studentRepository.findById(studentId)
                .orElseThrow(() -> new EntityNotFound("Không tìm thấy học sinh"));

        semesterRepository.findById(semesterId)
                .orElseThrow(() -> new EntityNotFound("Không tìm thấy học kỳ"));

        return gradeRepository.findByStudentIdAndSemesterId(studentId, semesterId)
                .stream()
                .filter(grade -> schoolYear.equals(grade.getSemester().getSchoolYear()))
                .map(grade -> {
                    GradeResponse response = gradeMapper.toResponse(grade);
                    studentClassRoomRepository.findByStudentIdAndClassRoom_SchoolYear(studentId, schoolYear)
                            .ifPresent(sc -> response.setClassName(sc.getClassRoom().getClassName()));
                    if (response.getClassName() == null && grade.getStudent().getClassRoom() != null) {
                        response.setClassName(grade.getStudent().getClassRoom().getClassName());
                    }
                    return response;
                })
                .toList();
    }
}