package com.lamthoncoding.myfschoolse1913be.service;

public interface EmailService {

    void sendPasswordResetEmail(
            String to,
            String fullName,
            String newPassword
    );

}