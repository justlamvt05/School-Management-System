package com.lamthoncoding.myfschoolse1913be.payload.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class LoginRequest {

    private String phone;
    @NotBlank(message = "{password.is.not.empty}")
    private String password;
}
