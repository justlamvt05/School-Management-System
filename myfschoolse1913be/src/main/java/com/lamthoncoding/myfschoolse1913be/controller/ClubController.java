package com.lamthoncoding.myfschoolse1913be.controller;

import com.lamthoncoding.myfschoolse1913be.payload.response.ApiResponse;
import com.lamthoncoding.myfschoolse1913be.service.ClubService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/student/clubs")
@RequiredArgsConstructor
public class ClubController {

    private final ClubService clubService;

    @GetMapping
    public ApiResponse<?> getAllClubs(Authentication authentication) {
        String phone = authentication != null ? authentication.getName() : null;
        return ApiResponse.success(clubService.getAllClubs(phone));
    }

    @GetMapping("/{id}")
    public ApiResponse<?> getClubById(@PathVariable Long id, Authentication authentication) {
        String phone = authentication != null ? authentication.getName() : null;
        return ApiResponse.success(clubService.getClubById(id, phone));
    }
}
