// teacher_grade_input_page.dart
import 'package:flutter/material.dart';
import '../../controller/teacher_controller.dart';
import '../../model/class_grade_response.dart';
import '../../model/classroom_response.dart';
import '../../model/teacher_grade_request.dart';
import 'teacher_home_page.dart';
import '../user/notification.dart';
import '../user_profile.dart';

// Model nhỏ để giữ semester kèm schoolYear
class _SemesterOption {
  final int id;
  final String name;
  final String schoolYear;
  const _SemesterOption(
      {required this.id, required this.name, required this.schoolYear});
}

class TeacherGradeInputPage extends StatefulWidget {
  final String token;

  const TeacherGradeInputPage({super.key, required this.token});

  @override
  State<TeacherGradeInputPage> createState() => _TeacherGradeInputPageState();
}

class _TeacherGradeInputPageState extends State<TeacherGradeInputPage> {
  static const Color _orange = Color(0xFFF37021);
  static const Color _border = Color(0xFFEDEDED);
  static const Color _textGrey = Color(0xFF9A9A9A);
  static const Color _rowAlt = Color(0xFFFBFBFB);

  late TeacherController _controller;

  List<ClassRoomResponse> _classes = [];
  ClassRoomResponse? _selectedClass;

  // Tất cả semester options, sinh ra từ school years của lớp đang chọn
  List<_SemesterOption> _semesterOptions = [];
  _SemesterOption? _selectedSemester;

  List<ClassGradeResponse> _students = [];
  bool _isLoadingClasses = true;
  bool _isLoadingStudents = false;
  String? _error;

  String? _selectedSchoolYear;

  // ── Sinh danh sách năm học từ tên lớp + schoolYear hiện tại ──────────────
  List<String> _getSchoolYearOptions(ClassRoomResponse? cls) {
    if (cls == null) return [];
    final name = cls.name;
    final sy = cls.schoolYear;

    final match = RegExp(r'^(\d+)').firstMatch(name);
    if (match == null) return [sy];

    final currentGrade = int.tryParse(match.group(1)!);
    if (currentGrade == null || currentGrade < 10 || currentGrade > 12) {
      return [sy];
    }

    final parts = sy.split('-');
    if (parts.length != 2) return [sy];

    final endYear = int.tryParse(parts[1]);
    if (endYear == null) return [sy];

    final options = <String>[];
    for (int g = 10; g <= currentGrade; g++) {
      final eYear = endYear - (currentGrade - g);
      options.add('${eYear - 1}-$eYear');
    }
    return options.reversed.toList(); // mới nhất trước
  }

  // ── Sinh semester options dựa trên school year đang chọn ─────────────────
  // Quy tắc: mỗi school year có 2 kỳ.
  // Vì backend seed: 2025-2026 → id 1,2 ; 2024-2025 → id 3,4 ; ...
  // Nếu bạn có API lấy semesters thì thay thế logic này bằng API call.
  List<_SemesterOption> _buildSemesterOptions(String schoolYear) {
    // Map cứng dựa trên dữ liệu seed — thay bằng API nếu cần
    const Map<String, List<_SemesterOption>> _seedMap = {
      '2025-2026': [
        _SemesterOption(id: 1, name: 'Học kỳ 1', schoolYear: '2025-2026'),
        _SemesterOption(id: 2, name: 'Học kỳ 2', schoolYear: '2025-2026'),
      ],
      '2024-2025': [
        _SemesterOption(id: 3, name: 'Học kỳ 1', schoolYear: '2024-2025'),
        _SemesterOption(id: 4, name: 'Học kỳ 2', schoolYear: '2024-2025'),
      ],
      // Thêm năm học khác nếu cần
    };
    return _seedMap[schoolYear] ?? [
      _SemesterOption(id: 1, name: 'Học kỳ 1', schoolYear: schoolYear),
      _SemesterOption(id: 2, name: 'Học kỳ 2', schoolYear: schoolYear),
    ];
  }

