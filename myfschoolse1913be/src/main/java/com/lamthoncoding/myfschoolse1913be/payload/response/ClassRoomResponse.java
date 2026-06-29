package com.lamthoncoding.myfschoolse1913be.payload.response;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ClassRoomResponse {
    private Long id;
    private String name;
    private String grade;
    private String schoolYear;
}
