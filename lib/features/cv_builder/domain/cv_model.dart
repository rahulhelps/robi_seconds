/// Immutable data model for the full CV generation payload.
/// Each field maps directly to the POST /api/v1/cvs/generate body.
class CvModel {
  final String templateId;
  final String careerObjective; // displayed in review; sent as personalInfo.summary
  final PersonalInfo personalInfo; // Required by API
  final PersonalProfile personalProfile;
  final List<Education> education;
  final List<SkillCategory> skills;
  final List<WorkExperience> workExperience;
  final List<Language> languages;

  const CvModel({
    this.templateId = '',
    this.careerObjective = '',
    this.personalInfo = const PersonalInfo(),
    this.personalProfile = const PersonalProfile(
      maritalStatus: 'Single',
      gender: 'Male',
    ),
    this.education = const [],
    this.skills = const [],
    this.workExperience = const [],
    this.languages = const [],
  });

  CvModel copyWith({
    String? templateId,
    String? careerObjective,
    PersonalInfo? personalInfo,
    PersonalProfile? personalProfile,
    List<Education>? education,
    List<SkillCategory>? skills,
    List<WorkExperience>? workExperience,
    List<Language>? languages,
  }) {
    return CvModel(
      templateId: templateId ?? this.templateId,
      careerObjective: careerObjective ?? this.careerObjective,
      personalInfo: personalInfo ?? this.personalInfo,
      personalProfile: personalProfile ?? this.personalProfile,
      education: education ?? this.education,
      skills: skills ?? this.skills,
      workExperience: workExperience ?? this.workExperience,
      languages: languages ?? this.languages,
    );
  }

  /// Builds the exact JSON body expected by POST /api/v1/cvs/generate.
  Map<String, dynamic> toJson() {
    final body = {
      'templateId': templateId,
      // personalInfo is Required by the API
      'personalInfo': {
        ...personalInfo.toJson(),
        'summary': careerObjective, // career objective goes here
      },
      'personalProfile': personalProfile.toJson(),
      'education': education.map((e) => e.toJson()).toList(),
      'skills': skills.map((s) => s.toJson()).toList(),
      'workExperience': workExperience.map((w) => w.toJson()).toList(),
      'languages': languages.map((l) => l.toJson()).toList(),
    };
    print('[CvModel] toJson() body: $body');
    return body;
  }
}

// ── Personal Info (Required by API) ─────────────────────────────────────────

class PersonalInfo {
  final String name;
  final String email;
  final String phone;
  final String address;

  const PersonalInfo({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.address = '',
  });

  PersonalInfo copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
  }) {
    return PersonalInfo(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
      };
}

// ── Personal Profile ────────────────────────────────────────────────────────

class PersonalProfile {
  final String fatherName;
  final String dateOfBirth;
  final String nationality;
  final String maritalStatus;
  final String gender;
  final String strength;
  final String hobbies;

  const PersonalProfile({
    this.fatherName = '',
    this.dateOfBirth = '',
    this.nationality = '',
    this.maritalStatus = '',
    this.gender = '',
    this.strength = '',
    this.hobbies = '',
  });

  PersonalProfile copyWith({
    String? fatherName,
    String? dateOfBirth,
    String? nationality,
    String? maritalStatus,
    String? gender,
    String? strength,
    String? hobbies,
  }) {
    return PersonalProfile(
      fatherName: fatherName ?? this.fatherName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      nationality: nationality ?? this.nationality,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      gender: gender ?? this.gender,
      strength: strength ?? this.strength,
      hobbies: hobbies ?? this.hobbies,
    );
  }

  Map<String, dynamic> toJson() => {
        'fatherName': fatherName,
        'dateOfBirth': dateOfBirth,
        'nationality': nationality,
        'maritalStatus': maritalStatus,
        'gender': gender,
        'strength': strength,
        'hobbies': hobbies,
      };
}

// ── Education ───────────────────────────────────────────────────────────────

class Education {
  final String institution;
  final String degree;
  final String fieldOfStudy;
  final String startDate;
  final String endDate;

  const Education({
    this.institution = '',
    this.degree = '',
    this.fieldOfStudy = '',
    this.startDate = '',
    this.endDate = '',
  });

  Education copyWith({
    String? institution,
    String? degree,
    String? fieldOfStudy,
    String? startDate,
    String? endDate,
  }) {
    return Education(
      institution: institution ?? this.institution,
      degree: degree ?? this.degree,
      fieldOfStudy: fieldOfStudy ?? this.fieldOfStudy,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'institution': institution,
        'degree': degree,
        'fieldOfStudy': fieldOfStudy,
        'startDate': startDate,
        'endDate': endDate,
      };
}

// ── Skills ──────────────────────────────────────────────────────────────────

class SkillCategory {
  final String category;
  final List<String> skills;

  const SkillCategory({this.category = '', this.skills = const []});

  SkillCategory copyWith({String? category, List<String>? skills}) {
    return SkillCategory(
      category: category ?? this.category,
      skills: skills ?? this.skills,
    );
  }

  Map<String, dynamic> toJson() => {
        'category': category,
        'skills': skills,
      };
}

// ── Work Experience ─────────────────────────────────────────────────────────

class WorkExperience {
  final String company;
  final String position;
  final String startDate;
  final String endDate;
  final String description;
  final List<String> bullets;

  const WorkExperience({
    this.company = '',
    this.position = '',
    this.startDate = '',
    this.endDate = '',
    this.description = '',
    this.bullets = const [],
  });

  WorkExperience copyWith({
    String? company,
    String? position,
    String? startDate,
    String? endDate,
    String? description,
    List<String>? bullets,
  }) {
    return WorkExperience(
      company: company ?? this.company,
      position: position ?? this.position,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      bullets: bullets ?? this.bullets,
    );
  }

  Map<String, dynamic> toJson() => {
        'company': company,
        'position': position,
        'startDate': startDate,
        'endDate': endDate,
        'description': description,
        'bullets': bullets,
      };
}

// ── Language ────────────────────────────────────────────────────────────────

class Language {
  final String language;
  final String proficiency;

  const Language({this.language = '', this.proficiency = ''});

  Language copyWith({String? language, String? proficiency}) {
    return Language(
      language: language ?? this.language,
      proficiency: proficiency ?? this.proficiency,
    );
  }

  Map<String, dynamic> toJson() => {
        'language': language,
        'proficiency': proficiency,
      };
}
