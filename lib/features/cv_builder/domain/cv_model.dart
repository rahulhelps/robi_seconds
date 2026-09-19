import 'package:flutter/foundation.dart';
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

  /// Realistic sample CV data for live template previews.
  static CvModel sample({String templateId = '', String? jobTitle}) {
    return CvModel(
      templateId: templateId,
      careerObjective:
          'Dedicated and results-oriented professional with a strong track record of success. Seeking to leverage proven technical and analytical skills to contribute to organizational growth and excellence.',
      personalInfo: const PersonalInfo(
        name: 'Mohammad Tanvir Ahmed',
        email: 'tanvir.ahmed@example.com',
        phone: '+880 1712-345678',
        address: 'House #12, Road #5, Dhanmondi, Dhaka-1209',
      ),
      personalProfile: const PersonalProfile(
        fatherName: 'Late Rafiqul Islam',
        dateOfBirth: '15 Jan 1996',
        nationality: 'Bangladeshi',
        maritalStatus: 'Single',
        gender: 'Male',
        strength: 'Quick learner, leadership, analytical problem solver',
        hobbies: 'Reading tech blogs, traveling, open source projects',
      ),
      education: const [
        Education(
          degree: 'B.Sc in Computer Science & Engineering',
          institution: 'University of Dhaka',
          board: 'Dhaka',
          fieldOfStudy: 'Computer Science',
          passingYear: '2019',
          result: 'CGPA 3.82',
        ),
        Education(
          degree: 'Higher Secondary Certificate (HSC)',
          institution: 'Dhaka College',
          board: 'Dhaka',
          fieldOfStudy: 'Science',
          passingYear: '2014',
          result: 'GPA 5.00',
        ),
      ],
      skills: const [
        SkillCategory(
          category: 'Core Competencies',
          skills: [
            'Flutter & Dart',
            'REST APIs',
            'State Management (BLoC)',
            'Git & GitHub',
            'Clean Architecture'
          ],
        ),
        SkillCategory(
          category: 'Tools & Technologies',
          skills: ['Figma', 'Postman', 'Firebase', 'Docker', 'Agile/Scrum'],
        ),
      ],
      workExperience: const [
        WorkExperience(
          company: 'TechNova Solutions Ltd.',
          position: 'Senior Software Engineer',
          startDate: '2021',
          endDate: 'Present',
          description:
              'Leading mobile application architecture and delivering high-performance cross-platform solutions.',
          bullets: [
            'Architected and published 3 production apps with over 100k downloads',
            'Reduced app crash rate to less than 0.1% by implementing robust state handling',
            'Mentored junior engineers and led bi-weekly code reviews',
          ],
        ),
        WorkExperience(
          company: 'InnoApp Labs',
          position: 'Software Developer',
          startDate: '2019',
          endDate: '2021',
          description:
              'Developed responsive UI screens and integrated REST APIs.',
          bullets: [
            'Implemented state management and local offline caching',
            'Collaborated closely with UX designers to ensure pixel-perfect screens',
          ],
        ),
      ],
      languages: const [
        Language(
            language: 'English',
            proficiency: 'Professional Working Proficiency'),
        Language(language: 'Bengali', proficiency: 'Native / Bilingual'),
      ],
    );
  }

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
      'template_id': templateId,
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
    debugPrint('[CvModel] toJson() body: $body');
    return body;
  }

  factory CvModel.fromJson(Map<String, dynamic> json) {
    return CvModel(
      templateId: json['templateId'] as String? ?? '',
      careerObjective: json['personalInfo']?['summary'] as String? ?? '',
      personalInfo: json['personalInfo'] != null 
          ? PersonalInfo.fromJson(json['personalInfo'] as Map<String, dynamic>)
          : const PersonalInfo(),
      personalProfile: json['personalProfile'] != null
          ? PersonalProfile.fromJson(json['personalProfile'] as Map<String, dynamic>)
          : const PersonalProfile(maritalStatus: 'Single', gender: 'Male'),
      education: (json['education'] as List<dynamic>?)
              ?.map((e) => Education.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => SkillCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      workExperience: (json['workExperience'] as List<dynamic>?)
              ?.map((e) => WorkExperience.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => Language.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
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

  factory PersonalInfo.fromJson(Map<String, dynamic> json) {
    return PersonalInfo(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
    );
  }
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

  factory PersonalProfile.fromJson(Map<String, dynamic> json) {
    return PersonalProfile(
      fatherName: json['fatherName'] as String? ?? '',
      dateOfBirth: json['dateOfBirth'] as String? ?? '',
      nationality: json['nationality'] as String? ?? '',
      maritalStatus: json['maritalStatus'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      strength: json['strength'] as String? ?? '',
      hobbies: json['hobbies'] as String? ?? '',
    );
  }
}

// ── Education ───────────────────────────────────────────────────────────────

class Education {
  final String institution;
  final String degree;
  final String fieldOfStudy;
  final String startDate;
  final String endDate;
  final String board;
  final String passingYear;
  final String result;

  const Education({
    this.institution = '',
    this.degree = '',
    this.fieldOfStudy = '',
    this.startDate = '',
    this.endDate = '',
    this.board = '',
    this.passingYear = '',
    this.result = '',
  });

  Education copyWith({
    String? institution,
    String? degree,
    String? fieldOfStudy,
    String? startDate,
    String? endDate,
    String? board,
    String? passingYear,
    String? result,
  }) {
    return Education(
      institution: institution ?? this.institution,
      degree: degree ?? this.degree,
      fieldOfStudy: fieldOfStudy ?? this.fieldOfStudy,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      board: board ?? this.board,
      passingYear: passingYear ?? this.passingYear,
      result: result ?? this.result,
    );
  }

  Map<String, dynamic> toJson() => {
        'institution': institution,
        'degree': degree,
        'fieldOfStudy': fieldOfStudy,
        'startDate': startDate,
        'endDate': endDate.isNotEmpty ? endDate : passingYear,
        'board': board,
        'passingYear': passingYear.isNotEmpty ? passingYear : endDate,
        'result': result,
      };

  factory Education.fromJson(Map<String, dynamic> json) {
    final end = json['endDate'] as String? ?? json['passingYear'] as String? ?? '';
    return Education(
      institution: json['institution'] as String? ?? '',
      degree: json['degree'] as String? ?? '',
      fieldOfStudy: json['fieldOfStudy'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: end,
      board: json['board'] as String? ?? '',
      passingYear: json['passingYear'] as String? ?? end,
      result: json['result'] as String? ?? json['grade'] as String? ?? '',
    );
  }
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

  factory SkillCategory.fromJson(Map<String, dynamic> json) {
    return SkillCategory(
      category: json['category'] as String? ?? '',
      skills: (json['skills'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    );
  }
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

  factory WorkExperience.fromJson(Map<String, dynamic> json) {
    return WorkExperience(
      company: json['company'] as String? ?? '',
      position: json['position'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      description: json['description'] as String? ?? '',
      bullets: (json['bullets'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    );
  }
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

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      language: json['language'] as String? ?? '',
      proficiency: json['proficiency'] as String? ?? '',
    );
  }
}
