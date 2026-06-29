package com.lamthoncoding.myfschoolse1913be.exception.handlers;

public class ApplicationAlreadyReviewedException extends RuntimeException {
    public ApplicationAlreadyReviewedException(String msg) {
        super(msg);
    }
}
