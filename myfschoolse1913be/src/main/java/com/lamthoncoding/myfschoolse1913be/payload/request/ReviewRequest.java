package com.lamthoncoding.myfschoolse1913be.payload.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ReviewRequest {

    @NotBlank(message = "Phản hồi không được để trống")
    private String responseMessage;
}
