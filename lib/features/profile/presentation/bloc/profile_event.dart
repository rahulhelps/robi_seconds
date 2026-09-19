part of 'profile_bloc.dart';

abstract class ProfileEvent {
  const ProfileEvent();
}

/// Fetch the user profile data including CV history.
class FetchProfile extends ProfileEvent {
  final bool forceNetwork;
  const FetchProfile({this.forceNetwork = false});
}

/// Reset profile state to initial (on logout).
class ResetProfile extends ProfileEvent {
  const ResetProfile();
}

/// Request to upload a new avatar image.
class UploadAvatarEvent extends ProfileEvent {
  final String filePath;
  final String fileName;
  final String mimeType;
  const UploadAvatarEvent(this.filePath, this.fileName, this.mimeType);
}

/// Request to update profile details.
class UpdateProfileEvent extends ProfileEvent {
  final Map<String, dynamic> data;
  const UpdateProfileEvent(this.data);
}
