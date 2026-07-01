import 'package:flutter/material.dart';
import '../../controller/student_controller.dart';
import '../../controller/teacher_controller.dart';
import '../../model/schedule_response.dart';
import '../user/notification.dart';
import '../user_profile.dart';

class TeacherCalenderPage extends StatefulWidget {
  final String token;

  const TeacherCalenderPage({super.key, required this.token});

  @override
  State<TeacherCalenderPage> createState() => _TeacherCalenderPageState();
}

class _TeacherCalenderPageState extends State<TeacherCalenderPage> {
  static const Color _orange = Color(0xFFF37021);
  static const Color _bgCard = Color(0xFFF7F6F6);
  static const Color _green = Color(0xFF3FAE5C);
  static const Color _amber = Color(0xFFFFA834);
  static const Color _blue = Color(0xFF3D8AF7);
  static const Color _purple = Color(0xFFD757F6);
  static const Color _textDark = Color(0xFF333333);
  static const Color _textGrey = Color(0xFF9A9A9A);
  static const Color _border = Color(0xFFEDEDED);

  // Danh sách thứ theo thứ tự trong tuần
  static const List<String> _dayOrder = [
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY',
  ];

  static const List<String> _dayLabels = [
    'T2',
    'T3',
    'T4',
    'T5',
    'T6',
    'T7',
    'CN',
  ];

  static const List<Color> _dayColors = [
    _amber,
    _blue,
    _green,
    _purple,
    _orange,
    _amber,
    _blue,
  ];

  late TeacherController _controller;
  List<ScheduleItem> _scheduleItems = [];
  bool _isLoading = true;
  String? _error;

  int _selectedDayIndex = 0; // Mặc định chọn Thứ 2

  @override
  void initState() {
    super.initState();
    _controller = TeacherController(token: widget.token);
    _fetchSchedule();
  }

  Future<void> _fetchSchedule() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _controller.getSchedules();
      if (result.status && result.data != null) {
        setState(() {
          _scheduleItems = result.data!;
          _isLoading = false;

          // Tìm ngày đầu tiên có lịch để chọn mặc định
          for (int i = 0; i < _dayOrder.length; i++) {
            if (_scheduleItems
                .any((item) => item.dayOfWeek == _dayOrder[i])) {
              _selectedDayIndex = i;
              break;
            }
          }
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

  /// Lấy danh sách tiết học của ngày được chọn
  List<ScheduleItem> get _filteredSchedule {
    final selectedDay = _dayOrder[_selectedDayIndex];
    return _scheduleItems
        .where((item) => item.dayOfWeek == selectedDay)
        .toList()
      ..sort((a, b) => a.periodStart.compareTo(b.periodStart));
  }

  /// Kiểm tra ngày có lịch hay không
  bool _dayHasClass(int dayIndex) {
    return _scheduleItems.any((item) => item.dayOfWeek == _dayOrder[dayIndex]);
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
            _buildWeekStrip(),
            const Divider(height: 1, thickness: 1, color: _border),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // ── Top bar ──────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: _orange,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Center(
            child: Text(
              'Thời khóa biểu',
              style: TextStyle(
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

  // ── Dải ngày trong tuần ───────────────────────
  Widget _buildWeekStrip() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_dayLabels.length, (index) {
          final bool isSelected = index == _selectedDayIndex;
          final bool hasClass = _dayHasClass(index);
          return GestureDetector(
            onTap: () => setState(() => _selectedDayIndex = index),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _dayLabels[index],
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? _textDark : _textGrey,
                    fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? _textDark : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: isSelected ? Colors.white : _textGrey,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: hasClass ? _orange : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── Body chính ────────────────────────────────
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _orange),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 48, color: Colors.red.shade300),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _textGrey, fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchSchedule,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final filtered = _filteredSchedule;

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy_rounded, size: 48, color: _textGrey.withOpacity(0.5)),
            const SizedBox(height: 12),
            const Text(
              'Không có tiết học',
              style: TextStyle(color: _textGrey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return _buildScheduleList(filtered);
  }

  // ── Danh sách lịch học ────────────────────────
  Widget _buildScheduleList(List<ScheduleItem> items) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final color = _dayColors[_selectedDayIndex];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildSessionCard(item, color),
        );
      },
    );
  }

  Widget _buildSessionCard(ScheduleItem item, Color lineColor) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Container(width: 3, color: lineColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Material(
              color: _bgCard,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tên môn
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: lineColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.periodLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: lineColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Phòng ${item.room}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: _textGrey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.subjectName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.room_rounded,
                              size: 14, color: _textGrey),
                          const SizedBox(width: 4),
                          Text(
                            item.room,
                            style: const TextStyle(
                                fontSize: 12, color: _textGrey),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.access_time_rounded,
                              size: 14, color: _textGrey),
                          const SizedBox(width: 4),
                          Text(
                            item.periodLabel,
                            style: const TextStyle(
                                fontSize: 12, color: _textGrey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildTag(item.dayOfWeekFull, _green),
                          const SizedBox(width: 8),
                          _buildTag(item.periodLabel, lineColor),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  // ── Bottom Nav (đồng bộ với HomePage) ─────────
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
          _buildNavItem(
            Icons.home_rounded,
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            }
            ),
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