package com.lamthoncoding.myfschoolse1913be.security.service;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.lamthoncoding.myfschoolse1913be.entity.Role;
import com.lamthoncoding.myfschoolse1913be.entity.User;
import lombok.Getter;
import lombok.Setter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;

import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.List;


@Getter
@Setter
public class UserDetailsImpl implements UserDetails {

    private Long userId;
    private String username;

    @JsonIgnore
    private String password;

    private Collection<? extends GrantedAuthority> authorities;

    public UserDetailsImpl(
            Long userId,
            String username,
            String password,
            Collection<? extends GrantedAuthority> authorities
    ) {
        this.userId = userId;
        this.username = username;
        this.password = password;
        this.authorities = authorities;
    }

    public static UserDetailsImpl build(User user) {
        List<GrantedAuthority> authorities =
                user.getRoles().stream()
                        .<GrantedAuthority>map(
                                role -> new SimpleGrantedAuthority(role.getName().name())
                        )
                        .toList();

        return new UserDetailsImpl(
                user.getId(),
                user.getPhone(),
                user.getPassword(),
                authorities
        );
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }
    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return true;
    }
}
