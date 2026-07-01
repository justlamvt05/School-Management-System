import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../controller/teacher_controller.dart';
import '../../model/classroom_response.dart';
import '../../model/teacher_student_attendance_response.dart';
import '../../model/teacher_take_attendance_request.dart';
import 'teacher_home_page.dart';

class TeacherAttendanceTakePage extends StatefulWidget {
  final String token;

  const TeacherAttendanceTakePage({super.key, required this.token});

  @override
  State<TeacherAttendanceTakePage> createState() => _TeacherAttendanceTakePageState();
}

class _TeacherAttendanceTakePageState extends State<TeacherAttendanceTakePage> {
  static const Color _orange = Color(0xFFF37021);
  static const Color _border = Color(0xFFEDEDED);
  static const Color _textGrey = Color(0xFF9A9A9A);
  static const Color _rowAlt = Color(0xFFFBFBFB);

  late TeacherController _controller;
  late TextEditingController _dateCtrl;

  List<ClassRoomResponse> _classes = [];
  ClassRoomResponse? _selectedClass;

  DateTime _selectedDate = DateTime.now();
  int _selectedPeriod = 1;
  final List<int> _periods = List.generate(10, (index) => index + 1);

  List<TeacherStudentAttendanceResponse> _students = [];
  Map<int, String> _attendanceStatus = {};
  Map<int, String> _attendanceNotes = {};

  bool _isLoadingClasses = true;
  bool _isLoadingStudents = false;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TeacherController(token: widget.token);
    _dateCtrl = TextEditingController(text: DateFormat('yyyy-MM-dd').format(_selectedDate));
    _fetchClasses();
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchClasses() async {
    setState(() {
      _isLoadingClasses = true;
      _error = null;
    });
    try {
      final result = await _controller.getTeachingClasses();
      if (result.status && result.data != null) {
        setState(() {
          _classes = result.data!;
          if (_classes.isNotEmpty) {
            _selectedClass = _classes.first;
            _fetchStudents();
          }
          _isLoadingClasses = false;
        });
      } else {
        setState(() {
          _error = result.message;
          _isLoadingClasses = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi kết nối: $e';
        _isLoadingClasses = false;
      });
    }
  }

  Future<void> _fetchStudents() async {
    if (_selectedClass == null) return;
    setState(() {
      _isLoadingStudents = true;
      _error = null;
      _students.clear();
      _attendanceStatus.clear();
      _attendanceNotes.clear();
    });
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final result = await _controller.getStudentsForAttendance(
          _selectedClass!.id, formattedDate, _selectedPeriod);
      if (result.status && result.data != null) {
        setState(() {
          _students = result.data!;
          for (var student in _students) {
            _attendanceStatus[student.studentId] = student.status ?? 'PRESENT';
            _attendanceNotes[student.studentId] = student.note ?? '';
          }
          _isLoadingStudents = false;
        });
      } else {
        setState(() {
          _error = result.message;
          _isLoadingStudents = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi kết nối hoặc không có quyền truy cập lịch này: $e';
        _isLoadingStudents = false;
      });
    }
    String getVietnameseError(String? errorCode) {
      switch (errorCode) {
        case 'ATTENDANCE_NOT_FOUND':
          return 'Chưa đến thời gian điểm danh của lớp này.';
        case 'ATTENDANCE_NOT_ASSIGNED':
          return 'Bạn không được phân công giảng dạy lớp này.';
        case 'ATTENDANCE_INVALID_PERIOD':
          return 'Bạn không được phân công giảng dạy ở tiết học này.';
        default:
          return errorCode ?? 'Đã xảy ra lỗi.';
      }
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _orange,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF333333),
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null && date != _selectedDate) {
      setState(() {
        _selectedDate = date;
        _dateCtrl.text = DateFormat('yyyy-MM-dd').format(date);
      });
      _fetchStudents();
    }
  }

