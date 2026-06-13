import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/storage/user_storage.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileInitial()) {
    on<FetchProfile>(_onFetchProfile);
    on<ResetProfile>(_onResetProfile);
    on<UploadAvatarEvent>(_onUploadAvatar);
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
        localUser['profileImage'] = avatarUrl;
        await UserStorage.saveUser(localUser);
      }

      // Create new ProfileLoaded state with the updated avatar URL
      final updatedState = ProfileLoaded(
        cvHistory: currentState.cvHistory,
        cvCount: currentState.cvCount,
        phoneNumber: currentState.phoneNumber,
        isSubscriptionActive: currentState.isSubscriptionActive,
        coverLetterCount: currentState.coverLetterCount,
        coverLetterHistory: currentState.coverLetterHistory,
        sopCount: currentState.sopCount,
        sopHistory: currentState.sopHistory,
        email: currentState.email,
        memberSince: currentState.memberSince,
        profileImageUrl: avatarUrl,
      );

      emit(UploadAvatarSuccess(updatedState));
      // Optionally emit the base ProfileLoaded state to settle down
      emit(updatedState);
      
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('Session expired')) {
        emit(const ProfileSessionExpired());
      } else {
        emit(UploadAvatarFailure(currentState, msg));
        // Fallback to normal loaded state after showing error
        emit(currentState);
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
          // Show cached data immediately — no spinner for the user.
          emit(_stateFromUserMap(localUser));
          // Then silently refresh in the background to sync counts
          // (e.g. coverLetterCount) without showing a loading indicator.
          await _refreshFromNetwork(emit);
          return;
        }
      } catch (e) {
        print('[ProfileBloc] Local storage read failed: $e');
        // Fall through to network call.
      }
    }

    // ── Step 2: No local cache or forceNetwork=true — fetch from network ───
    try {
      final response = await AuthService.authenticatedGet('/profile');

      // authenticatedGet returns {'__status': 401} when refresh also failed.
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
      
      print("Updated cvCount received: ${data['cvCount']}");
      print("Updated coverLetterCount received: ${data['coverLetterCount']}");

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

  // ── Background network sync (stale-while-revalidate) ─────────────────────
  //
  // Called after local cache is served. Silently fetches fresh data from the
  // network and re-emits ProfileLoaded with updated counts (e.g. coverLetterCount).
  // Does NOT emit ProfileLoading — the UI never shows a spinner.
  Future<void> _refreshFromNetwork(Emitter<ProfileState> emit) async {
    try {
      final response = await AuthService.authenticatedGet('/profile');

      if (response['__status'] == 401) return; // Silently ignore — no logout here

      final bool success = response['success'] == true;
      if (!success) return;

      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) return;

      // Persist updated data for next launch.
      await UserStorage.saveUser(data);

      print('[ProfileBloc] Background sync — coverLetterCount: ${data['coverLetterCount']}, cvCount: ${data['cvCount']}');

      emit(_stateFromUserMap(data));
    } catch (_) {
      // Network error during background sync — silently ignore.
      // The local cache is already displayed; this is best-effort only.
    }
  }

  // ── Helper: build ProfileLoaded from a user map ────────────────────────────

  ProfileLoaded _stateFromUserMap(Map<String, dynamic> user) {
    final List<dynamic> historyRaw = user['cvHistory'] ?? [];
    final List<String> cvHistory =
        historyRaw.map((e) => e.toString()).toList();

    final int cvCount = (user['cvCount'] as num?)?.toInt() ?? 0;
    final String phoneNumber = (user['phoneNumber'] ?? '').toString();
    final bool isSubscriptionActive =
        user['isSubscriptionActive'] == true ||
        user['subscription_active'] == true;

    final List<dynamic> coverHistoryRaw = user['coverLetterHistory'] ?? [];
    final List<String> coverLetterHistory =
        coverHistoryRaw.map((e) => e.toString()).toList();

    final int coverLetterCount = (user['coverLetterCount'] as num?)?.toInt() ?? 0;

    final List<dynamic> sopHistoryRaw = user['sopHistory'] ?? [];
    final List<String> sopHistory =
        sopHistoryRaw.map((e) => e.toString()).toList();
    final int sopCount = (user['sopCount'] as num?)?.toInt() ?? sopHistoryRaw.length;

    final String? email =
        (user['email'] as String?)?.isNotEmpty == true ? user['email'] as String : null;
    final String? memberSince = user['createdAt'] as String?;
    final String? profileImageUrl = (user['avatarUrl'] as String?) ?? (user['profileImage'] as String?);

    return ProfileLoaded(
      cvHistory: cvHistory,
      cvCount: cvCount,
      phoneNumber: phoneNumber,
      isSubscriptionActive: isSubscriptionActive,
      coverLetterCount: coverLetterCount,
      coverLetterHistory: coverLetterHistory,
      sopCount: sopCount,
      sopHistory: sopHistory,
      email: email,
      memberSince: memberSince,
      profileImageUrl: profileImageUrl,
    );
  }
}
