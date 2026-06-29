/// Request gửi lên để tạo đơn mới
/// POST /api/applications
class ApplicationRequest {
  final String type;         // ApplicationType enum value
  final String? fromDate;    // yyyy-MM-dd
  final String? toDate;      // yyyy-MM-dd
  final String reason;
  final String? attachmentUrl;

  ApplicationRequest({
    required this.type,
    this.fromDate,
    this.toDate,
    required this.reason,
    this.attachmentUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (fromDate != null) 'fromDate': fromDate,
      if (toDate != null) 'toDate': toDate,
      'reason': reason,
      if (attachmentUrl != null) 'attachmentUrl': attachmentUrl,
    };
  }
}
