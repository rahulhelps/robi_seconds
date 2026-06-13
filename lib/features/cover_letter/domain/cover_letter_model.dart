/// Immutable data model for a cover letter.
class CoverLetterModel {
  final int templateIndex;
  final String title;
  final String header;
  final String body;
  final String footer;

  const CoverLetterModel({
    this.templateIndex = 0,
    this.title = 'My Cover Letter',
    this.header = '',
    this.body = '',
    this.footer = '',
  });

  CoverLetterModel copyWith({
    int? templateIndex,
    String? title,
    String? header,
    String? body,
    String? footer,
  }) {
    return CoverLetterModel(
      templateIndex: templateIndex ?? this.templateIndex,
      title: title ?? this.title,
      header: header ?? this.header,
      body: body ?? this.body,
      footer: footer ?? this.footer,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'header': header,
        'body': body,
        'footer': footer,
        'templateIndex': templateIndex,
      };
}

// ── Saved Cover Letter Response ──────────────────────────────────────────────

/// Represents the API response after successfully posting a cover letter.
class SavedCoverLetter {
  final String id;
  final String header;
  final String body;
  final String footer;
  final String createdAt;

  const SavedCoverLetter({
    required this.id,
    required this.header,
    required this.body,
    required this.footer,
    required this.createdAt,
  });

  factory SavedCoverLetter.fromJson(Map<String, dynamic> json) {
    return SavedCoverLetter(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      header: json['header'] as String? ?? '',
      body: json['body'] as String? ?? '',
      footer: json['footer'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}

// ── Remote Cover Letter Template ─────────────────────────────────────────────

class CoverLetterTemplate {
  final String id;
  final String title;
  final String header;
  final String body;
  final String footer;

  const CoverLetterTemplate({
    required this.id,
    required this.title,
    this.header = '',
    this.body = '',
    this.footer = '',
  });

  factory CoverLetterTemplate.fromJson(Map<String, dynamic> json) {
    return CoverLetterTemplate(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled',
      header: json['header'] as String? ?? '',
      body: json['body'] as String? ?? '',
      footer: json['footer'] as String? ?? '',
    );
  }
}
