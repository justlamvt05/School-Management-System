package com.lamthoncoding.myfschoolse1913be.exception.handlers;

import lombok.Getter;

@Getter
public class EntityNotFound extends RuntimeException {
    public EntityNotFound(String msg) {
        super(msg);
    }
}
