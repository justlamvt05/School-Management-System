package com.lamthoncoding.myfschoolse1913be.service;

import com.lamthoncoding.myfschoolse1913be.dto.UserDto;
import com.lamthoncoding.myfschoolse1913be.payload.request.ForgotPasswordRequest;
import com.lamthoncoding.myfschoolse1913be.payload.request.LoginRequest;

public interface AuthService {

    UserDto login(LoginRequest request);

    void forgotPassword (ForgotPasswordRequest request);
}