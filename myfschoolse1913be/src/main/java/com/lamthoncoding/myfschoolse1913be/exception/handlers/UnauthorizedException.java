package com.lamthoncoding.myfschoolse1913be.exception.handlers;

import lombok.Getter;

@Getter
public class UnauthorizedException extends RuntimeException {
    public UnauthorizedException(String msg) {
        super(msg);
    }
}
