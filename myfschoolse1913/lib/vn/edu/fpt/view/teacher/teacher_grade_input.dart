import 'package:flutter/material.dart';
import '../../controller/teacher_controller.dart';
import '../../model/class_grade_response.dart';
import '../../model/classroom_response.dart';
import '../../model/teacher_grade_request.dart';

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

  final List<Map<String, dynamic>> _semesters = [
    {'id': 1, 'name': 'Học kỳ 1'},
    {'id': 2, 'name': 'Học kỳ 2'},
  ];
  int _selectedSemesterId = 2;

  List<ClassGradeResponse> _students = [];
  bool _isLoadingClasses = true;
  bool _isLoadingStudents = false;
  String? _error;

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
    });
    try {
      final result = await _controller.getStudentsGradesByClassAndSemester(
          _selectedClass!.id, _selectedSemesterId);
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
    showDialog(
      context: context,
      builder: (_) => _GradeDialog(
        student: student,
        semesterId: _selectedSemesterId,
        controller: _controller,
        onGradeSaved: _fetchStudents,
      ),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopBar(context),
          _buildFilters(),
          Expanded(child: _buildBody()),
        ],
      ),
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
      child: Row(
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
              value: _selectedSemesterId,
              decoration: InputDecoration(
                labelText: 'Học kỳ',
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
              items: _semesters
                  .map((s) => DropdownMenuItem<int>(
                  value: s['id'], child: Text(s['name'])))
                  .toList(),
              onChanged: (val) {
                if (val != null && val != _selectedSemesterId) {
                  setState(() => _selectedSemesterId = val);
                  _fetchStudents();
                }
              },
            ),
          ),
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
                SizedBox(width: 90), // space for button
              ],
            ),
          ),
          const Divider(height: 1, color: _border),
          // Table rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _students.length,
            separatorBuilder: (_, __) =>
            const Divider(height: 1, color: _border),
            itemBuilder: (context, index) {
              final student = _students[index];
              final isAlt = index % 2 == 1;
              return _buildTableRow(student, isAlt);
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
          // Index avatar
          CircleAvatar(
            radius: 16,
            backgroundColor: _orange.withOpacity(0.12),
            child: const Icon(Icons.person, color: _orange, size: 18),
          ),
          const SizedBox(width: 8),
          // Name + code
          Expanded(
            flex: 5,
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
                  student.studentCode,
                  style:
                  const TextStyle(fontSize: 12, color: _textGrey),
                ),
              ],
            ),
          ),
          // TBM
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
          // Action button
          SizedBox(
            width: 90,
            child: TextButton.icon(
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
}

// ─── Grade Dialog ────────────────────────────────────────────────────────────

class _GradeDialog extends StatefulWidget {
  final ClassGradeResponse student;
  final int semesterId;
  final TeacherController controller;
  final VoidCallback onGradeSaved;

  const _GradeDialog({
    required this.student,
    required this.semesterId,
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
    _oralCtrl =
        TextEditingController(text: _fmt(widget.student.oralScore));
    _15mCtrl =
        TextEditingController(text: _fmt(widget.student.score15Min));
    _1pCtrl =
        TextEditingController(text: _fmt(widget.student.score1Period));
    _finalCtrl =
        TextEditingController(text: _fmt(widget.student.finalExam));
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
          content:
          Text('Đã lưu điểm cho ${widget.student.studentName}'),
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
                if (widget.student.averageScore != null) ...[
                  const Spacer(),
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

          // Divider + actions
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
                    label: Text(
                        widget.student.gradeId != null
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
              hintStyle:
              const TextStyle(fontSize: 12, color: Color(0xFFBBBBBB)),
              filled: true,
              fillColor: const Color(0xFFF7F6F6),
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 10, horizontal: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _orange, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}