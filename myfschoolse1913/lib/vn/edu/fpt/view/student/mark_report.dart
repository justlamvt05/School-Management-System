import 'package:flutter/material.dart';
import '../../controller/student_controller.dart';
import '../../model/grade_response.dart';
import '../user/notification.dart';
import '../user_profile.dart';

/// Trang "Bảng điểm" – gọi API /api/student/grades/{studentId}
class MarkReportPage extends StatefulWidget {
  final String token;

  const MarkReportPage({super.key, required this.token});

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
  List<GradeItem> _allGrades = [];
  List<String> _semesters = [];
  String? _selectedSemester;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = StudentController(token: widget.token);
    _fetchGrades();
  }

  Future<void> _fetchGrades() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _controller.getGrades(2);
      if (result.status && result.data != null) {
        setState(() {
          _allGrades = result.data!;
          // Lấy danh sách học kỳ duy nhất, giữ thứ tự
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

  /// Lọc điểm theo học kỳ được chọn
  List<GradeItem> get _filteredGrades {
    if (_selectedSemester == null) return [];
    return _allGrades
        .where((g) => g.semesterName == _selectedSemester)
        .toList();
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

  // ── Bộ chọn học kỳ ─────────────────────────────
  Widget _buildSemesterSelector() {
    if (_semesters.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Row(
        children: _semesters.map((semester) {
          final isSelected = semester == _selectedSemester;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => setState(() => _selectedSemester = semester),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? _orange : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? _orange : _border,
                    width: 1,
                  ),
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
                onPressed: _fetchGrades,
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

    final grades = _filteredGrades;
    if (grades.isEmpty) {
      return const Center(
        child: Text(
          'Không có dữ liệu điểm',
          style: TextStyle(color: _textGrey, fontSize: 14),
        ),
      );
    }

    return _buildTable(grades);
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
              Navigator.pop(context);
            },
          ),
          _buildNavItem(
            Icons.chat_bubble_outline_rounded,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      NotificationPage(token: widget.token),
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