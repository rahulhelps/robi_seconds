/// Immutable data model for a Professional Email.
class EmailModel {
  // Required fields:
  final String emailType; // Job Application, Business Proposal, etc.
  final String senderName;
  final String recipientName;
  final String recipientDesignation;
  final String companyName;
  final String subject;

  // Optional fields:
  final String? senderDesignation;
  final String? senderCompany;
  final String? keyPoints;
  final String? specificRequest;
  final String? deadline;
  final String? templateId;
  final DateTime? createdAt;

  const EmailModel({
    required this.emailType,
    required this.senderName,
    required this.recipientName,
    required this.recipientDesignation,
    required this.companyName,
    required this.subject,
    this.senderDesignation,
    this.senderCompany,
    this.keyPoints,
    this.specificRequest,
    this.deadline,
    this.templateId,
    this.createdAt,
  });

  EmailModel copyWith({
    String? emailType,
    String? senderName,
    String? recipientName,
    String? recipientDesignation,
    String? companyName,
    String? subject,
    String? senderDesignation,
    String? senderCompany,
    String? keyPoints,
    String? specificRequest,
    String? deadline,
    String? templateId,
    DateTime? createdAt,
  }) {
    return EmailModel(
      emailType: emailType ?? this.emailType,
      senderName: senderName ?? this.senderName,
      recipientName: recipientName ?? this.recipientName,
      recipientDesignation: recipientDesignation ?? this.recipientDesignation,
      companyName: companyName ?? this.companyName,
      subject: subject ?? this.subject,
      senderDesignation: senderDesignation ?? this.senderDesignation,
      senderCompany: senderCompany ?? this.senderCompany,
      keyPoints: keyPoints ?? this.keyPoints,
      specificRequest: specificRequest ?? this.specificRequest,
      deadline: deadline ?? this.deadline,
      templateId: templateId ?? this.templateId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'emailType': emailType,
        'senderName': senderName,
        'recipientName': recipientName,
        'recipientDesignation': recipientDesignation,
        'companyName': companyName,
        'subject': subject,
        if (senderDesignation != null) 'senderDesignation': senderDesignation,
        if (senderCompany != null) 'senderCompany': senderCompany,
        if (keyPoints != null) 'keyPoints': keyPoints,
        if (specificRequest != null) 'specificRequest': specificRequest,
        if (deadline != null) 'deadline': deadline,
        if (templateId != null) 'templateId': templateId,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };

  factory EmailModel.fromJson(Map<String, dynamic> json) {
    return EmailModel(
      emailType: json['emailType'] as String? ?? '',
      senderName: json['senderName'] as String? ?? '',
      recipientName: json['recipientName'] as String? ?? '',
      recipientDesignation: json['recipientDesignation'] as String? ?? '',
      companyName: json['companyName'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      senderDesignation: json['senderDesignation'] as String?,
      senderCompany: json['senderCompany'] as String?,
      keyPoints: json['keyPoints'] as String?,
      specificRequest: json['specificRequest'] as String?,
      deadline: json['deadline'] as String?,
      templateId: json['templateId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}

// ── Saved Email Response ─────────────────────────────────────────────────────

/// Represents the API response after successfully posting an email.
class SavedEmail {
  final String id;
  final String subject;
  final String body;
  final String createdAt;
  final String? templateId;

  const SavedEmail({
    required this.id,
    required this.subject,
    required this.body,
    required this.createdAt,
    this.templateId,
  });

  factory SavedEmail.fromJson(Map<String, dynamic> json) {
    return SavedEmail(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      body: json['body'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      templateId: json['templateId'] as String?,
    );
  }
}

// ── Email Template (local) ───────────────────────────────────────────────────

/// Local email template definition.
class EmailTemplate {
  final String id;
  final String name;
  final String description;
  final bool isPremium;

  const EmailTemplate({
    required this.id,
    required this.name,
    required this.description,
    this.isPremium = false,
  });
}

// ── Email Type Constants ─────────────────────────────────────────────────────

/// 10 professional email types supported by the module.
class EmailTypes {
  static const List<String> all = [
    'Job Application Email',
    'Internship Request',
    'Business Proposal',
    'Follow-up Email',
    'Thank You Email',
    'Networking Email',
    'Resignation Letter',
    'Recommendation Request',
    'Cold Outreach',
    'Client Communication',
  ];
}
