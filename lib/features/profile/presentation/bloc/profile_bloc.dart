import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/storage/user_storage.dart';
import '../../domain/entities/user_profile.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileInitial()) {
    on<FetchProfile>(_onFetchProfile);
    on<ResetProfile>(_onResetProfile);
    on<UploadAvatarEvent>(_onUploadAvatar);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onUploadAvatar(
    UploadAvatarEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(UploadAvatarLoading(currentState));

    try {
      final response = await AuthService.uploadAvatar(
        event.filePath,
        event.fileName,
        event.mimeType,
      );

      final bool success = response['success'] == true;
      if (!success) {
        throw response['message'] ?? 'Failed to upload avatar';
      }

      final data = response['data'] as Map<String, dynamic>?;
      final avatarUrl = data?['avatarUrl'] as String?;

      if (avatarUrl == null) {
        throw 'Invalid server response: avatarUrl missing';
      }

      // Update local storage to persist the new profile picture URL
      final localUser = await UserStorage.getUser();
      if (localUser != null) {
        localUser['avatarUrl'] = avatarUrl;
        localUser['avatar_url'] = avatarUrl;
        localUser['profileImage'] = avatarUrl;
        await UserStorage.saveUser(localUser);
      }

      final updatedProfile = currentState.profile.copyWith(avatarUrl: avatarUrl);

      final updatedState = currentState.copyWith(profile: updatedProfile);

      emit(UploadAvatarSuccess(updatedState));
      emit(updatedState);
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('Session expired')) {
        emit(const ProfileSessionExpired());
      } else {
        emit(UploadAvatarFailure(currentState, msg));
        emit(currentState);
      }
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final response = await AuthService.authenticatedPatch('/profile', event.data);

      if (response['__status'] == 401) {
        emit(const ProfileSessionExpired());
        return;
      }

      final bool success = response['success'] == true;
      if (!success) {
        throw response['message'] ?? 'Failed to update profile';
      }

      final data = response['data'] as Map<String, dynamic>?;
      if (data != null) {
        await UserStorage.saveUser(data);
        emit(_stateFromUserMap(data));
      }
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('Session expired')) {
        emit(const ProfileSessionExpired());
      } else {
        emit(ProfileError(msg));
      }
    }
  }

  void _onResetProfile(ResetProfile event, Emitter<ProfileState> emit) {
    emit(const ProfileInitial());
  }

  Future<void> _onFetchProfile(
    FetchProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    // ── Step 1: Load from local storage (saved at login) ───────────────────
    if (!event.forceNetwork) {
      try {
        final localUser = await UserStorage.getUser();

        if (localUser != null) {
          emit(_stateFromUserMap(localUser));
          await _refreshFromNetwork(emit);
          return;
        }
      } catch (e) {
        debugPrint('[ProfileBloc] Local storage read failed: $e');
      }
    }

    // ── Step 2: Fetch from network ─────────────────────────────────────────
    try {
      final response = await AuthService.authenticatedGet('/profile');

      if (response['__status'] == 401) {
        emit(const ProfileSessionExpired());
        return;
      }

      final bool success = response['success'] == true;
      if (!success) {
        throw response['message'] ?? 'Failed to fetch profile';
      }

      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) throw 'Invalid server response: data is null';

      // Persist the fetched user so next launch is instant.
      await UserStorage.saveUser(data);

      emit(_stateFromUserMap(data));
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('Session expired')) {
        emit(const ProfileSessionExpired());
      } else {
        emit(ProfileError(msg));
      }
    }
  }

  Future<void> _refreshFromNetwork(Emitter<ProfileState> emit) async {
    try {
      final response = await AuthService.authenticatedGet('/profile');

      if (response['__status'] == 401) return;

      final bool success = response['success'] == true;
      if (!success) return;

      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) return;

      await UserStorage.saveUser(data);
      emit(_stateFromUserMap(data));
    } catch (_) {
      // Network error during background sync — silently ignore.
    }
  }

  // ── Helper: build ProfileLoaded from a user map ────────────────────────────

  ProfileLoaded _stateFromUserMap(Map<String, dynamic> userMap) {
    final profile = UserProfile.fromJson(userMap);

    final List<dynamic> historyRaw = userMap['cvHistory'] ?? [];
    final List<String> cvHistory = historyRaw.map((e) => e.toString()).toList();

    final List<dynamic> coverHistoryRaw = userMap['coverLetterHistory'] ?? [];
    final List<String> coverLetterHistory = coverHistoryRaw.map((e) => e.toString()).toList();

    final List<dynamic> sopHistoryRaw = userMap['sopHistory'] ?? [];
    final List<String> sopHistory = sopHistoryRaw.map((e) => e.toString()).toList();

    return ProfileLoaded(
      profile: profile,
      cvHistory: cvHistory,
      coverLetterHistory: coverLetterHistory,
      sopHistory: sopHistory,
    );
  }
}
