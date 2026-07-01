package com.lamthoncoding.myfschoolse1913be.payload.request;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;

@Getter
@Setter
public class TeacherGradeRequest {

    @NotNull(message = "Mã học sinh không được để trống")
    private Long studentId;

    @NotNull(message = "Mã môn học không được để trống")
    private Long subjectId;

    @NotNull(message = "Mã học kỳ không được để trống")
    private Long semesterId;

    @NotNull(message = "Năm học không được để trống")
    private String schoolYear;

    @Min(value = 0, message = "Điểm không được nhỏ hơn 0")
    @Max(value = 10, message = "Điểm không được lớn hơn 10")
    private Double oralScore;

    @Min(value = 0, message = "Điểm không được nhỏ hơn 0")
    @Max(value = 10, message = "Điểm không được lớn hơn 10")
    private Double score15Min;

    @Min(value = 0, message = "Điểm không được nhỏ hơn 0")
    @Max(value = 10, message = "Điểm không được lớn hơn 10")
    private Double score1Period;

    @Min(value = 0, message = "Điểm không được nhỏ hơn 0")
    @Max(value = 10, message = "Điểm không được lớn hơn 10")
    private Double finalExam;
}
