import 'package:flutter/material.dart';
import '../../controller/application_controller.dart';
import '../../model/application_item.dart';
import '../../model/application_request.dart';
import '../user/notification.dart';
import 'student_home_page.dart';
import '../user_profile.dart';

class ApplicationPage extends StatefulWidget {
  final String token;

  const ApplicationPage({super.key, required this.token});

  @override
  State<ApplicationPage> createState() => _ApplicationPageState();
}

class _ApplicationPageState extends State<ApplicationPage> {
  // ── Brand colors ──
  static const Color _orange = Color(0xFFF37021);
  static const Color _bgCard = Color(0xFFF7F6F6);
  static const Color _textDark = Color(0xFF333333);
  static const Color _textGrey = Color(0xFF9A9A9A);
  static const Color _green = Color(0xFF3FAE5C);
  static const Color _yellow = Color(0xFFFFA834);
  static const Color _red = Color(0xFFE61610);
  static const Color _blue = Color(0xFF3D8AF7);

  // 0: Tạo đơn | 1: Đơn của tôi
  int _selectedTab = 0;

  late ApplicationController _applicationController;
  List<ApplicationItem> _myApplications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _applicationController = ApplicationController(token: widget.token);
    _fetchMyApplications();
  }

  Future<void> _fetchMyApplications() async {
    setState(() => _isLoading = true);
    try {
      final response = await _applicationController.getMyApplications();
      if (response.status && response.data != null) {
        setState(() {
          _myApplications = response.data!;
        });
      }
    } catch (e) {
      debugPrint('Error fetching applications: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Danh sách loại đơn cố định ──
  static final List<_ApplicationType> _applicationTypes = [
    _ApplicationType(
      icon: Icons.sick_outlined,
      label: 'Xin nghỉ học',
      typeKey: 'LEAVE_SCHOOL',
      color: _red,
    ),
    _ApplicationType(
      icon: Icons.access_time_rounded,
      label: 'Xin đi muộn / về sớm',
      typeKey: 'LATE_OR_EARLY_LEAVE',
      color: _yellow,
    ),
    _ApplicationType(
      icon: Icons.badge_outlined,
      label: 'Xin xác nhận học sinh',
      typeKey: 'STUDENT_CONFIRMATION',
      color: _blue,
    ),
    _ApplicationType(
      icon: Icons.pause_circle_outline_rounded,
      label: 'Xin bảo lưu kết quả',
      typeKey: 'RESERVE_RESULT',
      color: Color(0xFF9C27B0),
    ),
    _ApplicationType(
      icon: Icons.credit_card_rounded,
      label: 'Xin cấp lại thẻ HS/SV',
      typeKey: 'REISSUE_CARD',
      color: Color(0xFF00BCD4),
    ),
    _ApplicationType(
      icon: Icons.swap_horiz_rounded,
      label: 'Xin chuyển lớp',
      typeKey: 'CHANGE_CLASS',
      color: Color(0xFF4CAF50),
    ),
    _ApplicationType(
      icon: Icons.more_horiz_rounded,
      label: 'Đơn khác',
      typeKey: 'OTHER',
      color: _textGrey,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(context),
            _buildTabSelector(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case 0:
        return _buildCreateTab();
      case 1:
        return _buildMyApplicationsTab();
      default:
        return _buildCreateTab();
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
              'Đơn từ',
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

  // ── Bộ chọn tab dạng segmented pill (2 tabs) ────────────
  Widget _buildTabSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F0EF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(child: _buildTabCell('Tạo đơn', 0)),
            Expanded(child: _buildTabCell('Đơn của tôi', 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabCell(String label, int index) {
    final bool isSelected = _selectedTab == index;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedTab = index);
        if (index == 1) _fetchMyApplications();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? _orange : _textGrey,
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // ── TAB 1: Tạo đơn ──────────────────────────
  // ══════════════════════════════════════════════
  Widget _buildCreateTab() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
      itemCount: _applicationTypes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) =>
          _buildAppTypeCard(_applicationTypes[index]),
    );
  }

  Widget _buildAppTypeCard(_ApplicationType appType) {
    return Material(
      color: _bgCard,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openApplicationForm(appType),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: appType.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(appType.icon, color: appType.color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  appType.label,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: _textGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // ── TAB 2: Đơn của tôi ──────────────────────
  // ══════════════════════════════════════════════
  Widget _buildMyApplicationsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _orange));
    }

    if (_myApplications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded, size: 48, color: _textGrey),
            SizedBox(height: 12),
            Text(
              'Chưa có đơn nào',
              style: TextStyle(fontSize: 14, color: _textGrey),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
      itemCount: _myApplications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _buildMyAppCard(_myApplications[index]),
    );
  }

  Widget _buildMyAppCard(ApplicationItem app) {
    Color statusColor;
    IconData statusIcon;

    switch (app.status) {
      case 'APPROVED':
        statusColor = _green;
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'REJECTED':
        statusColor = _red;
        statusIcon = Icons.cancel_rounded;
        break;
      default: // PENDING
        statusColor = _yellow;
        statusIcon = Icons.hourglass_empty_rounded;
        break;
    }

    String displayDate = app.createdAt != null
        ? _formatDate(app.createdAt!)
        : 'Không rõ thời gian';

    return Material(
      color: _bgCard,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          // TODO: Mở popup xem chi tiết đơn
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // ── Icon trạng thái ──
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(statusIcon, color: statusColor, size: 22),
              ),
              const SizedBox(width: 14),

              // ── Thông tin đơn ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.typeLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _textDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 11,
                          color: _textGrey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          displayDate,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: _textGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // ── Badge trạng thái ──
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  app.statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
    } catch (e) {
      return isoString;
    }
  }

  // ══════════════════════════════════════════════
  // ── Form tạo đơn (Bottom Sheet) ──────────────
  // ══════════════════════════════════════════════
  void _openApplicationForm(_ApplicationType appType) {
    final fromDateCtrl = TextEditingController();
    final toDateCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                children: [
                  // ── Handle bar ──
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // ── Tiêu đề ──
                  Text(
                    appType.label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Loại đơn ──
                  _buildFormLabel('Loại đơn'),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _bgCard,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.description_outlined,
                          size: 18,
                          color: _orange,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          appType.label,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: _textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Từ ngày – Đến ngày ──
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFormLabel('Từ ngày'),
                            const SizedBox(height: 6),
                            _buildDateField(
                              ctx,
                              fromDateCtrl,
                              'yyyy-mm-dd',
                              fromDateCtrl,
                              toDateCtrl,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFormLabel('Đến ngày'),
                            const SizedBox(height: 6),
                            _buildDateField(
                              ctx,
                              toDateCtrl,
                              'yyyy-mm-dd',
                              fromDateCtrl,
                              toDateCtrl,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Lý do ──
                  _buildFormLabel('Lý do'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: reasonCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Nhập lý do...',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: _textGrey,
                      ),
                      filled: true,
                      fillColor: _bgCard,
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: _orange,
                          width: 1.5,
                        ),
                      ),
                    ),
                    style: const TextStyle(fontSize: 13.5, color: _textDark),
                  ),
                  const SizedBox(height: 16),

                  // // ── Đính kèm minh chứng ──
                  // _buildFormLabel('Đính kèm minh chứng'),
                  // const SizedBox(height: 6),
                  // Material(
                  //   color: _bgCard,
                  //   borderRadius: BorderRadius.circular(10),
                  //   child: InkWell(
                  //     borderRadius: BorderRadius.circular(10),
                  //     onTap: () {
                  //       // TODO: Mở chọn ảnh
                  //     },
                  //     child: Container(
                  //       padding: const EdgeInsets.symmetric(
                  //           vertical: 20, horizontal: 14),
                  //       child: Row(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         children: [
                  //           Icon(Icons.add_photo_alternate_outlined,
                  //               size: 22, color: _orange.withOpacity(0.7)),
                  //           const SizedBox(width: 8),
                  //           Text(
                  //             'Chọn ảnh / tệp',
                  //             style: TextStyle(
                  //               fontSize: 13,
                  //               fontWeight: FontWeight.w500,
                  //               color: _orange.withOpacity(0.8),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 28),

                  // ── Nút Gửi đơn ──
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (fromDateCtrl.text.isEmpty) {
                          _showErrorDialog(context, 'Thiếu thông tin', const [
                            'Vui lòng nhập ngày bắt đầu',
                          ]);
                          return;
                        }
                        final fromDate = DateTime.parse(fromDateCtrl.text);
                        final today = DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day,
                        );
                        if (fromDate.isBefore(today)) {
                          _showErrorDialog(context, 'Ngày không hợp lệ', const [
                            'Ngày bắt đầu không được nhỏ hơn ngày hiện tại',
                          ]);
                          return;
                        }
                        if (toDateCtrl.text.isEmpty) {
                          _showErrorDialog(context, 'Thiếu thông tin', const [
                            'Vui lòng nhập ngày kết thúc',
                          ]);
                          return;
                        }

                        if (reasonCtrl.text.isEmpty) {
                          _showErrorDialog(context, 'Thiếu thông tin', const [
                            'Vui lòng nhập lý do',
                          ]);
                          return;
                        }

                        final request = ApplicationRequest(
                          type: appType.typeKey,
                          fromDate: fromDateCtrl.text.isNotEmpty
                              ? fromDateCtrl.text
                              : null,
                          toDate: toDateCtrl.text.isNotEmpty
                              ? toDateCtrl.text
                              : null,
                          reason: reasonCtrl.text,
                        );

                        // Call API
                        final res = await _applicationController
                            .createApplication(request);

                        if (res.status) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đơn đã được gửi thành công!'),
                              backgroundColor: _green,
                              duration: Duration(seconds: 2),
                            ),
                          );
                          _fetchMyApplications();
                          setState(() => _selectedTab = 1);
                        } else {
                          switch (res.code) {
                            case "E006":
                              _showErrorDialog(
                                context,
                                'Gửi đơn không thành công',
                                [res.message],
                              );
                              break;

                            case "E001":
                              _showErrorDialog(
                                context,
                                'Gửi đơn không thành công',
                                [res.message],
                              );
                              break;

                            default:
                              _showErrorDialog(
                                context,
                                'Gửi đơn không thành công',
                                [res.message],
                              );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Gửi đơn',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFormLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: _textDark,
      ),
    );
  }

  // ── Popup hiển thị lỗi (thay cho SnackBar) ───
  void _showErrorDialog(
    BuildContext dialogContext,
    String title,
    List<String> messages,
  ) {
    showDialog(
      context: dialogContext,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: _red, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: messages
                .map(
                  (m) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '• $m',
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: _textDark,
                        height: 1.4,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Đóng',
                style: TextStyle(color: _orange, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateField(
    BuildContext ctx,
    TextEditingController controller,
    String hint,
    TextEditingController fromController,
    TextEditingController toController,
  ) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: () async {
        final picked = await showDatePicker(
          context: ctx,
          initialDate: DateTime.now(),
          firstDate: DateTime(2024),
          lastDate: DateTime(2030),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: _orange,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: _textDark,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked == null) return;

        // API expects format yyyy-MM-dd
        controller.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';

        // Chỉ kiểm tra hợp lệ khi cả 2 ngày đã được chọn
        if (fromController.text.isNotEmpty && toController.text.isNotEmpty) {
          final fromDate = DateTime.tryParse(fromController.text);
          final toDate = DateTime.tryParse(toController.text);

          if (fromDate != null && toDate != null && fromDate.isAfter(toDate)) {
            _showErrorDialog(ctx, 'Ngày không hợp lệ', const [
              'Ngày bắt đầu không được lớn hơn ngày kết thúc',
            ]);

            // Xóa giá trị vừa chọn vì không hợp lệ
            controller.clear();
          }
        }
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: _textGrey),
        filled: true,
        fillColor: _bgCard,
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
      style: const TextStyle(fontSize: 13.5, color: _textDark),
    );
  }

  // ── Bottom Nav (đồng bộ với các trang khác) ───
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

// ── Data models ──────────────────────────────
class _ApplicationType {
  final IconData icon;
  final String label;
  final String typeKey; // key for API
  final Color color;

  const _ApplicationType({
    required this.icon,
    required this.label,
    required this.typeKey,
    required this.color,
  });
}
