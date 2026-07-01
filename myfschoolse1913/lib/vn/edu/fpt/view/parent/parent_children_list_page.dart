import 'package:flutter/material.dart';
import '../../controller/parent_controller.dart';
import '../../model/child_response.dart';
import '../student/mark_report.dart';
import '../student/attendance.dart';
import '../student/calendar.dart';
import '../user/notification.dart';
import '../user_profile.dart';

enum ParentDestination { markReport, attendance, calendar }

class ParentChildrenListPage extends StatefulWidget {
  final String token;
  final ParentDestination destination;

  const ParentChildrenListPage({
    super.key,
    required this.token,
    required this.destination,
  });

  @override
  State<ParentChildrenListPage> createState() => _ParentChildrenListPageState();
}

class _ParentChildrenListPageState extends State<ParentChildrenListPage> {
  static const Color _orange = Color(0xFFF37021);
  static const Color _textDark = Color(0xFF333333);
  static const Color _textGrey = Color(0xFF9A9A9A);
  static const Color _border = Color(0xFFEDEDED);

  late ParentController _controller;
  List<ChildResponse> _children = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = ParentController(token: widget.token);
    _fetchChildren();
  }

  Future<void> _fetchChildren() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _controller.getChildren();
      if (result.status && result.data != null) {
        setState(() {
          _children = result.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi kết nối: $e';
        _isLoading = false;
      });
    }
  }

  String get _pageTitle {
    switch (widget.destination) {
      case ParentDestination.markReport:
        return 'Điểm của con';
      case ParentDestination.attendance:
        return 'Điểm danh của con';
      case ParentDestination.calendar:
        return 'Lịch học của con';
    }
  }

  void _navigateToDestination(ChildResponse child) {
    Widget page;
    switch (widget.destination) {
      case ParentDestination.markReport:
        page = MarkReportPage(token: widget.token, studentId: child.studentId, classId: child.classId);
        break;
      case ParentDestination.attendance:
        page = AttendancePage(token: widget.token, studentId: child.studentId, classId: child.classId);
        break;
      case ParentDestination.calendar:
        page = CalendarPage(token: widget.token, studentId: child.studentId, classId: child.classId);
        break;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: _orange,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Text(
              _pageTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Positioned(
            left: 4,
            child: TextButton.icon(
              onPressed: () => Navigator.maybePop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 6),
              ),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 11,
              ),
              label: const Text(
                'Trang chính',
                style: TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _orange));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: _textGrey, fontSize: 14)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchChildren,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(backgroundColor: _orange, foregroundColor: Colors.white),
            ),
          ],
        ),
      );
    }
    if (_children.isEmpty) {
      return const Center(
        child: Text('Không có dữ liệu', style: TextStyle(color: _textGrey, fontSize: 14)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _children.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final child = _children[index];
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _navigateToDestination(child),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: _border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _orange.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_rounded, color: _orange),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.fullName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textDark),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mã HS: ${child.studentCode} • Lớp: ${child.className}',
                          style: const TextStyle(fontSize: 13, color: _textGrey),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: _textGrey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: _orange,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(0), topRight: Radius.circular(0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_rounded, onPressed: () => Navigator.pop(context)),
          _buildNavItem(
            Icons.chat_bubble_outline_rounded,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationPage(token: widget.token))),
          ),
          _buildNavItem(
            Icons.person_outline_rounded,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfilePage(token: widget.token))),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, {bool isActive = false, VoidCallback? onPressed}) {
    return IconButton(
      icon: Icon(icon, color: isActive ? Colors.white : Colors.white.withOpacity(0.65), size: 28),
      onPressed: onPressed ?? () {},
    );
  }
}
