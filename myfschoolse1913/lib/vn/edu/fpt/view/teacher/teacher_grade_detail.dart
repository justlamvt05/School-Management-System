import 'package:flutter/material.dart';
import '../../model/class_grade_response.dart';
import '../user/notification.dart';
import '../user_profile.dart';

/// Trang chi tiết điểm của 1 học sinh – layout giống MarkReportPage
class TeacherStudentGradeDetailPage extends StatelessWidget {
  final String token;
  final String studentName;
  final String studentCode;
  final String semesterName;
  final List<ClassGradeResponse> grades;

  static const Color _orange = Color(0xFFF37021);
  static const Color _rowAlt = Color(0xFFF7F6F6);
  static const Color _border = Color(0xFFEDEDED);
  static const Color _textGrey = Color(0xFF9A9A9A);

  const TeacherStudentGradeDetailPage({
    super.key,
    required this.token,
    required this.studentName,
    required this.studentCode,
    required this.semesterName,
    required this.grades,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(context),
            _buildStudentInfoCard(),
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
          const Center(
            child: Text(
              'Bảng điểm học sinh',
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
                  padding: const EdgeInsets.symmetric(horizontal: 6)),
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 11),
              label: const Text('Quay lại',
                  style: TextStyle(color: Colors.white, fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentInfoCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3EA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _orange.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: _orange.withOpacity(0.15),
            child: const Icon(Icons.person, color: _orange, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF222222)),
                ),
                const SizedBox(height: 2),
                Text(studentCode,
                    style:
                    const TextStyle(fontSize: 13, color: _textGrey)),
              ],
            ),
          ),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _orange,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              semesterName,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (grades.isEmpty) {
      return const Center(
        child: Text('Không có dữ liệu điểm',
            style: TextStyle(color: _textGrey, fontSize: 14)),
      );
    }
    return _buildTable();
  }

  Widget _buildTable() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Table(
        border: const TableBorder(
          top: BorderSide(color: _border, width: 1),
          bottom: BorderSide(color: _border, width: 1),
          horizontalInside: BorderSide(color: _border, width: 1),
        ),
        columnWidths: const {
          0: FlexColumnWidth(1.4),
          1: FlexColumnWidth(0.8),
          2: FlexColumnWidth(0.8),
          3: FlexColumnWidth(0.8),
          4: FlexColumnWidth(0.9),
          5: FlexColumnWidth(0.8),
        },
        children: [
          _buildHeaderRow(),
          for (int i = 0; i < grades.length; i++)
            _buildDataRow(grades[i], isAlt: i.isOdd),
          if (grades.isNotEmpty) _buildAverageRow(),
        ],
      ),
    );
  }

  TableRow _buildHeaderRow() {
    return const TableRow(
      decoration: BoxDecoration(color: Color(0xFFFFF3EA)),
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

  TableRow _buildDataRow(ClassGradeResponse grade, {bool isAlt = false}) {
    final avg = grade.averageScore;
    Color avgColor = const Color(0xFF333333);
    if (avg != null) {
      if (avg >= 8.0) avgColor = const Color(0xFF2E7D32);
      else if (avg >= 6.5) avgColor = const Color(0xFF1565C0);
      else if (avg >= 5.0) avgColor = const Color(0xFFF57F17);
      else avgColor = Colors.red;
    }

    return TableRow(
      decoration: BoxDecoration(color: isAlt ? _rowAlt : Colors.white),
      children: [
        _DataCell(grade.subjectName, bold: true, alignLeft: true),
        _DataCell(_fmt(grade.oralScore)),
        _DataCell(_fmt(grade.score15Min)),
        _DataCell(_fmt(grade.score1Period)),
        _DataCell(_fmt(grade.finalExam)),
        _DataCell(_fmt(grade.averageScore), bold: true, customColor: avgColor),
      ],
    );
  }

  TableRow _buildAverageRow() {
    // Tính TB chung tất cả các môn
    final avgs = grades
        .where((g) => g.averageScore != null)
        .map((g) => g.averageScore!)
        .toList();
    final overall = avgs.isEmpty
        ? null
        : avgs.reduce((a, b) => a + b) / avgs.length;

    Color overallColor = _orange;
    if (overall != null) {
      if (overall >= 8.0) overallColor = const Color(0xFF2E7D32);
      else if (overall >= 6.5) overallColor = const Color(0xFF1565C0);
      else if (overall >= 5.0) overallColor = const Color(0xFFF57F17);
      else overallColor = Colors.red;
    }

    return TableRow(
      decoration: const BoxDecoration(color: Color(0xFFFFF3EA)),
      children: [
        const _DataCell('TB chung', bold: true, alignLeft: true),
        const _DataCell(''),
        const _DataCell(''),
        const _DataCell(''),
        const _DataCell(''),
        _DataCell(
          _fmt(overall),
          bold: true,
          customColor: overallColor,
        ),
      ],
    );
  }

  static String _fmt(double? value) {
    if (value == null) return '-';
    return value % 1 == 0
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }

  // ── Bottom Nav (đồng bộ với TeacherHomePage) ─────────
  Widget _buildBottomNav(BuildContext context) {
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
                  builder: (_) => NotificationPage(token: token),
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
                  builder: (_) => UserProfilePage(token: token),
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

// ── Shared cell widgets ───────────────────────────────────────────────────────
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
            color: Color(0xFFF37021)),
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  final String text;
  final bool bold;
  final bool alignLeft;
  final Color? customColor;

  const _DataCell(
      this.text, {
        this.bold = false,
        this.alignLeft = false,
        this.customColor,
      });

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
          color: customColor ?? const Color(0xFF333333),
        ),
      ),
    );
  }
}