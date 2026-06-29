package com.lamthoncoding.myfschoolse1913be.security.config.jwt;



import com.lamthoncoding.myfschoolse1913be.security.service.UserDetailsImpl;
import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.List;

@Slf4j
@Component
public class JwtUtils {
    @Value("${chat.jwtSecret}")
    private String jwtSecret;
    @Value("${chat.jwtExpirationMs}")
    private int jwtExpirationMs;
    private SecretKey secretKey;

    private SecretKey getSigningKey() {
        return Keys.hmacShaKeyFor(jwtSecret.getBytes(StandardCharsets.UTF_8));
    }

    public String generateToken(Authentication authentication) {
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();

        assert userDetails != null;
        List<String> roles = userDetails.getAuthorities()
                .stream()
                .map(GrantedAuthority::getAuthority)
                .toList();
        log.info("Generating token for user: {}", userDetails.getUsername());
//        log.info("Roles: {}", userDetails.getAuthorities()
//                .stream()
//                .map(GrantedAuthority::getAuthority));
        return Jwts.builder()
                .subject(userDetails.getUsername())
                .claim("roles", roles)
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + jwtExpirationMs))
                .signWith(getSigningKey(), Jwts.SIG.HS256)
                .compact();
    }
//    public String generateToken(User user) {
//
//        return Jwts.builder()
//                .subject(user.getUsername())
//                .issuedAt(new Date())
//                .expiration(new Date(System.currentTimeMillis() + jwtExpirationMs))
//                .claim("id", user.getId())
//                .claim("email", user.getEmail())
//                .claim("role", user.getRole().getName())
//                .claim("provider", user.getAuthProvider().name())
//                .signWith(getSigningKey(), Jwts.SIG.HS256)
//                .compact();
//    }

    public String getUsernameFromToken(String token) {
        return Jwts
                .parser()
                .verifyWith(getSigningKey())
                .build()
                .parseSignedClaims(token)
                .getPayload().getSubject();
    }

    public Date getExpirationDateFromToken(String token) {
        return Jwts
                .parser()
                .verifyWith(getSigningKey())
                .build()
                .parseSignedClaims(token)
                .getPayload().getExpiration();
    }

    public boolean validateToken(String authToken) {
        try{
            Jwts.parser()
                    .verifyWith(getSigningKey())
                    .build()
                    .parseSignedClaims(authToken);
            return true;
        } catch (MalformedJwtException e) {
            log.error("Invalid JWT token: {}", e.getMessage());
        } catch (ExpiredJwtException e) {
            log.error("JWT token is expired: {}", e.getMessage());
        } catch (UnsupportedJwtException e) {
            log.error("JWT token is unsupported: {}", e.getMessage());
        } catch (IllegalArgumentException e) {
            log.error("JWT claims string is empty: {}", e.getMessage());
        }
        return false;
    }
}
