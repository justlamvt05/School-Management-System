import 'package:flutter/material.dart';
import 'package:myfschoolse1913/vn/edu/fpt/view/teacher/teacher_grade_detail.dart';
import '../../controller/teacher_controller.dart';
import '../../model/class_grade_response.dart';
import 'teacher_home_page.dart';

class TeacherHomeroomGradesPage extends StatefulWidget {
  final String token;

  const TeacherHomeroomGradesPage({super.key, required this.token});

  @override
  State<TeacherHomeroomGradesPage> createState() =>
      _TeacherHomeroomGradesPageState();
}

class _TeacherHomeroomGradesPageState
    extends State<TeacherHomeroomGradesPage> {
  static const Color _orange = Color(0xFFF37021);
  static const Color _rowAlt = Color(0xFFF7F6F6);
  static const Color _border = Color(0xFFEDEDED);
  static const Color _textDark = Color(0xFF333333);
  static const Color _textGrey = Color(0xFF9A9A9A);

  late TeacherController _controller;
  List<ClassGradeResponse> _allGrades = [];
  List<String> _semesters = [];
  String? _selectedSemester;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TeacherController(token: widget.token);
    _fetchGrades();
  }

  Future<void> _fetchGrades() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await _controller.getHomeroomGrades();
      if (result.status && result.data != null) {
        setState(() {
          _allGrades = result.data!;
          final seen = <String>{};
          _semesters = _allGrades
              .map((g) => g.semesterName)
              .where((s) => seen.add(s))
              .toList();
          _selectedSemester =
          _semesters.isNotEmpty ? _semesters.first : null;
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

  /// Nhóm theo học sinh (mỗi HS 1 dòng), lọc theo học kỳ đang chọn
  List<_StudentSummary> get _studentSummaries {
    if (_selectedSemester == null) return [];

    final filtered =
    _allGrades.where((g) => g.semesterName == _selectedSemester).toList();

    // Gom nhóm theo studentId
    final Map<String, _StudentSummary> map = {};
    for (final g in filtered) {
      final key = g.studentId.toString();
      if (!map.containsKey(key)) {
        map[key] = _StudentSummary(
          studentId: g.studentId,
          studentCode: g.studentCode,
          studentName: g.studentName,
          grades: [],
        );
      }
      map[key]!.grades.add(g);
    }
    final list = map.values.toList();
    list.sort((a, b) => a.studentName.compareTo(b.studentName));
    return list;
  }

  void _openDetail(_StudentSummary summary) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeacherStudentGradeDetailPage(
          token: widget.token,
          studentName: summary.studentName,
          studentCode: summary.studentCode,
          semesterName: _selectedSemester ?? '',
          grades: summary.grades,
        ),
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
            _buildSemesterSelector(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: _orange,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Center(
            child: Text(
              'Điểm lớp chủ nhiệm',
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
              style:
              TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6)),
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

  Widget _buildSemesterSelector() {
    if (_semesters.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _semesters.map((semester) {
            final isSelected = semester == _selectedSemester;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => setState(() => _selectedSemester = semester),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? _orange : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: isSelected ? _orange : _border, width: 1),
                  ),
                  child: Text(
                    semester,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : _textDark,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _orange));
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
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _textGrey, fontSize: 14)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchGrades,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: _orange, foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    final summaries = _studentSummaries;
    if (summaries.isEmpty) {
      return const Center(
        child: Text('Không có dữ liệu điểm',
            style: TextStyle(color: _textGrey, fontSize: 14)),
      );
    }

    return Column(
      children: [
        // Table header
        Container(
          color: const Color(0xFFFFF3EA),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: const [
              SizedBox(width: 36),
              SizedBox(width: 10),
              Expanded(
                flex: 5,
                child: Text('Học sinh',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: _orange)),
              ),
              Expanded(
                flex: 3,
                child: Text('Mã học sinh',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: _orange)),
              ),
              Expanded(
                flex: 2,
                child: Text('Môn',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: _orange)),
              ),
              SizedBox(width: 32),
            ],
          ),
        ),
        const Divider(height: 1, color: _border),
        Expanded(
          child: ListView.separated(
            itemCount: summaries.length,
            separatorBuilder: (_, __) =>
            const Divider(height: 1, color: _border),
            itemBuilder: (context, index) {
              return _buildStudentRow(summaries[index], index.isOdd);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStudentRow(_StudentSummary summary, bool isAlt) {
    final subjectCount = summary.grades.length;
    return InkWell(
      onTap: () => _openDetail(summary),
      child: Container(
        color: isAlt ? _rowAlt : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: _orange.withOpacity(0.12),
              child: const Icon(Icons.person, color: _orange, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(summary.studentName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF222222))),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(summary.studentCode,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: _textGrey)),
            ),
            Expanded(
              flex: 2,
              child: Text('$subjectCount môn',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _orange)),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: _textGrey, size: 20),
          ],
        ),
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
          _buildNavItem(Icons.home_rounded, isActive: true, onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      TeacherHomePage(phone: '', token: widget.token)),
            );
          }),
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

// ── Helper model ──────────────────────────────────────────────────────────────
class _StudentSummary {
  final int studentId;
  final String studentCode;
  final String studentName;
  final List<ClassGradeResponse> grades;

  _StudentSummary({
    required this.studentId,
    required this.studentCode,
    required this.studentName,
    required this.grades,
  });
}