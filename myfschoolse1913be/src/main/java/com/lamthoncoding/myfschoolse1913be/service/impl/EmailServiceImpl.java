package com.lamthoncoding.myfschoolse1913be.service.impl;

import com.lamthoncoding.myfschoolse1913be.service.EmailService;
import lombok.RequiredArgsConstructor;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class EmailServiceImpl implements EmailService {

    private final JavaMailSender mailSender;

    @Override
    public void sendPasswordResetEmail(String to, String fullName, String newPassword) {

        SimpleMailMessage message = new SimpleMailMessage();

        message.setTo(to);
        message.setSubject("My FSchool - Cấp lại mật khẩu");

        message.setText(
                "Kính gửi " + fullName + ",\n\n" +
                        "Chúng tôi nhận được yêu cầu cấp lại mật khẩu cho tài khoản của bạn.\n\n" +
                        "Mật khẩu tài khoản của bạn đã được đặt lại thành công.\n\n" +
                        "Mật khẩu mới của bạn là: " + newPassword + "\n\n" +
                        "Vui lòng sử dụng mật khẩu trên để đăng nhập vào hệ thống và thay đổi mật khẩu ngay sau lần đăng nhập đầu tiên.\n\n" +
                        "Nếu bạn không thực hiện yêu cầu này, vui lòng liên hệ quản trị viên để được hỗ trợ.\n\n" +
                        "Trân trọng,\n" +
                        "Ban quản trị hệ thống My FSchool"
        );

        mailSender.send(message);
    }
}