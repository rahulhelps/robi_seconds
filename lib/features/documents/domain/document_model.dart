enum DocumentType { cv, coverLetter, sop, email }

extension DocumentTypeExtension on DocumentType {
  String get apiValue {
    return switch (this) {
      DocumentType.cv => 'cv',
      DocumentType.coverLetter => 'cover_letter',
      DocumentType.sop => 'sop',
      DocumentType.email => 'email',
    };
  }

  String get label {
    return switch (this) {
      DocumentType.cv => 'CV',
      DocumentType.coverLetter => 'Cover Letter',
      DocumentType.sop => 'SOP',
      DocumentType.email => 'Email',
    };
  }
}

enum DocumentStatus { draft, rendering, ready, failed }

extension DocumentStatusExtension on DocumentStatus {
  String get apiValue {
    return switch (this) {
      DocumentStatus.draft => 'draft',
      DocumentStatus.rendering => 'rendering',
      DocumentStatus.ready => 'ready',
      DocumentStatus.failed => 'failed',
    };
  }
}

class DocumentModel {
  final String id;
  final DocumentType type;
  final String? templateId;
  final Map<String, dynamic>? payload;
  final String? generatedFileUrl;
  final DocumentStatus status;
  final String? errorMessage;
  final int renderAttempts;
  final DateTime? renderedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DocumentModel({
    required this.id,
    required this.type,
    this.templateId,
    this.payload,
    this.generatedFileUrl,
    required this.status,
    this.errorMessage,
    this.renderAttempts = 0,
    this.renderedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    final rawType = (json['type'] as String?)?.toLowerCase() ?? 'cv';

    DocumentType parseType(String raw) {
      return DocumentType.values.firstWhere(
        (e) => e.apiValue == raw,
        orElse: () => DocumentType.cv,
      );
    }

    DocumentStatus parseStatus(String raw) {
      return DocumentStatus.values.firstWhere(
        (e) => e.apiValue == raw,
        orElse: () => DocumentStatus.draft,
      );
    }

    return DocumentModel(
      id: json['id'] as String? ?? '',
      type: parseType(rawType),
      templateId: json['template_id'] as String?,
      payload: (json['payload'] as Map<String, dynamic>?) ?? const {},
      generatedFileUrl: json['generated_file_url'] as String?,
      status: parseStatus((json['status'] as String?) ?? 'draft'),
      errorMessage: json['error_message'] as String?,
      renderAttempts: (json['render_attempts'] as int?) ?? 0,
      renderedAt: json['rendered_at'] != null
          ? DateTime.tryParse(json['rendered_at'] as String)
          : null,
      createdAt: (json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null) ?? DateTime.now(),
      updatedAt: (json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.apiValue,
      'template_id': templateId,
      'payload': payload,
    };
  }
}

class CreateDocumentRequest {
  final DocumentType type;
  final String? templateId;
  final Map<String, dynamic> payload;

  const CreateDocumentRequest({
    required this.type,
    this.templateId,
    required this.payload,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.apiValue,
      'template_id': templateId,
      'payload': payload,
    };
  }
}
