package com.lamthoncoding.myfschoolse1913be.payload.request;

import com.lamthoncoding.myfschoolse1913be.contraints.ApplicationType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;

@Getter
@Setter
public class ApplicationRequest {

    @NotNull(message = "Loại đơn không được để trống")
    private ApplicationType type;

    @NotNull(message = "Ngày bắt đầu không được để trống")
    private LocalDate fromDate;

    @NotNull(message = "Ngày kết thúc không được để trống")
    private LocalDate toDate;

    @NotBlank(message = "Nội dung không được để trống")
    @Size(min = 10, message = "Nội dung tối thiểu 10 ký tự")
    private String reason;

    private String attachmentUrl;
}
