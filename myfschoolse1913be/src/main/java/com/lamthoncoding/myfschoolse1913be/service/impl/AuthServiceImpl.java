package com.lamthoncoding.myfschoolse1913be.service.impl;

import com.lamthoncoding.myfschoolse1913be.contraints.UserStatus;
import com.lamthoncoding.myfschoolse1913be.dto.UserDto;
import com.lamthoncoding.myfschoolse1913be.entity.User;
import com.lamthoncoding.myfschoolse1913be.exception.handlers.EntityNotFound;
import com.lamthoncoding.myfschoolse1913be.mapper.UserMapper;
import com.lamthoncoding.myfschoolse1913be.payload.request.ForgotPasswordRequest;
import com.lamthoncoding.myfschoolse1913be.payload.request.LoginRequest;
import com.lamthoncoding.myfschoolse1913be.repository.UserRepository;
import com.lamthoncoding.myfschoolse1913be.service.AuthService;
import com.lamthoncoding.myfschoolse1913be.service.EmailService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.security.SecureRandom;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final UserMapper userMapper;
    private final EmailService emailService;

    @Override
    public UserDto login (LoginRequest loginRequest) {
        log.info("Login request: {}", loginRequest.getPhone());
        User user = userRepository.findByPhoneAndStatus(
                loginRequest.getPhone(), UserStatus.ACTIVE).orElseThrow(()
                -> new EntityNotFound("Invalid username or password"));
        log.info("User found: {}", user.getUsername());
        if (!passwordEncoder.matches(loginRequest.getPassword(), user.getPassword())) {
            throw new EntityNotFound("Invalid username or password.");
        }

        return userMapper.toDto(user);
    }

    @Override
    public void forgotPassword (ForgotPasswordRequest request) {

        User user = userRepository.findByEmailAndPhone(request.getEmail(),request.getPhone())
                .orElseThrow(() -> new EntityNotFound(
                                "Email or phone is incorrect"));

        String randomPassword = generateRandomPassword();

        user.setPassword(passwordEncoder.encode(randomPassword));

        userRepository.save(user);

        emailService.sendPasswordResetEmail(user.getEmail(),user.getFullName(),randomPassword);
    }

    private String generateRandomPassword() {

        String chars ="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

        SecureRandom random = new SecureRandom();

        StringBuilder sb = new StringBuilder();

        for (int i = 0; i < 8; i++) {
            sb.append(chars.charAt(random.nextInt(chars.length())));
        }

        return sb.toString();
    }
}
