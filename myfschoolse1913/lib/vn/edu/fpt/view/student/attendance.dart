import 'package:flutter/material.dart';
import '../../controller/student_controller.dart';
import '../../controller/parent_controller.dart';
import '../../model/attendance_response.dart';
import '../user/notification.dart';
import '../user_profile.dart';

/// Trang "Điểm danh" – hiển thị danh sách tháng, sau đó xem chi tiết điểm danh
class AttendancePage extends StatefulWidget {
  final String token;
  final int? studentId;
  final int? classId;

  const AttendancePage({
    super.key,
    required this.token,
    this.studentId,
    this.classId,
  });

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  // ── Brand colors (đồng bộ với HomePage) ──────
  static const Color _orange = Color(0xFFF37021);
  static const Color _border = Color(0xFFEDEDED);
  static const Color _textDark = Color(0xFF333333);
  static const Color _textGrey = Color(0xFF9A9A9A);

  StudentController? _studentController;
  ParentController? _parentController;

  // Months list
  List<AttendanceMonth> _months = [];
  bool _isLoadingMonths = true;
  String? _monthsError;

  // Attendance detail
  AttendanceMonth? _selectedMonth;
  List<AttendanceItem> _attendances = [];
  bool _isLoadingAttendances = false;
  String? _attendancesError;

  @override
  void initState() {
    super.initState();
    if (widget.studentId != null) {
      _parentController = ParentController(token: widget.token);
    } else {
      _studentController = StudentController(token: widget.token);
    }
    _fetchMonths();
  }

  Future<void> _fetchMonths() async {
    setState(() {
      _isLoadingMonths = true;
      _monthsError = null;
    });

    try {
      final result = widget.studentId != null
          ? await _parentController!.getAttendanceMonths(
              widget.studentId!,
              widget.classId ?? 1,
            )
          : await _studentController!.getAttendanceMonths(widget.classId ?? 1);
      if (result.status && result.data != null) {
        setState(() {
          _months = result.data!;
          _isLoadingMonths = false;
        });
      } else {
        setState(() {
          _monthsError = result.message;
          _isLoadingMonths = false;
        });
      }
    } catch (e) {
      setState(() {
        _monthsError = 'Lỗi kết nối: $e';
        _isLoadingMonths = false;
      });
    }
  }

