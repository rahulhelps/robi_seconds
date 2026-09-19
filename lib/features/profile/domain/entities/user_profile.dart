/// Complete UserProfile entity holding all personal, professional, and career details.
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String jobTitle;
  final String professionalHeadline;
  final String careerObjective;
  final String avatarUrl;
  final String bio;
  final String address;
  final String permanentAddress;
  final String dateOfBirth;
  final String gender;
  final String maritalStatus;
  final String nationality;
  final String fatherName;
  final String motherName;
  final String currentCompany;
  final String currentDesignation;
  final String experienceYears;
  final String yearsInCurrentRole;
  final String noticePeriod;
  final String expectedSalary;
  final String educationLevel;
  final String institution;
  final List<String> skills;
  final List<String> languages;
  final String linkedinUrl;
  final String githubUrl;
  final String portfolioUrl;
  final int completionPercentage;
  final int cvCount;
  final int coverLetterCount;
  final int sopCount;
  final int emailCount;
  final bool isSubscriptionActive;
  final String createdAt;

  const UserProfile({
    this.id = '',
    this.name = '',
    this.email = '',
    this.phone = '',
    this.jobTitle = '',
    this.professionalHeadline = '',
    this.careerObjective = '',
    this.avatarUrl = '',
    this.bio = '',
    this.address = '',
    this.permanentAddress = '',
    this.dateOfBirth = '',
    this.gender = '',
    this.maritalStatus = '',
    this.nationality = '',
    this.fatherName = '',
    this.motherName = '',
    this.currentCompany = '',
    this.currentDesignation = '',
    this.experienceYears = '',
    this.yearsInCurrentRole = '',
    this.noticePeriod = '',
    this.expectedSalary = '',
    this.educationLevel = '',
    this.institution = '',
    this.skills = const [],
    this.languages = const [],
    this.linkedinUrl = '',
    this.githubUrl = '',
    this.portfolioUrl = '',
    this.completionPercentage = 0,
    this.cvCount = 0,
    this.coverLetterCount = 0,
    this.sopCount = 0,
    this.emailCount = 0,
    this.isSubscriptionActive = false,
    this.createdAt = '',
  });

  /// Backward compatibility with older components expecting `displayName`
  String get displayName => name.isNotEmpty ? name : (phone.isNotEmpty ? phone : 'User');
  String get phoneNumber => phone;
  String get profileImageUrl => avatarUrl;
  String get memberSince => createdAt;
  String get headline => jobTitle;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // Handle nested 'user' key if wrapped
    final map = (json['user'] is Map<String, dynamic>)
        ? json['user'] as Map<String, dynamic>
        : json;

    List<String> parseList(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
      }
      if (val is String && val.isNotEmpty) {
        return val.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
      return [];
    }

    return UserProfile(
      id: (map['id'] ?? map['_id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      phone: (map['phoneNumber'] ?? map['msisdn'] ?? map['phone'] ?? '').toString(),
      jobTitle: (map['job_title'] ?? map['jobTitle'] ?? '').toString(),
      professionalHeadline: (map['professional_headline'] ?? map['professionalHeadline'] ?? '').toString(),
      careerObjective: (map['career_objective'] ?? map['careerObjective'] ?? '').toString(),
      avatarUrl: (map['avatar_url'] ?? map['avatarUrl'] ?? map['profileImageUrl'] ?? '').toString(),
      bio: (map['bio'] ?? '').toString(),
      address: (map['address'] ?? '').toString(),
      permanentAddress: (map['permanent_address'] ?? map['permanentAddress'] ?? '').toString(),
      dateOfBirth: (map['date_of_birth'] ?? map['dateOfBirth'] ?? '').toString(),
      gender: (map['gender'] ?? '').toString(),
      maritalStatus: (map['marital_status'] ?? map['maritalStatus'] ?? '').toString(),
      nationality: (map['nationality'] ?? '').toString(),
      fatherName: (map['father_name'] ?? map['fatherName'] ?? '').toString(),
      motherName: (map['mother_name'] ?? map['motherName'] ?? '').toString(),
      currentCompany: (map['current_company'] ?? map['currentCompany'] ?? '').toString(),
      currentDesignation: (map['current_designation'] ?? map['currentDesignation'] ?? '').toString(),
      experienceYears: (map['experience_years'] ?? map['experienceYears'] ?? '').toString(),
      yearsInCurrentRole: (map['years_in_current_role'] ?? map['yearsInCurrentRole'] ?? '').toString(),
      noticePeriod: (map['notice_period'] ?? map['noticePeriod'] ?? '').toString(),
      expectedSalary: (map['expected_salary'] ?? map['expectedSalary'] ?? '').toString(),
      educationLevel: (map['education_level'] ?? map['educationLevel'] ?? '').toString(),
      institution: (map['institution'] ?? '').toString(),
      skills: parseList(map['skills']),
      languages: parseList(map['languages']),
      linkedinUrl: (map['linkedin_url'] ?? map['linkedinUrl'] ?? '').toString(),
      githubUrl: (map['github_url'] ?? map['githubUrl'] ?? '').toString(),
      portfolioUrl: (map['portfolio_url'] ?? map['portfolioUrl'] ?? '').toString(),
      completionPercentage: (json['completionPercentage'] as num?)?.toInt() ??
          (map['completionPercentage'] as num?)?.toInt() ?? 0,
      cvCount: (json['cvCount'] as num?)?.toInt() ??
          (map['cvCount'] as num?)?.toInt() ?? 0,
      coverLetterCount: (json['coverLetterCount'] as num?)?.toInt() ??
          (map['coverLetterCount'] as num?)?.toInt() ?? 0,
      sopCount: (json['sopCount'] as num?)?.toInt() ??
          (map['sopCount'] as num?)?.toInt() ?? 0,
      emailCount: (json['emailCount'] as num?)?.toInt() ??
          (map['emailCount'] as num?)?.toInt() ?? 0,
      isSubscriptionActive: json['isSubscriptionActive'] == true ||
          map['isSubscriptionActive'] == true ||
          map['subscription_active'] == true,
      createdAt: (map['createdAt'] ?? map['created_at'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phone,
      'job_title': jobTitle,
      'professional_headline': professionalHeadline,
      'career_objective': careerObjective,
      'avatar_url': avatarUrl,
      'bio': bio,
      'address': address,
      'permanent_address': permanentAddress,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'marital_status': maritalStatus,
      'nationality': nationality,
      'father_name': fatherName,
      'mother_name': motherName,
      'current_company': currentCompany,
      'current_designation': currentDesignation,
      'experience_years': experienceYears,
      'years_in_current_role': yearsInCurrentRole,
      'notice_period': noticePeriod,
      'expected_salary': expectedSalary,
      'education_level': educationLevel,
      'institution': institution,
      'skills': skills,
      'languages': languages,
      'linkedin_url': linkedinUrl,
      'github_url': githubUrl,
      'portfolio_url': portfolioUrl,
      'completionPercentage': completionPercentage,
      'cvCount': cvCount,
      'coverLetterCount': coverLetterCount,
      'sopCount': sopCount,
      'emailCount': emailCount,
      'isSubscriptionActive': isSubscriptionActive,
      'createdAt': createdAt,
    };
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? jobTitle,
    String? professionalHeadline,
    String? careerObjective,
    String? avatarUrl,
    String? bio,
    String? address,
    String? permanentAddress,
    String? dateOfBirth,
    String? gender,
    String? maritalStatus,
    String? nationality,
    String? fatherName,
    String? motherName,
    String? currentCompany,
    String? currentDesignation,
    String? experienceYears,
    String? yearsInCurrentRole,
    String? noticePeriod,
    String? expectedSalary,
    String? educationLevel,
    String? institution,
    List<String>? skills,
    List<String>? languages,
    String? linkedinUrl,
    String? githubUrl,
    String? portfolioUrl,
    int? completionPercentage,
    int? cvCount,
    int? coverLetterCount,
    int? sopCount,
    int? emailCount,
    bool? isSubscriptionActive,
    String? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      jobTitle: jobTitle ?? this.jobTitle,
      professionalHeadline: professionalHeadline ?? this.professionalHeadline,
      careerObjective: careerObjective ?? this.careerObjective,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      address: address ?? this.address,
      permanentAddress: permanentAddress ?? this.permanentAddress,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      nationality: nationality ?? this.nationality,
      fatherName: fatherName ?? this.fatherName,
      motherName: motherName ?? this.motherName,
      currentCompany: currentCompany ?? this.currentCompany,
      currentDesignation: currentDesignation ?? this.currentDesignation,
      experienceYears: experienceYears ?? this.experienceYears,
      yearsInCurrentRole: yearsInCurrentRole ?? this.yearsInCurrentRole,
      noticePeriod: noticePeriod ?? this.noticePeriod,
      expectedSalary: expectedSalary ?? this.expectedSalary,
      educationLevel: educationLevel ?? this.educationLevel,
      institution: institution ?? this.institution,
      skills: skills ?? this.skills,
      languages: languages ?? this.languages,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      cvCount: cvCount ?? this.cvCount,
      coverLetterCount: coverLetterCount ?? this.coverLetterCount,
      sopCount: sopCount ?? this.sopCount,
      emailCount: emailCount ?? this.emailCount,
      isSubscriptionActive: isSubscriptionActive ?? this.isSubscriptionActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static const sample = UserProfile(
    name: 'Mohammad Tanvir Ahmed',
    jobTitle: 'Senior Full Stack Software Engineer',
    professionalHeadline: 'Senior Full Stack Developer | 6+ Years Experience',
    careerObjective: 'Dedicated and results-oriented professional with a strong track record of success. Seeking to leverage proven technical and analytical skills to contribute to organizational growth and excellence.',
    email: 'tanvir.ahmed@example.com',
    phone: '+880 1712-345678',
    avatarUrl: '',
    bio: 'Results-driven professional with 6+ years of experience in product marketing and user acquisition.',
    address: 'House #12, Road #5, Dhanmondi, Dhaka-1209',
    permanentAddress: 'House #12, Road #5, Dhanmondi, Dhaka-1209',
    fatherName: 'Late Rafiqul Islam',
    motherName: 'Rahima Begum',
    dateOfBirth: '15 Jan 1996',
    gender: 'Male',
    maritalStatus: 'Single',
    nationality: 'Bangladeshi',
    experienceYears: '6+ years',
    yearsInCurrentRole: '3 years',
    noticePeriod: '30 days',
    expectedSalary: 'BDT 120,000 - 150,000',
    skills: ['Product Marketing', 'Growth Strategy', 'SEO', 'Data Analytics', 'Team Leadership'],
    educationLevel: "Bachelor's / Honours",
    institution: 'University of Dhaka',
    completionPercentage: 85,
    cvCount: 3,
    coverLetterCount: 2,
    sopCount: 1,
    emailCount: 5,
  );
}
