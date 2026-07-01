package com.lamthoncoding.myfschoolse1913be.service;

import com.lamthoncoding.myfschoolse1913be.payload.response.ParentStudentResponse;

import java.util.List;

public interface ParentService {

    List<ParentStudentResponse> getMyChildren(Long userId);

}