  Future<void> _fetchAttendances(AttendanceMonth month) async {
    setState(() {
      _selectedMonth = month;
      _isLoadingAttendances = true;
      _attendancesError = null;
      _attendances = [];
    });

    try {
      final result = widget.studentId != null
          ? await _parentController!.getAttendances(
              widget.studentId!,
              widget.classId ?? 1,
              month.year,
              month.month,
            )
          : await _studentController!.getAttendances(
              widget.classId ?? 1,
              month.year,
              month.month,
            );
      if (result.status && result.data != null) {
        setState(() {
          _attendances = result.data!;
          _isLoadingAttendances = false;
        });
      } else {
        setState(() {
          _attendancesError = result.message;
          _isLoadingAttendances = false;
        });
      }
    } catch (e) {
      setState(() {
        _attendancesError = 'Lỗi kết nối: $e';
        _isLoadingAttendances = false;
      });
    }
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
          Center(
            child: Text(
              _selectedMonth != null
                  ? 'Điểm danh - Tháng ${_selectedMonth!.month}/${_selectedMonth!.year}'
                  : 'Điểm danh',
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
              onPressed: () {
                if (_selectedMonth != null) {
                  // Quay lại danh sách tháng
                  setState(() {
                    _selectedMonth = null;
                    _attendances = [];
                    _attendancesError = null;
                  });
                } else {
                  Navigator.maybePop(context);
                }
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 6),
              ),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 11,
              ),
              label: Text(
                _selectedMonth != null ? 'Chọn tháng' : 'Trang chính',
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Body chính ────────────────────────────────
  Widget _buildBody() {
    if (_selectedMonth != null) {
      return _buildAttendanceDetail();
    }
    return _buildMonthList();
  }

  // ── Danh sách tháng ───────────────────────────
  Widget _buildMonthList() {
    if (_isLoadingMonths) {
      return const Center(child: CircularProgressIndicator(color: _orange));
    }

    if (_monthsError != null) {
      return _buildErrorWidget(_monthsError!, _fetchMonths);
    }

    if (_months.isEmpty) {
      return const Center(
        child: Text(
          'Không có dữ liệu điểm danh',
          style: TextStyle(color: _textGrey, fontSize: 14),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _months.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final month = _months[index];
        return _buildMonthCard(month);
      },
    );
  }

  Widget _buildMonthCard(AttendanceMonth month) {
    final monthNames = [
      '',
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12',
    ];

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _fetchAttendances(month),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _border, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _orange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: _orange,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      month.month >= 1 && month.month <= 12
                          ? monthNames[month.month]
                          : 'Tháng ${month.month}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Năm ${month.year}',
                      style: const TextStyle(fontSize: 13, color: _textGrey),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: _textGrey,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Chi tiết điểm danh ────────────────────────
  Widget _buildAttendanceDetail() {
    if (_isLoadingAttendances) {
      return const Center(child: CircularProgressIndicator(color: _orange));
    }

    if (_attendancesError != null) {
      return _buildErrorWidget(_attendancesError!, () {
        if (_selectedMonth != null) {
          _fetchAttendances(_selectedMonth!);
        }
      });
    }

    if (_attendances.isEmpty) {
      return const Center(
        child: Text(
          'Không có dữ liệu điểm danh',
          style: TextStyle(color: _textGrey, fontSize: 14),
        ),
      );
    }

    // Nhóm theo ngày
    final Map<String, List<AttendanceItem>> grouped = {};
    for (final item in _attendances) {
      grouped.putIfAbsent(item.attendanceDate, () => []).add(item);
    }

    // Sắp xếp ngày giảm dần
    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    // Tính thống kê
    final stats = _buildStats();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thống kê tổng quan
          _buildStatsRow(stats),
          const SizedBox(height: 16),
          // Danh sách theo ngày
          for (final date in sortedDates) ...[
            _buildDateHeader(date),
            const SizedBox(height: 8),
            ...grouped[date]!.map((item) => _buildAttendanceRow(item)),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Map<String, int> _buildStats() {
    final stats = <String, int>{
      'PRESENT': 0,
      'LATE': 0,
      'ABSENT_WITH_PERMISSION': 0,
      'ABSENT_WITHOUT_PERMISSION': 0,
    };
    for (final item in _attendances) {
      stats[item.status] = (stats[item.status] ?? 0) + 1;
    }
    return stats;
  }

  Widget _buildStatsRow(Map<String, int> stats) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F6F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Có mặt',
            stats['PRESENT'] ?? 0,
            const Color(0xFF4CAF50),
          ),
          _buildStatItem('Trễ', stats['LATE'] ?? 0, const Color(0xFFFF9800)),
          _buildStatItem(
            'Có phép',
            stats['ABSENT_WITH_PERMISSION'] ?? 0,
            const Color(0xFF2196F3),
          ),
          _buildStatItem(
            'Không phép',
            stats['ABSENT_WITHOUT_PERMISSION'] ?? 0,
            const Color(0xFFE61610),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: _textGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDateHeader(String date) {
    // Parse date string (yyyy-MM-dd) and format
    final parts = date.split('-');
    final formatted = '${parts[2]}/${parts[1]}/${parts[0]}';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: _orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_rounded, color: _orange, size: 18),
          const SizedBox(width: 8),
          Text(
            formatted,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceRow(AttendanceItem item) {
    final statusInfo = _getStatusInfo(item.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border, width: 1),
      ),
      child: Row(
        children: [
          // Tiết học
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F6F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                'T${item.period}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Trạng thái + ghi chú
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusInfo['label']!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _parseColor(statusInfo['color']!),
                  ),
                ),
                if (item.note != null && item.note!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    item.note!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _textGrey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Status icon
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _parseColor(statusInfo['color']!).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(item.status),
              color: _parseColor(statusInfo['color']!),
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> _getStatusInfo(String status) {
    switch (status) {
      case 'PRESENT':
        return {'label': 'Có mặt', 'color': '0xFF4CAF50'};
      case 'LATE':
        return {'label': 'Đi trễ', 'color': '0xFFFF9800'};
      case 'ABSENT_WITH_PERMISSION':
        return {'label': 'Vắng có phép', 'color': '0xFF2196F3'};
      case 'ABSENT_WITHOUT_PERMISSION':
        return {'label': 'Vắng không phép', 'color': '0xFFE61610'};
      default:
        return {'label': status, 'color': '0xFF9A9A9A'};
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'PRESENT':
        return Icons.check_circle_outline_rounded;
      case 'LATE':
        return Icons.schedule_rounded;
      case 'ABSENT_WITH_PERMISSION':
        return Icons.info_outline_rounded;
      case 'ABSENT_WITHOUT_PERMISSION':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Color _parseColor(String colorStr) {
    return Color(int.parse(colorStr));
  }

  // ── Error widget ──────────────────────────────
  Widget _buildErrorWidget(String error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _textGrey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
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
            },
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
