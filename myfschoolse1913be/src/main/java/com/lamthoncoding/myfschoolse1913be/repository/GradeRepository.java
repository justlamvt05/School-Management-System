package com.lamthoncoding.myfschoolse1913be.repository;

import com.lamthoncoding.myfschoolse1913be.entity.Grade;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface GradeRepository extends JpaRepository<Grade, Long> {

    List<Grade> findByStudentId(Long studentId);

    List<Grade> findByStudentIdAndSemesterId(Long studentId, Long semesterId);

    List<Grade> findByStudentClassRoomId(Long classRoomId);

    List<Grade> findByStudentClassRoomIdAndSemesterId(Long classRoomId, Long semesterId);

    Optional<Grade> findByStudentIdAndSubjectIdAndSemesterId(Long studentId, Long subjectId, Long semesterId);
}
