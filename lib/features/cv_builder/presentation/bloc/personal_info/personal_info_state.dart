part of 'personal_info_bloc.dart';

class PersonalInfoState {
  final String fullName;
  final String jobTitle;
  final String email;
  final String phone;
  final String location;
  final String bio;

  const PersonalInfoState({
    this.fullName = '',
    this.jobTitle = '',
    this.email = '',
    this.phone = '',
    this.location = '',
    this.bio = '',
  });

  PersonalInfoState copyWith({
    String? fullName,
    String? jobTitle,
    String? email,
    String? phone,
    String? location,
    String? bio,
  }) {
    return PersonalInfoState(
      fullName: fullName ?? this.fullName,
      jobTitle: jobTitle ?? this.jobTitle,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      bio: bio ?? this.bio,
    );
  }
}
