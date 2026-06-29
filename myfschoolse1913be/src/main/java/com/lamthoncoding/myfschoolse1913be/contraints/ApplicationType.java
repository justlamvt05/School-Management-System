package com.lamthoncoding.myfschoolse1913be.contraints;

public enum ApplicationType {

    // ===== Student =====
    LEAVE_SCHOOL,        // Xin nghỉ học
    LATE_OR_EARLY_LEAVE, // Đi muộn / về sớm
    STUDENT_CONFIRMATION,// Xác nhận học sinh
    RESERVE_RESULT,      // Bảo lưu kết quả
    REISSUE_CARD,        // Cấp lại thẻ
    CHANGE_CLASS,        // Chuyển lớp

    // ===== Teacher =====
    LEAVE_REQUEST,         // Xin nghỉ phép
    SICK_LEAVE,            // Xin nghỉ ốm
    BUSINESS_TRIP,         // Xin công tác
    SCHEDULE_CHANGE,       // Xin đổi lịch dạy
    SUBSTITUTE_REQUEST,    // Xin giáo viên dạy thay
    OVERTIME_REQUEST,      // Xin làm thêm giờ
    EQUIPMENT_REQUEST,     // Xin cấp thiết bị
    TRAINING_REQUEST,      // Đăng ký tập huấn


    OTHER                // Đơn khác
}
