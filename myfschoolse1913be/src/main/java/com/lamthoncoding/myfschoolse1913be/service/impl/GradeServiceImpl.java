package com.lamthoncoding.myfschoolse1913be.service.impl;

import com.lamthoncoding.myfschoolse1913be.exception.handlers.EntityNotFound;
import com.lamthoncoding.myfschoolse1913be.mapper.GradeMapper;
import com.lamthoncoding.myfschoolse1913be.payload.response.GradeResponse;
import com.lamthoncoding.myfschoolse1913be.repository.GradeRepository;
import com.lamthoncoding.myfschoolse1913be.repository.SemesterRepository;
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
    private final GradeMapper gradeMapper;

    @Override
    public List<GradeResponse> getStudentGrades(Long studentId) {

        log.info("Get grades of student {}", studentId);

        studentRepository.findById(studentId)
                .orElseThrow(() -> new EntityNotFound("Student not found"));

        return gradeRepository.findByStudentId(studentId)
                .stream()
                .map(gradeMapper::toResponse)
                .toList();
    }

    @Override
    public List<GradeResponse> getStudentGradesBySemester(Long studentId, Long semesterId) {

        log.info("Get grades of student {} in semester {}", studentId, semesterId);

        studentRepository.findById(studentId)
                .orElseThrow(() -> new EntityNotFound("Student not found"));

        semesterRepository.findById(semesterId)
                .orElseThrow(() -> new EntityNotFound("Semester not found"));

        return gradeRepository.findByStudentIdAndSemesterId(studentId, semesterId)
                .stream()
                .map(gradeMapper::toResponse)
                .toList();
    }
}
