part of 'profile_bloc.dart';

abstract class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final UserProfile profile;
  final List<String> cvHistory;
  final List<String> coverLetterHistory;
  final List<String> sopHistory;

  // Convenient getters for backward compatibility
  int get cvCount => profile.cvCount;
  String get phoneNumber => profile.phone;
  bool get isSubscriptionActive => profile.isSubscriptionActive;
  int get coverLetterCount => profile.coverLetterCount;
  int get sopCount => profile.sopCount;
  int get emailCount => profile.emailCount;
  String? get email => profile.email.isNotEmpty ? profile.email : null;
  String? get memberSince => profile.createdAt.isNotEmpty ? profile.createdAt : null;
  String? get profileImageUrl => profile.avatarUrl.isNotEmpty ? profile.avatarUrl : null;
  String? get name => profile.name.isNotEmpty ? profile.name : null;
  String? get jobTitle => profile.jobTitle.isNotEmpty ? profile.jobTitle : null;
  int get completionPercentage => profile.completionPercentage;

  ProfileLoaded({
    UserProfile? profile,
    List<String>? cvHistory,
    int? cvCount,
    String? phoneNumber,
    bool? isSubscriptionActive,
    int? coverLetterCount,
    List<String>? coverLetterHistory,
    int? sopCount,
    List<String>? sopHistory,
    String? email,
    String? memberSince,
    String? profileImageUrl,
  })  : cvHistory = cvHistory ?? const [],
        coverLetterHistory = coverLetterHistory ?? const [],
        sopHistory = sopHistory ?? const [],
        profile = profile ??
            UserProfile(
              phone: phoneNumber ?? '',
              email: email ?? '',
              cvCount: cvCount ?? 0,
              coverLetterCount: coverLetterCount ?? 0,
              sopCount: sopCount ?? 0,
              isSubscriptionActive: isSubscriptionActive ?? false,
              avatarUrl: profileImageUrl ?? '',
              createdAt: memberSince ?? '',
            );

  ProfileLoaded copyWith({
    UserProfile? profile,
    List<String>? cvHistory,
    List<String>? coverLetterHistory,
    List<String>? sopHistory,
  }) {
    return ProfileLoaded(
      profile: profile ?? this.profile,
      cvHistory: cvHistory ?? this.cvHistory,
      coverLetterHistory: coverLetterHistory ?? this.coverLetterHistory,
      sopHistory: sopHistory ?? this.sopHistory,
    );
  }
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
}

class ProfileSessionExpired extends ProfileState {
  const ProfileSessionExpired();
}

// ── Avatar Upload States ────────────────────────────────────────────────────

class UploadAvatarLoading extends ProfileLoaded {
  UploadAvatarLoading(ProfileLoaded state)
      : super(
          profile: state.profile,
          cvHistory: state.cvHistory,
          coverLetterHistory: state.coverLetterHistory,
          sopHistory: state.sopHistory,
        );
}

class UploadAvatarSuccess extends ProfileLoaded {
  UploadAvatarSuccess(ProfileLoaded state)
      : super(
          profile: state.profile,
          cvHistory: state.cvHistory,
          coverLetterHistory: state.coverLetterHistory,
          sopHistory: state.sopHistory,
        );
}

class UploadAvatarFailure extends ProfileLoaded {
  final String error;
  UploadAvatarFailure(ProfileLoaded state, this.error)
      : super(
          profile: state.profile,
          cvHistory: state.cvHistory,
          coverLetterHistory: state.coverLetterHistory,
          sopHistory: state.sopHistory,
        );
}
