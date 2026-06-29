package com.lamthoncoding.myfschoolse1913be.repository;

import com.lamthoncoding.myfschoolse1913be.contraints.ApplicationStatus;
import com.lamthoncoding.myfschoolse1913be.contraints.ApplicationType;
import com.lamthoncoding.myfschoolse1913be.entity.Application;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

public interface ApplicationRepository extends JpaRepository<Application, Long> {

    List<Application> findByStudentId(Long studentId);

    Optional<Application> findByIdAndStudentId(Long id, Long studentId);

    List<Application> findByStatus(ApplicationStatus status);

    List<Application> findByType(ApplicationType type);

    List<Application> findByStatusAndType(ApplicationStatus status, ApplicationType type);

    List<Application> findByTeacherId(Long teacherId);

    Optional<Application> findByIdAndTeacherId(Long id, Long teacherId);

    List<Application> findByStatusAndTypeOrderByCreatedAtDesc (ApplicationStatus status, ApplicationType type);

    List<Application> findByStatusOrderByCreatedAtDesc (ApplicationStatus status);

    List<Application> findByTypeOrderByCreatedAtDesc (ApplicationType type);

    List<Application> findAllByOrderByCreatedAtDesc ();

    List<Application> findByTeacherIdOrderByCreatedAtDesc (Long id);

    List<Application> findByStudentIdOrderByCreatedAtDesc (Long id);
}
