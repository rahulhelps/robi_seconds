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
  final List<String> cvHistory;
  final int cvCount;
  final String phoneNumber;
  final bool isSubscriptionActive;
  final int coverLetterCount;
  final List<String> coverLetterHistory;
  final int sopCount;
  final List<String> sopHistory;

  // ── Extended user fields ──────────────────────────────────────────────────
  /// Email address — may be null/empty if not provided.
  final String? email;

  /// Raw `createdAt` string from the server (ISO-8601). Display layer formats it.
  final String? memberSince;

  /// URL to the user's profile image. Null means show a placeholder.
  final String? profileImageUrl;

  const ProfileLoaded({
    required this.cvHistory,
    required this.cvCount,
    required this.phoneNumber,
    required this.isSubscriptionActive,
    required this.coverLetterCount,
    required this.coverLetterHistory,
    required this.sopCount,
    required this.sopHistory,
    this.email,
    this.memberSince,
    this.profileImageUrl,
  });
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
  UploadAvatarLoading(ProfileLoaded state) : super(
    cvHistory: state.cvHistory,
    cvCount: state.cvCount,
    phoneNumber: state.phoneNumber,
    isSubscriptionActive: state.isSubscriptionActive,
    coverLetterCount: state.coverLetterCount,
    coverLetterHistory: state.coverLetterHistory,
    sopCount: state.sopCount,
    sopHistory: state.sopHistory,
    email: state.email,
    memberSince: state.memberSince,
    profileImageUrl: state.profileImageUrl,
  );
}

class UploadAvatarSuccess extends ProfileLoaded {
  UploadAvatarSuccess(ProfileLoaded state) : super(
    cvHistory: state.cvHistory,
    cvCount: state.cvCount,
    phoneNumber: state.phoneNumber,
    isSubscriptionActive: state.isSubscriptionActive,
    coverLetterCount: state.coverLetterCount,
    coverLetterHistory: state.coverLetterHistory,
    sopCount: state.sopCount,
    sopHistory: state.sopHistory,
    email: state.email,
    memberSince: state.memberSince,
    profileImageUrl: state.profileImageUrl,
  );
}

class UploadAvatarFailure extends ProfileLoaded {
  final String error;
  UploadAvatarFailure(ProfileLoaded state, this.error) : super(
    cvHistory: state.cvHistory,
    cvCount: state.cvCount,
    phoneNumber: state.phoneNumber,
    isSubscriptionActive: state.isSubscriptionActive,
    coverLetterCount: state.coverLetterCount,
    coverLetterHistory: state.coverLetterHistory,
    sopCount: state.sopCount,
    sopHistory: state.sopHistory,
    email: state.email,
    memberSince: state.memberSince,
    profileImageUrl: state.profileImageUrl,
  );
}
