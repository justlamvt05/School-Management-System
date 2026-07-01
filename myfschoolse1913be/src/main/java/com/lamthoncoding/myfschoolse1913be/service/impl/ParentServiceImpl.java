package com.lamthoncoding.myfschoolse1913be.service.impl;

import com.lamthoncoding.myfschoolse1913be.entity.Student;
import com.lamthoncoding.myfschoolse1913be.payload.response.ParentStudentResponse;
import com.lamthoncoding.myfschoolse1913be.repository.ParentStudentRepository;
import com.lamthoncoding.myfschoolse1913be.service.ParentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class ParentServiceImpl implements ParentService {

    private final ParentStudentRepository parentStudentRepository;

    @Override
    public List<ParentStudentResponse> getMyChildren(Long userId) {

        log.info("Parent {} getting children", userId);

        return parentStudentRepository.findByParent_User_Id(userId)
                .stream()
                .map(ps -> {

                    Student student = ps.getStudent();

                    return ParentStudentResponse.builder()
                            .studentId(student.getId())
                            .studentCode(student.getStudentCode())
                            .fullName(student.getUser().getFullName())
                            .classId(student.getClassRoom().getId())
                            .className(student.getClassRoom().getClassName())
                            .schoolYear(student.getClassRoom().getSchoolYear())
                            .build();

                })
                .toList();
    }
}