  Future<void> _saveAttendance() async {
    if (_selectedClass == null || _students.isEmpty) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final attendances = _students.map((s) {
        return StudentAttendanceRequest(
          studentId: s.studentId,
          status: _attendanceStatus[s.studentId]!,
          note: _attendanceNotes[s.studentId],
        );
      }).toList();

      final request = TeacherTakeAttendanceRequest(
        classRoomId: _selectedClass!.id,
        attendanceDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
        period: _selectedPeriod,
        attendances: attendances,
      );

      final result = await _controller.takeAttendance(request);

      if (!mounted) return;

      if (result.status) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Lưu điểm danh thành công!'),
          backgroundColor: Colors.green,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Lỗi: ${result.message}'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Lỗi hệ thống: $e'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
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
              'Điểm danh',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(context),
            _buildFilters(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _students.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: _isSaving ? null : _saveAttendance,
        backgroundColor: _orange,
        icon: _isSaving
            ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.save_rounded, color: Colors.white),
        label: Text(
          _isSaving ? 'Đang lưu...' : 'Lưu điểm danh',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      )
          : null,
    );
  }

  Widget _buildFilters() {
    if (_isLoadingClasses) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator(color: _orange)),
      );
    }
    if (_classes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Bạn không có lịch dạy lớp nào',
            style: TextStyle(color: _textGrey)),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<ClassRoomResponse>(
                  value: _selectedClass,
                  decoration: InputDecoration(
                    labelText: 'Chọn lớp',
                    labelStyle: const TextStyle(color: _orange),
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _orange),
                    ),
                  ),
                  items: _classes
                      .map((c) =>
                      DropdownMenuItem(value: c, child: Text(c.name)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null && val != _selectedClass) {
                      setState(() => _selectedClass = val);
                      _fetchStudents();
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _selectedPeriod,
                  decoration: InputDecoration(
                    labelText: 'Tiết học',
                    labelStyle: const TextStyle(color: _orange),
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _orange),
                    ),
                  ),
                  items: _periods
                      .map((p) =>
                      DropdownMenuItem(value: p, child: Text('Tiết $p')))
                      .toList(),
                  onChanged: (val) {
                    if (val != null && val != _selectedPeriod) {
                      setState(() => _selectedPeriod = val);
                      _fetchStudents();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: const Text(
              'Ngày điểm danh',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _dateCtrl,
            readOnly: true,
            onTap: _pickDate,
            decoration: InputDecoration(
              hintText: 'yyyy-mm-dd',
              hintStyle: const TextStyle(fontSize: 13, color: _textGrey),
              filled: true,
              fillColor: const Color(0xFFF7F6F6),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              suffixIcon: const Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: _orange,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _orange, width: 1.5),
              ),
            ),
            style: const TextStyle(fontSize: 13.5, color: Color(0xFF333333)),
          )
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoadingStudents) {
      return const Center(child: CircularProgressIndicator(color: _orange));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: _textGrey, fontSize: 14)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchStudents,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(backgroundColor: _orange, foregroundColor: Colors.white),
              )
            ],
          ),
        ),
      );
    }
    if (_students.isEmpty) {
      return const Center(
        child: Text('Không có học sinh trong lớp này hoặc chưa chọn đúng thời gian',
            style: TextStyle(color: _textGrey), textAlign: TextAlign.center),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: _students.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: _border),
      itemBuilder: (context, index) {
        final student = _students[index];
        final isAlt = index % 2 == 1;
        return _buildTableRow(student, isAlt);
      },
    );
  }

  Widget _buildTableRow(TeacherStudentAttendanceResponse student, bool isAlt) {
    return Container(
      color: isAlt ? _rowAlt : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: _orange.withOpacity(0.12),
                child: const Icon(Icons.person, color: _orange, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.studentName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF222222)),
                    ),
                    Text(
                      student.mssv,
                      style: const TextStyle(fontSize: 12, color: _textGrey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Status selector
          DropdownButtonFormField<String>(
            value: _attendanceStatus[student.studentId],
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            items: const [
              DropdownMenuItem(value: 'PRESENT', child: Text('Có mặt', style: TextStyle(color: Colors.green))),
              DropdownMenuItem(value: 'ABSENT_WITH_PERMISSION', child: Text('Vắng có phép', style: TextStyle(color: Colors.orange))),
              DropdownMenuItem(value: 'ABSENT_WITHOUT_PERMISSION', child: Text('Vắng không phép', style: TextStyle(color: Colors.red))),
              DropdownMenuItem(value: 'LATE', child: Text('Đi trễ', style: TextStyle(color: Colors.blue))),
              DropdownMenuItem(value: 'EARLY_LEAVE', child: Text('Về sớm', style: TextStyle(color: Colors.deepPurple))),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _attendanceStatus[student.studentId] = val;
                });
              }
            },
          ),
          const SizedBox(height: 8),
          // Note field
          TextFormField(
            initialValue: _attendanceNotes[student.studentId],
            decoration: InputDecoration(
              hintText: 'Ghi chú...',
              hintStyle: const TextStyle(color: _textGrey, fontSize: 13),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: (val) {
              _attendanceNotes[student.studentId] = val;
            },
          )
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 64,
      decoration: const BoxDecoration(color: _orange),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            Icons.home_rounded,
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
          _buildNavItem(Icons.chat_bubble_outline_rounded),
          _buildNavItem(Icons.person_outline_rounded),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon,
      {bool isActive = false, VoidCallback? onPressed}) {
    return IconButton(
      icon: Icon(icon,
          color: isActive ? Colors.white : Colors.white.withOpacity(0.65),
          size: 28),
      onPressed: onPressed ?? () {},
    );
  }
}
