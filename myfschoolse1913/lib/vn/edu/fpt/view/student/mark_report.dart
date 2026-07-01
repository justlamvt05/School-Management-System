import 'package:flutter/material.dart';
import '../../controller/student_controller.dart';
import '../../model/grade_response.dart';
import '../../model/classroom_response.dart';
import '../user/notification.dart';
import '../user_profile.dart';

// Model nhỏ để giữ semester kèm schoolYear
class _SemesterOption {
  final int id;
  final String name;
  final String schoolYear;
  const _SemesterOption({required this.id, required this.name, required this.schoolYear});
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _SemesterOption &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          schoolYear == other.schoolYear;

  @override
  int get hashCode => id.hashCode ^ schoolYear.hashCode;
}

/// Trang "Bảng điểm" – gọi API /api/student/grades/{studentId}/...
class MarkReportPage extends StatefulWidget {
  final String token;
  final int? studentId;
  final int? classId;

  const MarkReportPage({super.key, required this.token, this.studentId, this.classId});

  @override
  State<MarkReportPage> createState() => _MarkReportPageState();
}

class _MarkReportPageState extends State<MarkReportPage> {
  // ── Brand colors (đồng bộ với HomePage) ──────
  static const Color _orange = Color(0xFFF37021);
  static const Color _rowAlt = Color(0xFFF7F6F6);
  static const Color _border = Color(0xFFEDEDED);
  static const Color _textDark = Color(0xFF333333);
  static const Color _textGrey = Color(0xFF9A9A9A);

  late StudentController _controller;
  
  // Data cho filters
  List<ClassRoomResponse> _classes = [];
  ClassRoomResponse? _selectedClass;
  
  List<_SemesterOption> _semesterOptions = [];
  _SemesterOption? _selectedSemester;

