import 'package:flutter/material.dart';
import 'package:myfschoolse1913/vn/edu/fpt/view/student/calendar.dart';
import 'package:myfschoolse1913/vn/edu/fpt/view/student/mark_report.dart';
import 'package:myfschoolse1913/vn/edu/fpt/view/teacher/teacher_application.dart';
import 'package:myfschoolse1913/vn/edu/fpt/view/teacher/teacher_calendar.dart';
import 'package:myfschoolse1913/vn/edu/fpt/view/teacher/teacher_homeroom_grades.dart';
import 'package:myfschoolse1913/vn/edu/fpt/view/teacher/teacher_grade_input.dart';
import 'package:myfschoolse1913/vn/edu/fpt/view/teacher/teacher_attendance_take.dart';
import 'package:myfschoolse1913/vn/edu/fpt/view/user/event.dart';
import 'package:myfschoolse1913/vn/edu/fpt/view/student/application.dart';
import 'package:myfschoolse1913/vn/edu/fpt/view/student/attendance.dart';
import 'package:myfschoolse1913/vn/edu/fpt/view/user_profile.dart';
import '../../controller/user_controller.dart';
import '../../model/user_profile_response.dart';
import '../student/club.dart';
import '../user/notification.dart';


class TeacherHomePage extends StatefulWidget {
  final String phone;
  final String token;
  final String refreshToken;

  const TeacherHomePage({
    super.key,
    required this.phone,
    required this.token,
    this.refreshToken = '',
  });

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  UserProfile? _userProfile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final userController = UserController(token: widget.token);
    try {
      final response = await userController.getProfile();
      if (response.status && response.data != null) {
        setState(() {
          _userProfile = response.data;
          _isLoadingProfile = false;
        });
      } else {
        setState(() => _isLoadingProfile = false);
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      setState(() => _isLoadingProfile = false);
    }
  }

  // ── Brand colors ─────────────────────────────
  static const Color _orange = Color(0xFFF37021); // bottom nav + primary
  static const Color _bgCard = Color(0xFFF7F6F6); // card background

  // ── Menu item colors (icon background tints) ─
  static const Color _purple = Color(0xFFD757F6);
  static const Color _amber = Color(0xFFFFA834);
  static const Color _blue = Color(0xFF3D8AF7);
  static const Color _red = Color(0xFFE61610);
  static const Color _coral = Color(0xFFFF3823);
  static const Color _green = Color(0xFF4CAF50);

