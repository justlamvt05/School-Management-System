package com.lamthoncoding.myfschoolse1913be.payload.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class ForgotPasswordRequest {

    @NotBlank
    private String phone;

    @Email
    @NotBlank
    private String email;


}