  // Data cho bảng điểm
  List<GradeItem> _grades = [];
  bool _isLoadingClasses = true;
  bool _isLoadingGrades = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = StudentController(token: widget.token);
    _fetchClassHistory();
  }

  Future<void> _fetchClassHistory() async {
    setState(() {
      _isLoadingClasses = true;
      _error = null;
    });

    try {
      final result = await _controller.getStudentClassHistory(widget.studentId ?? 2); // default studentId = 2
      if (result.status && result.data != null) {
        final classes = result.data!;
        ClassRoomResponse? firstClass = classes.isNotEmpty ? classes.first : null;
        
        List<_SemesterOption> semOptions = [];
        _SemesterOption? firstSem;

        if (firstClass != null) {
          semOptions = _buildSemesterOptions(firstClass.schoolYear);
          firstSem = semOptions.isNotEmpty ? semOptions.first : null;
        }

        setState(() {
          _classes = classes;
          _selectedClass = firstClass;
          _semesterOptions = semOptions;
          _selectedSemester = firstSem;
          _isLoadingClasses = false;
        });

        if (firstClass != null) {
          _fetchGrades();
        }
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

  // ── Sinh semester options dựa trên school year ─────────────────
  List<_SemesterOption> _buildSemesterOptions(String schoolYear) {
    const Map<String, List<_SemesterOption>> _seedMap = {
      '2025-2026': [
        _SemesterOption(id: 1, name: 'Học kỳ 1', schoolYear: '2025-2026'),
        _SemesterOption(id: 2, name: 'Học kỳ 2', schoolYear: '2025-2026'),
      ],
      '2024-2025': [
        _SemesterOption(id: 3, name: 'Học kỳ 1', schoolYear: '2024-2025'),
        _SemesterOption(id: 4, name: 'Học kỳ 2', schoolYear: '2024-2025'),
      ],
    };
    return _seedMap[schoolYear] ?? [
      _SemesterOption(id: 1, name: 'Học kỳ 1', schoolYear: schoolYear),
      _SemesterOption(id: 2, name: 'Học kỳ 2', schoolYear: schoolYear),
    ];
  }

  void _onClassChanged(ClassRoomResponse? val) {
    if (val == null || val == _selectedClass) return;
    
    final semOptions = _buildSemesterOptions(val.schoolYear);
    setState(() {
      _selectedClass = val;
      _semesterOptions = semOptions;
      _selectedSemester = semOptions.isNotEmpty ? semOptions.first : null;
      _grades = [];
    });
    _fetchGrades();
  }

  Future<void> _fetchGrades() async {
    if (_selectedClass == null || _selectedSemester == null) return;
    
    setState(() {
      _isLoadingGrades = true;
      _error = null;
    });

    try {
      final result = await _controller.getGradesBySchoolYearAndSemester(
        widget.studentId ?? 2, // default studentId = 2
        _selectedClass!.schoolYear,
        _selectedSemester!.id,
      );
      if (result.status && result.data != null) {
        setState(() {
          _grades = result.data!;
          _isLoadingGrades = false;
        });
      } else {
        setState(() {
          _error = result.message;
          _isLoadingGrades = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi kết nối: $e';
        _isLoadingGrades = false;
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
            _buildFilters(),
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
              'Bảng điểm',
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

  // ── Bộ chọn lớp và học kỳ ─────────────────────────────
  Widget _buildFilters() {
    if (_isLoadingClasses) return const SizedBox.shrink();

    if (_classes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Không có dữ liệu lớp học', style: TextStyle(color: _textGrey)),
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
          // Lớp
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<ClassRoomResponse>(
              value: _selectedClass,
              decoration: _dropDeco('Lớp - Năm học'),
              isExpanded: true,
              items: _classes
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text('${c.name} (${c.schoolYear})', overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: _onClassChanged,
            ),
          ),
          const SizedBox(width: 12),
          // Học kỳ
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<_SemesterOption>(
              value: _selectedSemester,
              decoration: _dropDeco('Học kỳ'),
              isExpanded: true,
              items: _semesterOptions
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.name, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null && val != _selectedSemester) {
                  setState(() => _selectedSemester = val);
                  _fetchGrades();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _dropDeco(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _orange, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _orange),
        ),
      );

  // ── Body chính ────────────────────────────────
  Widget _buildBody() {
    if (_isLoadingClasses || _isLoadingGrades) {
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
              Icon(Icons.error_outline_rounded, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _textGrey, fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _classes.isEmpty ? _fetchClassHistory : _fetchGrades,
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

    if (_grades.isEmpty) {
      return const Center(
        child: Text(
          'Không có dữ liệu điểm',
          style: TextStyle(color: _textGrey, fontSize: 14),
        ),
      );
    }

    return _buildTable(_grades);
  }

  // ── Bảng điểm ──────────────────────────────────
  Widget _buildTable(List<GradeItem> grades) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Table(
        border: const TableBorder(
          top: BorderSide(color: _border, width: 1),
          bottom: BorderSide(color: _border, width: 1),
          horizontalInside: BorderSide(color: _border, width: 1),
        ),
        columnWidths: const {
          0: FlexColumnWidth(1.2),
          1: FlexColumnWidth(0.8),
          2: FlexColumnWidth(0.8),
          3: FlexColumnWidth(0.8),
          4: FlexColumnWidth(0.8),
          5: FlexColumnWidth(0.8),
        },
        children: [
          _buildHeaderRow(),
          for (int i = 0; i < grades.length; i++)
            _buildDataRow(grades[i], isAlt: i.isOdd),
        ],
      ),
    );
  }

  TableRow _buildHeaderRow() {
    return const TableRow(
      decoration: BoxDecoration(color: Colors.white),
      children: [
        _HeaderCell('Môn'),
        _HeaderCell('Miệng'),
        _HeaderCell('15 phút'),
        _HeaderCell('1 tiết'),
        _HeaderCell('Cuối kỳ'),
        _HeaderCell('TBM'),
      ],
    );
  }

  TableRow _buildDataRow(GradeItem grade, {bool isAlt = false}) {
    return TableRow(
      decoration: BoxDecoration(color: isAlt ? _rowAlt : Colors.white),
      children: [
        _DataCell(grade.subjectName, bold: true, alignLeft: true),
        _DataCell(_fmt(grade.oralScore)),
        _DataCell(_fmt(grade.score15Min)),
        _DataCell(_fmt(grade.score1Period)),
        _DataCell(_fmt(grade.finalExam)),
        _DataCell(_fmt(grade.averageScore), bold: true),
      ],
    );
  }

  static String _fmt(double value) {
    return value % 1 == 0 ? value.toInt().toString() : value.toString();
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
              // Quay về trang chủ (HomePage là route gốc đã push trang này)
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

// ── Header / data cell widgets ───────────────
class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF9A9A9A),
        ),
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  final String text;
  final bool bold;
  final bool alignLeft;
  const _DataCell(this.text, {this.bold = false, this.alignLeft = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      child: Text(
        text,
        textAlign: alignLeft ? TextAlign.left : TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          color: const Color(0xFF333333),
        ),
      ),
    );
  }
}