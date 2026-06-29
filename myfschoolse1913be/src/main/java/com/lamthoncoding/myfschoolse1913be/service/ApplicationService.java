package com.lamthoncoding.myfschoolse1913be.service;

import com.lamthoncoding.myfschoolse1913be.contraints.ApplicationStatus;
import com.lamthoncoding.myfschoolse1913be.contraints.ApplicationType;
import com.lamthoncoding.myfschoolse1913be.payload.request.ApplicationRequest;
import com.lamthoncoding.myfschoolse1913be.payload.request.ReviewRequest;
import com.lamthoncoding.myfschoolse1913be.payload.response.ApplicationResponse;

import java.util.List;

public interface ApplicationService {

    // Student APIs
    ApplicationResponse createApplication(ApplicationRequest request, Long currentUserId);

    List<ApplicationResponse> getMyApplications(Long currentUserId);

    ApplicationResponse getMyApplicationById(Long id, Long currentUserId);

    // Admin APIs
    List<ApplicationResponse> getAllApplications(ApplicationStatus status, ApplicationType type);

    ApplicationResponse getApplicationById(Long id);

    ApplicationResponse approveApplication(Long id, ReviewRequest request, Long adminUserId);

    ApplicationResponse rejectApplication(Long id, ReviewRequest request, Long adminUserId);
}
