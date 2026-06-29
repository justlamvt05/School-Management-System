package com.lamthoncoding.myfschoolse1913be.service;

import com.lamthoncoding.myfschoolse1913be.dto.UserDto;

public interface UserService {
    UserDto getMyProfile(String phone);

    String changePassword (String newPass,String confirmPassword, String phone);
}
