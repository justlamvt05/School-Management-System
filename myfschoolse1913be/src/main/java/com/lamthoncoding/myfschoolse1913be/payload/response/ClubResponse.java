package com.lamthoncoding.myfschoolse1913be.payload.response;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ClubResponse {

    private Long id;

    private String code;

    private String name;

    private boolean joined;
}