  /// Xây dựng danh sách menu items, truyền token vào các trang cần thiết
  List<_MenuItem> _buildMenuItems() {
    return [
      _MenuItem(
        label: 'Thời khóa biểu',
        icon: Icons.calendar_month_rounded,
        color: _purple,
        builder: () => TeacherCalenderPage(token: widget.token),
      ),
      _MenuItem(
        label: 'Điểm của lớp',
        icon: Icons.bar_chart_rounded,
        color: _amber,
        builder: () => TeacherHomeroomGradesPage(token: widget.token),
      ),
      _MenuItem(
        label: 'Nhập điểm',
        icon: Icons.edit_document,
        color: _coral,
        builder: () => TeacherGradeInputPage(token: widget.token),
      ),
      _MenuItem(
        label: 'Sự kiện',
        icon: Icons.event_note_rounded,
        color: _blue,
        builder: () => EventPage(token: widget.token),
      ),
      _MenuItem(
        label: 'Đơn từ',
        icon: Icons.description_outlined,
        color: _red,
        builder: () => TeacherApplication(token: widget.token),
      ),
      _MenuItem(
        label: 'Điểm danh',
        icon: Icons.co_present_rounded,
        color: _green,
        builder: () => TeacherAttendanceTakePage(token: widget.token),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(context),
            const SizedBox(height: 20),
            Expanded(child: _buildGrid(context)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // ── Top bar ──────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Image.asset('assets/images/fpt_logo.png', width: 100),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isLoadingProfile
                      ? 'Đang tải...'
                      : (_userProfile != null
                      ? 'Giáo Viên ${_userProfile!.fullName}'
                      : ''),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // ── Hiển thị token (rút gọn) ──
                // GestureDetector(
                //   onTap: () => _showTokenDialog(context),
                //   child: Row(
                //     children: [
                //       const Icon(
                //         Icons.vpn_key_rounded,
                //         size: 12,
                //         color: Color(0xFF9A9A9A),
                //       ),
                //       const SizedBox(width: 4),
                //       Expanded(
                //         child: Text(
                //           widget.token.isNotEmpty
                //               ? 'Token: ${widget.token.length > 20 ? '${widget.token.substring(0, 20)}...' : widget.token}'
                //               : 'Chưa có token – Nhấn để nhập',
                //           style: const TextStyle(
                //             fontSize: 10,
                //             color: Color(0xFF9A9A9A),
                //           ),
                //           overflow: TextOverflow.ellipsis,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
          // Notification bell
          // Stack(
          //   children: [
          //     IconButton(
          //       icon: const Icon(
          //         Icons.notifications_none_rounded,
          //         color: Color(0xFF555555),
          //         size: 26,
          //       ),
          //       onPressed: () {
          //         Navigator.push(
          //           context,
          //           MaterialPageRoute(
          //             builder: (_) => NotificationPage(token: widget.token),
          //           ),
          //         );
          //       },
          //       padding: EdgeInsets.zero,
          //       constraints: const BoxConstraints(),
          //     ),
          //     Positioned(
          //       right: 2,
          //       top: 2,
          //       child: Container(
          //         width: 8,
          //         height: 8,
          //         decoration: const BoxDecoration(
          //           color: _coral,
          //           shape: BoxShape.circle,
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  // ── Dialog hiển thị token đầy đủ ─────────────
  void _showTokenDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.vpn_key_rounded, color: _orange, size: 22),
              SizedBox(width: 8),
              Text(
                'Token hiện tại',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F6F6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFEDEDED)),
                ),
                child: SelectableText(
                  widget.token.isNotEmpty ? widget.token : '(Trống)',
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: Color(0xFF333333),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.token.isNotEmpty
                    ? 'Token đang được sử dụng để xác thực API.'
                    : 'Chưa có token. Hãy đăng nhập lại để nhận token.',
                style: const TextStyle(fontSize: 12, color: Color(0xFF9A9A9A)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Đóng',
                style: TextStyle(color: _orange, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Grid ─────────────────────────────────────
  Widget _buildGrid(BuildContext context) {
    final menuItems = _buildMenuItems();
    // 6 items: 3 rows x 2 columns
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Row 1
          Row(
            children: [
              Expanded(child: _buildCard(context, menuItems[0])),
              const SizedBox(width: 14),
              Expanded(child: _buildCard(context, menuItems[1])),
            ],
          ),
          const SizedBox(height: 14),
          // Row 2
          Row(
            children: [
              Expanded(child: _buildCard(context, menuItems[2])),
              const SizedBox(width: 14),
              Expanded(child: _buildCard(context, menuItems[3])),
            ],
          ),
          const SizedBox(height: 14),
          // Row 3
          Row(
            children: [
              Expanded(child: _buildCard(context, menuItems[4])),
              const SizedBox(width: 14),
              Expanded(child: _buildCard(context, menuItems[5])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, _MenuItem item) {
    return Material(
      color: _bgCard,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (item.builder != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => item.builder!()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${item.label} - Chức năng đang phát triển'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with tinted circular bg
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, color: item.color, size: 28),
              ),
              const SizedBox(height: 10),
              Text(
                item.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bottom Nav ───────────────────────────────
  Widget _buildBottomNav(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: _orange,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_rounded, isActive: true),
          _buildNavItem(
            Icons.chat_bubble_outline_rounded,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotificationPage(token: widget.token),
                ),
              );
            },
          ),
          _buildNavItem(
            Icons.person_outline_rounded,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserProfilePage(token: widget.token),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, {
        bool isActive = false,
        VoidCallback? onPressed,
      }) {
    return IconButton(
      icon: Icon(
        icon,
        color: isActive ? Colors.white : Colors.white.withOpacity(0.65),
        size: 28,
      ),
      onPressed: onPressed ?? () {},
    );
  }
}

// ── Data model ───────────────────────────────
class _MenuItem {
  final String label;
  final IconData icon;
  final Color color;
  final Widget Function()? builder;

  const _MenuItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.builder,
  });
}
