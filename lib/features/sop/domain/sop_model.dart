/// Immutable data model for a Statement of Purpose (SOP).
class SopModel {
  // Required fields:
  final String name;
  final String programName;
  final String universityName;
  final String country;

  // Optional fields:
  final String? academicBackground;
  final String? gpa;
  final String? workExperience;
  final String? researchExperience;
  final String? skills;
  final String? goals;
  final String? achievements;
  final String? whyThisUniversity;
  final String? templateId;
  final DateTime? createdAt;

  const SopModel({
    required this.name,
    required this.programName,
    required this.universityName,
    required this.country,
    this.academicBackground,
    this.gpa,
    this.workExperience,
    this.researchExperience,
    this.skills,
    this.goals,
    this.achievements,
    this.whyThisUniversity,
    this.templateId,
    this.createdAt,
  });

  SopModel copyWith({
    String? name,
    String? programName,
    String? universityName,
    String? country,
    String? academicBackground,
    String? gpa,
    String? workExperience,
    String? researchExperience,
    String? skills,
    String? goals,
    String? achievements,
    String? whyThisUniversity,
    String? templateId,
    DateTime? createdAt,
  }) {
    return SopModel(
      name: name ?? this.name,
      programName: programName ?? this.programName,
      universityName: universityName ?? this.universityName,
      country: country ?? this.country,
      academicBackground: academicBackground ?? this.academicBackground,
      gpa: gpa ?? this.gpa,
      workExperience: workExperience ?? this.workExperience,
      researchExperience: researchExperience ?? this.researchExperience,
      skills: skills ?? this.skills,
      goals: goals ?? this.goals,
      achievements: achievements ?? this.achievements,
      whyThisUniversity: whyThisUniversity ?? this.whyThisUniversity,
      templateId: templateId ?? this.templateId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'programName': programName,
        'universityName': universityName,
        'country': country,
        if (academicBackground != null) 'academicBackground': academicBackground,
        if (gpa != null) 'gpa': gpa,
        if (workExperience != null) 'workExperience': workExperience,
        if (researchExperience != null) 'researchExperience': researchExperience,
        if (skills != null) 'skills': skills,
        if (goals != null) 'goals': goals,
        if (achievements != null) 'achievements': achievements,
        if (whyThisUniversity != null) 'whyThisUniversity': whyThisUniversity,
        if (templateId != null) 'templateId': templateId,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };

  factory SopModel.fromJson(Map<String, dynamic> json) {
    return SopModel(
      name: json['name'] as String? ?? '',
      programName: json['programName'] as String? ?? '',
      universityName: json['universityName'] as String? ?? '',
      country: json['country'] as String? ?? '',
      academicBackground: json['academicBackground'] as String?,
      gpa: json['gpa'] as String?,
      workExperience: json['workExperience'] as String?,
      researchExperience: json['researchExperience'] as String?,
      skills: json['skills'] as String?,
      goals: json['goals'] as String?,
      achievements: json['achievements'] as String?,
      whyThisUniversity: json['whyThisUniversity'] as String?,
      templateId: json['templateId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}

// ── Saved SOP Response ───────────────────────────────────────────────────────

/// Represents the API response after successfully posting an SOP.
class SavedSop {
  final String id;
  final String header;
  final String body;
  final String footer;
  final String createdAt;
  final String? templateId;

  const SavedSop({
    required this.id,
    required this.header,
    required this.body,
    required this.footer,
    required this.createdAt,
    this.templateId,
  });

  factory SavedSop.fromJson(Map<String, dynamic> json) {
    return SavedSop(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      header: json['header'] as String? ?? '',
      body: json['body'] as String? ?? '',
      footer: json['footer'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      templateId: json['templateId'] as String?,
    );
  }
}

// ── Remote SOP Template ──────────────────────────────────────────────────────

class SopTemplate {
  final String id;
  final String title;
  final String header;
  final String body;
  final String footer;

  const SopTemplate({
    required this.id,
    required this.title,
    this.header = '',
    this.body = '',
    this.footer = '',
  });

  factory SopTemplate.fromJson(Map<String, dynamic> json) {
    return SopTemplate(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled',
      header: json['header'] as String? ?? '',
      body: json['body'] as String? ?? '',
      footer: json['footer'] as String? ?? '',
    );
  }
}
