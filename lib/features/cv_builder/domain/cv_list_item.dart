/// Represents a single CV entry returned by [GET /api/v1/cvs].
class CvListItem {
  final String id;
  final String templateId;
  final String title;
  final String createdAt;

  const CvListItem({
    required this.id,
    required this.templateId,
    required this.title,
    required this.createdAt,
  });

  factory CvListItem.fromJson(Map<String, dynamic> json) {
    return CvListItem(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      templateId: json['templateId'] as String? ?? '',
      // Use a human-readable title if the server sends one; fallback to templateId
      title: json['title'] as String? ??
          json['name'] as String? ??
          'CV – ${json['templateId'] ?? ''}',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}
