package com.lamthoncoding.myfschoolse1913be.repository;

import com.lamthoncoding.myfschoolse1913be.entity.ParentStudent;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ParentStudentRepository extends JpaRepository<ParentStudent, Long> {

    List<ParentStudent> findByParent_User_Id(Long userId);

}