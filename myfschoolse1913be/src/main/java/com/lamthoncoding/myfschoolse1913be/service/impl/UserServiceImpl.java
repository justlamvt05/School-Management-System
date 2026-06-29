package com.lamthoncoding.myfschoolse1913be.service.impl;

import com.lamthoncoding.myfschoolse1913be.dto.UserDto;
import com.lamthoncoding.myfschoolse1913be.entity.User;
import com.lamthoncoding.myfschoolse1913be.exception.handlers.EntityNotFound;
import com.lamthoncoding.myfschoolse1913be.exception.handlers.InvalidInputException;
import com.lamthoncoding.myfschoolse1913be.repository.UserRepository;
import com.lamthoncoding.myfschoolse1913be.service.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    @Override
    public UserDto getMyProfile(String phone) {

        log.info("GetMyProfile: {}", phone);
        User user = userRepository.findByPhone(phone)
                .orElseThrow(() -> new EntityNotFound("User Not Found"));
        
        return UserDto.builder()
                .id(user.getId())
                .username(user.getUsername())
                .fullName(user.getFullName())
                .email(user.getEmail())
                .phone(user.getPhone())
                .status(user.getStatus())
                .roles(user.getRoles().stream().map(role -> role.getName().name()).collect(java.util.stream.Collectors.toSet()))
                .build();
    }


    @Override
    public String changePassword (String newPass, String confirmPassword,  String phone){
        log.info("ChangePassword: {}", phone);
        if(!newPass.equals(confirmPassword)){
            throw new InvalidInputException("Confirm Password does not match");
        }
        User user = userRepository.findByPhone(phone)
                .orElseThrow(() -> new EntityNotFound("User Not Found"));
        String pass = passwordEncoder.encode(newPass);
        user.setPassword(pass);
        userRepository.save(user);
        return "Changed password successfully";
    }
}
