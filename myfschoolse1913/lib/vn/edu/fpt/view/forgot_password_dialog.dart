import 'package:flutter/material.dart';
import 'package:myfschoolse1913/vn/edu/fpt/model/forgot_password_request.dart';
import '../controller/auth_controller.dart';


void showForgotPasswordDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    // barrierColor: Colors.transparent,
    builder: (_) => const _ForgotPasswordDialog(),

  );

}

class _ForgotPasswordDialog extends StatefulWidget {
  const _ForgotPasswordDialog();

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  static const Color _primaryOrange = Color(0xFFF37021);

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isSending = false;
  bool _sent = false;
  final AuthController authController = AuthController();
  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendLink() async {
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();

    if (phone.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }

    final phoneRegex = RegExp(r'^0[0-9]{9}$');
    if (!phoneRegex.hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số điện thoại không hợp lệ')),
      );
      return;
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email không hợp lệ')),
      );
      return;
    }

    setState(() => _isSending = true);

    try{
      ForgotPasswordRequest request = ForgotPasswordRequest(
        phone: phone,
        email: email,
      );

      final result = await authController.forgotPassword(request);
      if (result.status) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.green,
            ),
          );
      }else{
        switch (result.code) {
          case "E002":
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Sai số điện thoại hoặc email"),
              ),
            );
            break;

          case "E006":
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.errors[0]),
              ),
            );
            break;

          default:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.message),
              ),
            );
        }
        setState(() => _isSending = false);
      }
      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;

      String error = e.toString().replaceFirst("Exception: ", "");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
        ),
      );
    }
    // await Future.delayed(const Duration(seconds: 1)); // giả lập network call

    if (!context.mounted) return;
    setState(() {
      _isSending = false;
      _sent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      insetPadding: const EdgeInsets.only(
      left: 32,
      right: 32,
      top: 130,
      bottom: 24,
    ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: _sent ? _buildSuccessView() : _buildFormView(),
      ),
    );
  }

  // ── View chính – nhập email ──────────────────
  Widget _buildFormView() {
    return Column(

      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon khoá
        const Icon(Icons.lock, size: 48, color: Color(0xFF333333)),
        const SizedBox(height: 12),

        // Tiêu đề
        const Text(
          'Quên mật khẩu?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF222222),
          ),
        ),
        const SizedBox(height: 8),

        // Mô tả
        const Text(
          'Bạn có thể đặt lại mật khẩu tại đây.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 20),

        // Input số điện thoại
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFCCCCCC)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  Icons.phone_outlined,
                  color: Color(0xFF888888),
                  size: 20,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF333333),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Số điện thoại',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Input email với border box
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFCCCCCC)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  Icons.email_outlined,
                  color: Color(0xFF888888),
                  size: 20,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF333333),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Nút gửi link
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: _isSending ? null : _handleSendLink,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryOrange,
              foregroundColor: Colors.white,
              disabledBackgroundColor: _primaryOrange.withOpacity(0.7),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: _isSending
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
                : const Text(
              'Gửi liên kết đặt lại mật khẩu',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Nút huỷ / quay lại
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Quay lại đăng nhập',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 13,
              decoration: TextDecoration.underline,
              decorationColor: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  // ── View sau khi gửi thành công ──────────────
  Widget _buildSuccessView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFF3EC),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(16),
          child: const Icon(
            Icons.mark_email_read_outlined,
            size: 40,
            color: _primaryOrange,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Đã gửi email!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF222222),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Kiểm tra hộp thư của bạn và nhấn vào liên kết để đặt lại mật khẩu.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryOrange,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Text(
              'Về trang đăng nhập',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}