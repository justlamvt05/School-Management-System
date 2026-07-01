import 'package:flutter/material.dart';
import '../../controller/event_controller.dart';
import '../../model/event_item.dart';
import '../user_profile.dart';
import 'notification.dart';

class EventPage extends StatefulWidget {
  final String token;

  const EventPage({super.key, required this.token});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  // ── Brand colors (đồng bộ với các trang khác) ──
  static const Color _orange = Color(0xFFF37021);
  static const Color _bgCard = Color(0xFFF7F6F6);
  static const Color _textDark = Color(0xFF333333);
  static const Color _textGrey = Color(0xFF9A9A9A);
  static const Color _green = Color(0xFF3FAE5C);
  static const Color _blue = Color(0xFF2196F3);

  // 0: Sắp diễn ra | 1: Đã diễn ra
  int _selectedTab = 0;

  List<EventItem> _allEvents = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final controller = EventController(token: widget.token);
      final response = await controller.getEvents();

      if (response.status && response.data != null) {
        setState(() {
          _allEvents = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message.isNotEmpty
              ? response.message
              : 'Không thể tải sự kiện';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching events: $e');
      setState(() {
        _errorMessage = 'Lỗi kết nối server';
        _isLoading = false;
      });
    }
  }

  List<EventItem> get _filteredEvents {
    if (_selectedTab == 0) {
      // Sắp diễn ra
      return _allEvents.where((e) => e.isUpcoming).toList();
    } else {
      // Đã diễn ra
      return _allEvents.where((e) => e.isPast).toList();
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
            _buildTabSelector(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _orange),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48, color: _textGrey),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 14, color: _textGrey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _fetchEvents,
              icon: const Icon(Icons.refresh_rounded, color: _orange),
              label: const Text(
                'Thử lại',
                style: TextStyle(color: _orange, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    return _buildEventList(_filteredEvents);
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
              'Sự kiện',
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
            Expanded(child: _buildTabCell('Sắp diễn ra', 0)),
            Expanded(child: _buildTabCell('Đã diễn ra', 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabCell(String label, int index) {
    final bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
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

  // ── Danh sách sự kiện ───────────────────────
  Widget _buildEventList(List<EventItem> events) {
    if (events.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy_rounded, size: 48, color: _textGrey),
            SizedBox(height: 12),
            Text(
              'Không có sự kiện nào',
              style: TextStyle(fontSize: 14, color: _textGrey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: _orange,
      onRefresh: _fetchEvents,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
        itemCount: events.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _buildEventCard(events[index]),
      ),
    );
  }

  Widget _buildEventCard(EventItem event) {
    return Material(
      color: _bgCard,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showEventDetail(event),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // ── Icon / mã sự kiện ──
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _orange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  event.code.length > 3
                      ? event.code.substring(0, 3)
                      : event.code,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _orange,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // ── Thông tin sự kiện ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _textDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 11, color: _textGrey),
                        const SizedBox(width: 4),
                        Text(
                          event.formattedDate,
                          style:
                              const TextStyle(fontSize: 11, color: _textGrey),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.access_time_rounded,
                            size: 11, color: _textGrey),
                        const SizedBox(width: 3),
                        Text(
                          event.formattedTime,
                          style:
                              const TextStyle(fontSize: 11, color: _textGrey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 11, color: _textGrey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location ?? '',
                            style: const TextStyle(
                                fontSize: 11, color: _textGrey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // ── Badge trạng thái ──
              _buildStatusBadge(event),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(EventItem event) {
    if (event.isUpcoming) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _blue.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time_rounded, size: 14, color: _blue),
            SizedBox(width: 4),
            Text(
              'Sắp tới',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: _blue,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _green.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, size: 14, color: _green),
            SizedBox(width: 4),
            Text(
              'Đã diễn ra',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: _green,
              ),
            ),
          ],
        ),
      );
    }
  }

  // ── Dialog chi tiết sự kiện ──────────────────
  void _showEventDetail(EventItem event) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _orange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.event_note_rounded,
                    color: _orange, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 15,
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
            children: [
              if (event.description != null && event.description!.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _bgCard,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    event.description!,
                    style: const TextStyle(fontSize: 13, color: _textDark),
                  ),
                ),
              const SizedBox(height: 14),
              _buildDetailRow(
                  Icons.calendar_today_rounded, 'Ngày', event.formattedDate),
              const SizedBox(height: 8),
              _buildDetailRow(
                  Icons.access_time_rounded, 'Giờ', event.formattedTime),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.location_on_outlined, 'Địa điểm',
                  event.location ?? 'Chưa xác định'),
              if (event.createdByName != null) ...[
                const SizedBox(height: 8),
                _buildDetailRow(Icons.person_outline_rounded, 'Tạo bởi',
                    event.createdByName!),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Đóng',
                style:
                    TextStyle(color: _orange, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _textGrey),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            color: _textGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: _textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ── Bottom Nav ───────────────────────────────
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
