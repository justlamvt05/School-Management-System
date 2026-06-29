package com.lamthoncoding.myfschoolse1913be.controller;

import com.lamthoncoding.myfschoolse1913be.payload.response.ApiResponse;
import com.lamthoncoding.myfschoolse1913be.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/profile")
    public ApiResponse<?> getMyProfile(Authentication authentication
    ) {
        String phone = authentication.getName();
        return ApiResponse.success(userService.getMyProfile(phone));
    }

    @PutMapping("/change-password")
    public ApiResponse<?> changePassword(Authentication authentication,
                                         @RequestParam String password,
                                         @RequestParam String confirmPassword
    ) {
        String phone = authentication.getName();
        return ApiResponse.success(userService.changePassword(password, confirmPassword,phone));
    }

}