  // ── Cập nhật semester options khi đổi school year ────────────────────────
  void _onSchoolYearChanged(String? newYear) {
    if (newYear == null || newYear == _selectedSchoolYear) return;
    final options = _buildSemesterOptions(newYear);
    setState(() {
      _selectedSchoolYear = newYear;
      _semesterOptions = options;
      _selectedSemester = options.isNotEmpty ? options.first : null;
    });
    _fetchStudents();
  }

  // ── Cập nhật state khi đổi lớp ───────────────────────────────────────────
  void _onClassChanged(ClassRoomResponse? val) {
    if (val == null || val == _selectedClass) return;
    final syOptions = _getSchoolYearOptions(val);
    final firstYear = syOptions.isNotEmpty ? syOptions.first : val.schoolYear;
    final semOptions = _buildSemesterOptions(firstYear);
    setState(() {
      _selectedClass = val;
      _selectedSchoolYear = firstYear;
      _semesterOptions = semOptions;
      _selectedSemester = semOptions.isNotEmpty ? semOptions.first : null;
      _students = [];
    });
    _fetchStudents();
  }

  @override
  void initState() {
    super.initState();
    _controller = TeacherController(token: widget.token);
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    setState(() {
      _isLoadingClasses = true;
      _error = null;
    });
    try {
      final result = await _controller.getTeachingClasses();
      if (result.status && result.data != null) {
        final classes = result.data!;
        ClassRoomResponse? firstClass =
        classes.isNotEmpty ? classes.first : null;
        String? firstYear;
        List<_SemesterOption> semOptions = [];
        _SemesterOption? firstSem;

        if (firstClass != null) {
          final syOptions = _getSchoolYearOptions(firstClass);
          firstYear = syOptions.isNotEmpty ? syOptions.first : firstClass.schoolYear;
          semOptions = _buildSemesterOptions(firstYear);
          firstSem = semOptions.isNotEmpty ? semOptions.first : null;
        }

        setState(() {
          _classes = classes;
          _selectedClass = firstClass;
          _selectedSchoolYear = firstYear;
          _semesterOptions = semOptions;
          _selectedSemester = firstSem;
          _isLoadingClasses = false;
        });

        if (firstClass != null) _fetchStudents();
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
    if (_selectedClass == null || _selectedSemester == null) return;
    setState(() {
      _isLoadingStudents = true;
      _error = null;
    });
    try {
      // Truyền semesterId đúng với school year đang chọn
      final result = await _controller.getStudentsGradesByClassAndSemester(
        _selectedClass!.id,
        _selectedSemester!.id, // ← đã đồng bộ với school year
      );
      if (result.status && result.data != null) {
        setState(() {
          _students = result.data!;
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
        _error = 'Lỗi tải danh sách học sinh: $e';
        _isLoadingStudents = false;
      });
    }
  }

  void _openGradeDialog(ClassGradeResponse student) {
    if (_selectedSemester == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn học kỳ trước')));
      return;
    }
    showDialog(
      context: context,
      builder: (_) => _GradeDialog(
        student: student,
        semesterId: _selectedSemester!.id,
        schoolYear: _selectedSemester!.schoolYear,
        controller: _controller,
        onGradeSaved: _fetchStudents,
      ),
    );
  }

  // ── Top bar ──────────────────────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: _orange,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Center(
            child: Text(
              'Nhập điểm',
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
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 11),
              label: const Text('Trang chính',
                  style: TextStyle(color: Colors.white, fontSize: 11)),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopBar(context),
          _buildFilters(),
          Expanded(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
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

    final syOptions = _getSchoolYearOptions(_selectedClass);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          // Lớp
          Expanded(
            child: DropdownButtonFormField<ClassRoomResponse>(
              value: _selectedClass,
              decoration: _dropDeco('Chọn lớp'),
              items: _classes
                  .map(
                    (c) => DropdownMenuItem(
                  value: c,
                  child: Text(c.name),
                ),
              )
                  .toList(),
              onChanged: _onClassChanged,
            ),
          ),
          const SizedBox(width: 12),
          // Học kỳ
          Expanded(
            child: DropdownButtonFormField<_SemesterOption>(
              value: _selectedSemester,
              decoration: _dropDeco('Học kỳ'),
              items: _semesterOptions
                  .map(
                    (s) => DropdownMenuItem(
                  value: s,
                  child: Text(s.name),
                ),
              )
                  .toList(),
              onChanged: (val) {
                if (val != null && val != _selectedSemester) {
                  setState(() => _selectedSemester = val);
                  _fetchStudents();
                }
              },
            ),
          ),
          // Năm học
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedSchoolYear,
              decoration: _dropDeco('Năm học'),
              items: syOptions
                  .map(
                    (sy) => DropdownMenuItem(
                  value: sy,
                  child: Text(sy),
                ),
              )
                  .toList(),
              onChanged: _onSchoolYearChanged,
            ),
          ),
          const SizedBox(width: 12),


        ],
      ),
    );
  }

  InputDecoration _dropDeco(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: _orange),
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _orange),
    ),
  );

  Widget _buildBody() {
    if (_isLoadingStudents) {
      return const Center(child: CircularProgressIndicator(color: _orange));
    }
    if (_error != null) {
      return Center(
          child: Text(_error!, style: const TextStyle(color: Colors.red)));
    }
    if (_students.isEmpty) {
      return const Center(
        child: Text('Không có học sinh trong lớp này',
            style: TextStyle(color: _textGrey)),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Table header
          Container(
            color: const Color(0xFFFFF3EA),
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: const [
                SizedBox(width: 32),
                SizedBox(width: 8),
                Expanded(
                  flex: 5,
                  child: Text('Học sinh',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: _orange)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('TBM',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: _orange)),
                ),
                SizedBox(width: 90),
              ],
            ),
          ),
          const Divider(height: 1, color: _border),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _students.length,
            separatorBuilder: (_, __) =>
            const Divider(height: 1, color: _border),
            itemBuilder: (context, index) {
              return _buildTableRow(_students[index], index % 2 == 1);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(ClassGradeResponse student, bool isAlt) {
    final avg = student.averageScore;
    final hasGrade = student.gradeId != null;

    Color avgColor = Colors.black87;
    if (avg != null) {
      if (avg >= 8.0) avgColor = const Color(0xFF2E7D32);
      else if (avg >= 6.5) avgColor = const Color(0xFF1565C0);
      else if (avg >= 5.0) avgColor = const Color(0xFFF57F17);
      else avgColor = Colors.red;
    }

    return Container(
      color: isAlt ? _rowAlt : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: _orange.withOpacity(0.12),
            child: const Icon(Icons.person, color: _orange, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.studentName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF222222))),
                Text(student.studentCode,
                    style:
                    const TextStyle(fontSize: 12, color: _textGrey)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: avg != null
                  ? Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: avgColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _fmtScore(avg),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: avgColor),
                ),
              )
                  : const Text('—',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _textGrey)),
            ),
          ),
          SizedBox(
            width: 90,
            child: TextButton.icon(
              // ← bỏ tham số schoolYear thừa, lấy từ _selectedSemester
              onPressed: () => _openGradeDialog(student),
              icon: Icon(
                hasGrade ? Icons.edit_outlined : Icons.add_circle_outline,
                size: 16,
                color: _orange,
              ),
              label: Text(
                hasGrade ? 'Sửa' : 'Nhập điểm',
                style: const TextStyle(
                    fontSize: 12,
                    color: _orange,
                    fontWeight: FontWeight.w600),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtScore(double? val) => val == null
      ? ''
      : (val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(1));

  // ── Bottom Nav (đồng bộ với TeacherHomePage) ─────────
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

// ─── Grade Dialog ────────────────────────────────────────────────────────────

class _GradeDialog extends StatefulWidget {
  final ClassGradeResponse student;
  final int semesterId;
  final String schoolYear;
  final TeacherController controller;
  final VoidCallback onGradeSaved;

  const _GradeDialog({
    required this.student,
    required this.semesterId,
    required this.schoolYear,
    required this.controller,
    required this.onGradeSaved,
  });

  @override
  State<_GradeDialog> createState() => _GradeDialogState();
}

class _GradeDialogState extends State<_GradeDialog> {
  static const Color _orange = Color(0xFFF37021);

  late TextEditingController _oralCtrl;
  late TextEditingController _15mCtrl;
  late TextEditingController _1pCtrl;
  late TextEditingController _finalCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _oralCtrl = TextEditingController(text: _fmt(widget.student.oralScore));
    _15mCtrl = TextEditingController(text: _fmt(widget.student.score15Min));
    _1pCtrl = TextEditingController(text: _fmt(widget.student.score1Period));
    _finalCtrl = TextEditingController(text: _fmt(widget.student.finalExam));
  }

  String _fmt(double? val) => val == null
      ? ''
      : (val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(1));

  @override
  void dispose() {
    _oralCtrl.dispose();
    _15mCtrl.dispose();
    _1pCtrl.dispose();
    _finalCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveGrade() async {
    setState(() => _isSaving = true);
    try {
      final req = TeacherGradeRequest(
        studentId: widget.student.studentId,
        subjectId: widget.student.subjectId,
        semesterId: widget.semesterId,
        schoolYear: widget.schoolYear, // ← đã đồng bộ từ semester đang chọn
        oralScore: double.tryParse(_oralCtrl.text),
        score15Min: double.tryParse(_15mCtrl.text),
        score1Period: double.tryParse(_1pCtrl.text),
        finalExam: double.tryParse(_finalCtrl.text),
      );

      final isUpdate = widget.student.gradeId != null;
      final res = isUpdate
          ? await widget.controller.updateGrade(widget.student.gradeId!, req)
          : await widget.controller.inputGrade(req);

      if (!mounted) return;

      if (res.status) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Đã lưu điểm cho ${widget.student.studentName}'),
          backgroundColor: Colors.green,
        ));
        widget.onGradeSaved();
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(res.message),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding:
      const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dialog header
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: _orange,
              borderRadius:
              BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.grade_outlined,
                    color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nhập điểm',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      Text(widget.student.studentName,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close,
                      color: Colors.white, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Student info strip
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: const Color(0xFFFFF3EA),
            child: Row(
              children: [
                const Icon(Icons.badge_outlined,
                    size: 15, color: Color(0xFF9A9A9A)),
                const SizedBox(width: 6),
                Text(widget.student.studentCode,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF666666))),
                const Spacer(),
                Text('${widget.schoolYear} · ${_semesterLabel()}',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF9A9A9A))),
                if (widget.student.averageScore != null) ...[
                  const SizedBox(width: 8),
                  const Text('TBM: ',
                      style: TextStyle(
                          fontSize: 13, color: Color(0xFF666666))),
                  Text(
                    _fmt(widget.student.averageScore),
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _orange),
                  ),
                ]
              ],
            ),
          ),

          // Grade inputs
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildRow('Điểm miệng', _oralCtrl,
                    'Điểm kiểm tra miệng (0–10)'),
                const SizedBox(height: 14),
                _buildRow(
                    'KT 15 phút', _15mCtrl, 'Kiểm tra 15 phút (0–10)'),
                const SizedBox(height: 14),
                _buildRow(
                    'KT 1 tiết', _1pCtrl, 'Kiểm tra 1 tiết (0–10)'),
                const SizedBox(height: 14),
                _buildRow('Thi cuối kỳ', _finalCtrl,
                    'Điểm thi cuối học kỳ (0–10)'),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFEDEDED)),
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF666666),
                      side: const BorderSide(color: Color(0xFFCCCCCC)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveGrade,
                    icon: _isSaving
                        ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.save_outlined, size: 18),
                    label: Text(widget.student.gradeId != null
                        ? 'Cập nhật'
                        : 'Lưu điểm'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Lấy tên học kỳ từ semesterId để hiển thị trong dialog
  String _semesterLabel() {
    // Odd id = HK1, Even id = HK2 (theo seed data)
    return widget.semesterId % 2 == 1 ? 'Học kỳ 1' : 'Học kỳ 2';
  }

  Widget _buildRow(
      String label, TextEditingController ctrl, String hint) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF444444))),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: ctrl,
            keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                  fontSize: 12, color: Color(0xFFBBBBBB)),
              filled: true,
              fillColor: const Color(0xFFF7F6F6),
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 10, horizontal: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                const BorderSide(color: _orange, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}