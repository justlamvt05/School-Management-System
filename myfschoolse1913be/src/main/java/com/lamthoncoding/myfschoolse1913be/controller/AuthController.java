package com.lamthoncoding.myfschoolse1913be.controller;

import com.lamthoncoding.myfschoolse1913be.dto.UserDto;
import com.lamthoncoding.myfschoolse1913be.payload.request.ForgotPasswordRequest;
import com.lamthoncoding.myfschoolse1913be.payload.request.LoginRequest;
import com.lamthoncoding.myfschoolse1913be.payload.response.ApiResponse;
import com.lamthoncoding.myfschoolse1913be.payload.response.JwtResponse;
import com.lamthoncoding.myfschoolse1913be.security.config.jwt.JwtUtils;
import com.lamthoncoding.myfschoolse1913be.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.lamthoncoding.myfschoolse1913be.entity.RefreshToken;
import com.lamthoncoding.myfschoolse1913be.exception.handlers.TokenRefreshException;
import com.lamthoncoding.myfschoolse1913be.payload.request.TokenRefreshRequest;
import com.lamthoncoding.myfschoolse1913be.payload.response.TokenRefreshResponse;
import com.lamthoncoding.myfschoolse1913be.security.service.UserDetailsImpl;
import com.lamthoncoding.myfschoolse1913be.service.BlacklistTokenService;
import com.lamthoncoding.myfschoolse1913be.service.RefreshTokenService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.util.StringUtils;

import java.util.Date;
@RestController
@RequiredArgsConstructor
@RequestMapping("/auth")
public class AuthController {
    private final AuthService authService;
    private final AuthenticationManager authenticationManager;
    private final JwtUtils jwtUtils;
    private final RefreshTokenService refreshTokenService;
    private final BlacklistTokenService blacklistTokenService;

    @PostMapping("/login")
    public ApiResponse<?> login (@Valid @RequestBody LoginRequest loginRequest) {
        UserDto userDto = authService.login(loginRequest);
        Authentication authentication = authenticationManager
                .authenticate(new UsernamePasswordAuthenticationToken
                        (loginRequest.getPhone(), loginRequest.getPassword()));
        SecurityContextHolder.getContext().setAuthentication(authentication);
        String token = jwtUtils.generateToken(authentication);

        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        RefreshToken refreshToken = refreshTokenService.createRefreshToken(userDetails.getUserId());

        return ApiResponse.success(
                JwtResponse.builder()
                        .type("Bearer")
                        .token(token)
                        .refreshToken(refreshToken.getToken())
                        .phone(userDto.getPhone())
                        .build());

    }
    @PostMapping("/refresh-token")
    public ApiResponse<?> refreshtoken(@Valid @RequestBody TokenRefreshRequest request) {
        String requestRefreshToken = request.getRefreshToken();

        return refreshTokenService.findByToken(requestRefreshToken)
                .map(refreshTokenService::verifyExpiration)
                .map(RefreshToken::getUser)
                .map(user -> {
                    String token = jwtUtils.generateToken(UsernamePasswordAuthenticationToken.authenticated(
                            UserDetailsImpl.build(user), null, UserDetailsImpl.build(user).getAuthorities()));
                    return ApiResponse.success(TokenRefreshResponse.builder()
                            .accessToken(token)
                            .refreshToken(requestRefreshToken)
                            .tokenType("Bearer")
                            .build());
                })
                .orElseThrow(() -> new TokenRefreshException(requestRefreshToken,
                        "Refresh token is not in database!"));
    }

    @PostMapping("/logout")
    public ApiResponse<?> logoutUser(HttpServletRequest request, @Valid @RequestBody TokenRefreshRequest tokenRefreshRequest) {
        String headerAuth = request.getHeader("Authorization");
        if (StringUtils.hasText(headerAuth) && headerAuth.startsWith("Bearer ")) {
            String jwt = headerAuth.substring(7);
            Date expiration = jwtUtils.getExpirationDateFromToken(jwt);
            blacklistTokenService.addToBlacklist(jwt, expiration.toInstant());
        }

        refreshTokenService.findByToken(tokenRefreshRequest.getRefreshToken())
                .ifPresent(refreshToken -> refreshTokenService.deleteByUserId(refreshToken.getUser().getId()));

        return ApiResponse.success("Log out successful!");
    }

    @PostMapping("/forgot-password")
    public ApiResponse<?> forgotPassword(@Valid@RequestBody ForgotPasswordRequest request) {

        authService.forgotPassword(request);

        return ApiResponse.success("A new password has been sent to your email.");

    }
}