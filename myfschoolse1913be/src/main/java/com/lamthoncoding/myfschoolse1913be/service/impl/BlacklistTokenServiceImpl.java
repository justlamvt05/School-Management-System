package com.lamthoncoding.myfschoolse1913be.service.impl;

import com.lamthoncoding.myfschoolse1913be.entity.BlacklistToken;
import com.lamthoncoding.myfschoolse1913be.repository.BlacklistTokenRepository;
import com.lamthoncoding.myfschoolse1913be.service.BlacklistTokenService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Instant;

@Service
@RequiredArgsConstructor
public class BlacklistTokenServiceImpl implements BlacklistTokenService {

    private final BlacklistTokenRepository blacklistTokenRepository;

    @Override
    public void addToBlacklist(String token, Instant expiryDate) {
        if (!isBlacklisted(token)) {
            BlacklistToken blacklistToken = BlacklistToken.builder()
                    .token(token)
                    .expiryDate(expiryDate)
                    .build();
            blacklistTokenRepository.save(blacklistToken);
        }
    }

    @Override
    public boolean isBlacklisted(String token) {
        return blacklistTokenRepository.existsByToken(token);
    }
}
