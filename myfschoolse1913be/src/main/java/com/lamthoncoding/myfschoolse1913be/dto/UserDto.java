package com.lamthoncoding.myfschoolse1913be.dto;



import com.lamthoncoding.myfschoolse1913be.contraints.UserStatus;
import lombok.*;

import java.util.Set;


@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@Builder
public class UserDto {
    private Long id;
    private String username;
    private String fullName;
    private String email;
    private String phone;
    private UserStatus status;
    private Set<String> roles;

}
