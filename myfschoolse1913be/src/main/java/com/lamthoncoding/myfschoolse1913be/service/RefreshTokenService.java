package com.lamthoncoding.myfschoolse1913be.service;

import com.lamthoncoding.myfschoolse1913be.entity.RefreshToken;
import java.util.Optional;

public interface RefreshTokenService {
    Optional<RefreshToken> findByToken(String token);
    RefreshToken createRefreshToken(Long userId);
    RefreshToken verifyExpiration(RefreshToken token);
    int deleteByUserId(Long userId);
}
