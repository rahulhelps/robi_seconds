/// Represents a single CV entry returned by [GET /api/v1/cvs].
class CvListItem {
  final String id;
  final String templateId;
  final String templateName;
  final String title;
  final String createdAt;

  const CvListItem({
    required this.id,
    required this.templateId,
    this.templateName = '',
    required this.title,
    required this.createdAt,
  });

  factory CvListItem.fromJson(Map<String, dynamic> json) {
    return CvListItem(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      templateId: json['template_id'] as String? ?? json['templateId'] as String? ?? '',
      templateName: json['template_name'] as String? ?? '',
      title: json['title'] as String? ?? json['name'] as String? ?? 'CV',
      createdAt: json['created_at'] as String? ?? json['createdAt'] as String? ?? '',
    );
  }
}
