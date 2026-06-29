package com.lamthoncoding.myfschoolse1913be.service;

import com.lamthoncoding.myfschoolse1913be.payload.response.ClubResponse;

import java.util.List;

public interface ClubService {
    List<ClubResponse> getAllClubs(String phone);
    ClubResponse getClubById(Long id, String phone);
}
