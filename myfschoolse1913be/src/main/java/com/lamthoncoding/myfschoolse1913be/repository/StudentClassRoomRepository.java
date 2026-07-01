package com.lamthoncoding.myfschoolse1913be.repository;

import com.lamthoncoding.myfschoolse1913be.entity.StudentClassRoom;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface StudentClassRoomRepository extends JpaRepository<StudentClassRoom, Long> {

    Optional<StudentClassRoom> findByStudentIdAndClassRoom_SchoolYear(Long studentId, String schoolYear);

    List<StudentClassRoom> findByClassRoomId(Long classRoomId);

    List<StudentClassRoom> findByStudentId(Long studentId);
}
