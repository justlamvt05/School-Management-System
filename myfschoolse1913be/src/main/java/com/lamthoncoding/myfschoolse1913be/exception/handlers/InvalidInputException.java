package com.lamthoncoding.myfschoolse1913be.exception.handlers;

import lombok.Getter;

@Getter
public class InvalidInputException extends IllegalArgumentException {
    public InvalidInputException(String s) {
        super(s);
    }
}
