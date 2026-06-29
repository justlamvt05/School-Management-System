import 'package:flutter/material.dart';
import '../../controller/notification_controller.dart';
import '../../model/notification_item.dart';
import '../user_profile.dart';

class NotificationPage extends StatefulWidget {
  final String token;

  const NotificationPage({super.key, required this.token});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  // ── Brand colors ──
  static const Color _orange = Color(0xFFF37021);
  static const Color _bgCard = Color(0xFFF7F6F6);
  static const Color _textDark = Color(0xFF333333);
  static const Color _textGrey = Color(0xFF9A9A9A);

  List<NotificationItem> _notifications = [];
  bool _isLoading = true;

  late NotificationController _notificationController;

  @override
  void initState() {
    super.initState();
    _notificationController = NotificationController(token: widget.token);
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    try {
      final response = await _notificationController.getMyNotifications();
      if (response.status && response.data != null) {
        setState(() {
          _notifications = response.data!;
        });
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(NotificationItem notification) async {
    if (notification.isRead) return;

    try {
      final response = await _notificationController.markAsRead(notification.id);
      if (response.status) {
        setState(() {
          final index = _notifications.indexWhere((n) => n.id == notification.id);
          if (index != -1) {
            _notifications[index] = response.data!;
          }
        });
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final response = await _notificationController.markAllAsRead();
      if (response.status) {
        _fetchNotifications(); // Refresh list to get updated states
      }
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
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
            Expanded(child: _buildContent()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _orange),
      );
    }

    if (_notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_off_outlined, size: 48, color: _textGrey),
            SizedBox(height: 12),
            Text(
              'Không có thông báo',
              style: TextStyle(fontSize: 14, color: _textGrey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: _orange,
      onRefresh: _fetchNotifications,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) =>
            _buildNotificationCard(_notifications[index]),
      ),
    );
  }

  // ── Top bar ──────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Container(
      color: _orange,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Center(
            child: Text(
              'Thông báo',
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
                'Quay lại',
                style: TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ),
          if (unreadCount > 0)
            Positioned(
              right: 12,
              child: GestureDetector(
                onTap: _markAllAsRead,
                child: const Text(
                  'Đánh dấu tất cả',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
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
            isActive: true, // đang ở trang Thông báo
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

  Widget _buildNotificationCard(NotificationItem notification) {
    return Material(
      color: notification.isRead ? _bgCard : _orange.withOpacity(0.06),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _markAsRead(notification),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Icon ──
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: notification.isRead
                      ? _textGrey.withOpacity(0.12)
                      : _orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.notifications_active_rounded,
                  color: notification.isRead ? _textGrey : _orange,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),

              // ── Nội dung ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight:
                        notification.isRead ? FontWeight.w500 : FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notification.content,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight:
                        notification.isRead ? FontWeight.w400 : FontWeight.w500,
                        color: _textDark,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 5),
                    if (notification.createdAt != null)
                      Text(
                        _formatDate(notification.createdAt!),
                        style: const TextStyle(fontSize: 11, color: _textGrey),
                      ),
                  ],
                ),
              ),

              // ── Dấu chấm chưa đọc ──
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4, left: 6),
                  decoration: const BoxDecoration(
                    color: _orange,
                    shape: BoxShape.circle,
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
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} - ${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
    } catch (e) {
      return isoString;
    }
  }
}