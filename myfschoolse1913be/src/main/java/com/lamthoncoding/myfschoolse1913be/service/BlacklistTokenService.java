package com.lamthoncoding.myfschoolse1913be.service;

import java.time.Instant;

public interface BlacklistTokenService {
    void addToBlacklist(String token, Instant expiryDate);
    boolean isBlacklisted(String token);
}
