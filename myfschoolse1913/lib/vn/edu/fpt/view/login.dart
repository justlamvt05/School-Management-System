import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myfschoolse1913/vn/edu/fpt/view/student/student_home_page.dart';
import 'package:myfschoolse1913/vn/edu/fpt/view/teacher/teacher_home_page.dart';
import 'forgot_password_dialog.dart';
import '../model/login_request.dart';
import '../controller/auth_controller.dart';
import '../core/token_manager.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  static const Color _primaryOrange = Color(0xFFF37021);
  bool _isLoading = false;
  bool _obscurePassword = true;



  final AuthController authController = AuthController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_phoneController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ thông tin'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      LoginRequest request = LoginRequest(
        phone: _phoneController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final result = await authController.login(request);

      final decoded = JwtDecoder.decode(result.data!.token);

      final List roles = decoded['roles'];
      if (result.status) {
        TokenManager.instance.token = result.data!.token;
        TokenManager.instance.refreshToken = result.data!.refreshToken ?? '';

        if (roles.contains('ROLE_TEACHER')) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => TeacherHomePage(
                phone: result.data!.phone,
                token: result.data!.token,
                refreshToken: result.data!.refreshToken ?? '',
              ),
            ),
          );
        } else if (roles.contains('ROLE_STUDENT')) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomePage(
                phone: result.data!.phone,
                token: result.data!.token,
                refreshToken: result.data!.refreshToken ?? '',
              ),
            ),
          );
        }
      } else {
        switch (result.code) {
          case "E002":
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Sai tài khoản hoặc mật khẩu"),
              ),
            );
            break;

          case "E005":
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Chưa đăng nhập"),
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
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi: $e"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ── Mở popup quên mật khẩu ──────────────────
  void _handleForgotPassword() {
    showForgotPasswordDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Column(
            children: [
              _buildHeader(size),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 24),
                          _buildInputField(
                            controller: _phoneController,
                            hintText: 'Số điện thoại',
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 24),
                          _buildPasswordField(),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _handleForgotPassword,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Quên mật khẩu',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.blue,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 36),
                          _buildLoginButton(),
                          const Spacer(),
                          Align(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'Version 1.0',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Copyright @lamthoncoding',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Size size) {
    return Stack(
      children: [
        SizedBox(
          height: size.height * 0.35,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                Image.asset('assets/images/fpt_logo.png', width: 400),
                const SizedBox(height: 8),
                const Text(
                  'Academic Portal',
                  style: TextStyle(
                    color: Color(0xFFF37021),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(prefixIcon, color: Colors.grey.shade600, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                style: const TextStyle(fontSize: 15, color: Color(0xFF333333)),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.only(bottom: 8),
                ),
              ),
            ),
          ],
        ),
        Divider(color: Colors.grey.shade400, thickness: 1, height: 1),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lock_outline, color: Colors.grey.shade600, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(fontSize: 15, color: Color(0xFF333333)),
                decoration: InputDecoration(
                  hintText: 'Mật khẩu',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.only(bottom: 8),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _obscurePassword = !_obscurePassword),
              child: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey.shade500,
                size: 22,
              ),
            ),
          ],
        ),
        Divider(color: Colors.grey.shade400, thickness: 1, height: 1),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryOrange,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _primaryOrange.withOpacity(0.7),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'Đăng nhập',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}
