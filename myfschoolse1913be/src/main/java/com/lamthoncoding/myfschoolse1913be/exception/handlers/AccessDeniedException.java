package com.lamthoncoding.myfschoolse1913be.exception.handlers;

public class AccessDeniedException extends RuntimeException {
    public AccessDeniedException(String msg) {
        super(msg);
    }
}
