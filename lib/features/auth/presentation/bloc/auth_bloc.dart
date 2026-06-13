import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/bdapps_service.dart';
import '../../../../core/storage/token_manager.dart';
import '../../../../core/storage/user_storage.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../domain/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<SubmitPhoneNumber>(_onSubmitPhoneNumber);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LogoutRequested>(_onLogoutRequested);
    on<LoginSuccess>(_onLoginSuccess);
    // BDApps OTP flow
    on<SendOtpRequested>(_onSendOtpRequested);
    on<OtpVerified>(_onOtpVerified);
    on<CheckSubscriptionStatus>(_onCheckSubscriptionStatus);
    on<UnsubscribeRequested>(_onUnsubscribeRequested);
  }

  // ── Check persistent session ──────────────────────────────────────────────

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final token = await TokenManager.getToken();
      if (token != null && token.isNotEmpty) {
        final user = await AuthService.getCurrentUser();
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  // ── Phone login ───────────────────────────────────────────────────────────

  Future<void> _onSubmitPhoneNumber(
    SubmitPhoneNumber event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      print("AuthBloc: calling AuthService");
      await _authRepository.phoneAuth(event.phone);
      print("AuthService method triggered");

      final user = await AuthService.getCurrentUser();
      
      // Ensure the phone is preserved in the user object if mock
      final safeUser = user ?? {'phoneNumber': event.phone};
      if (!safeUser.containsKey('phoneNumber') && !safeUser.containsKey('phone')) {
         safeUser['phoneNumber'] = event.phone;
      }
      
      emit(AuthAuthenticated(safeUser));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Clear tokens and user data from storage
    await AuthService.logout(); 
    emit(AuthUnauthenticated());
  }

  // ── Login Success ─────────────────────────────────────────────────────────

  Future<void> _onLoginSuccess(
    LoginSuccess event,
    Emitter<AuthState> emit,
  ) async {
    await TokenManager.saveAccessToken(event.token);
    final user = await AuthService.getCurrentUser();
    emit(AuthAuthenticated(user));
  }

  // ── BDApps: Send OTP ──────────────────────────────────────────────────────

  Future<void> _onSendOtpRequested(
    SendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await BDAppsService.sendOtp(event.phone);
      if (result.success) {
        // success == true AND referenceNo present → go to OTP screen.
        emit(AuthOtpSent(referenceNo: result.referenceNo, phone: event.phone));
      } else if (result.statusDetail == "user already registered") {
        try {
          await AuthService.loginWithPhone(event.phone);
          await UserStorage.savePhone(event.phone);
          await UserStorage.updateSubscriptionStatus(true);
          
          emit(AuthEmailRequired());
        } catch (e) {
          emit(AuthError(e.toString()));
        }
      } else {
        // Failure → stay on Auth Screen, show statusDetail in snackbar.
        emit(AuthError(result.statusDetail ?? 'Failed to send OTP.'));
      }
    } catch (e) {
      emit(AuthError('Network error. Please check your connection.'));
    }
  }

  // ── BDApps: Verify OTP + JWT Login ────────────────────────────────────────

  Future<void> _onOtpVerified(
    OtpVerified event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Step 1: Verify OTP with BDApps
      final verifyResult = await BDAppsService.verifyOtp(
        event.otp,
        event.referenceNo,
      );

      if (!verifyResult.success) {
        emit(AuthError(verifyResult.errorMessage ?? 'OTP verification failed.'));
        return;
      }

      // Step 2: Call JWT backend (POST /auth/phone-auth)
      await AuthService.loginWithPhone(event.phone);

      // loginWithPhone already saves accessToken, refreshToken, and user.
      // Also persist phone for subscription checks on future launches.
      await UserStorage.savePhone(event.phone);
      await UserStorage.updateSubscriptionStatus(true);

      final user = await AuthService.getCurrentUser();
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(_friendlyError(e)));
    }
  }

  // ── BDApps: Check Subscription ────────────────────────────────────────────

  Future<void> _onCheckSubscriptionStatus(
    CheckSubscriptionStatus event,
    Emitter<AuthState> emit,
  ) async {
    // No loading state – splash screen manages its own progress display.
    try {
      final result = await BDAppsService.checkSubscription(event.phone);

      switch (result.status) {
        case BDAppsSubscriptionStatus.registered:
          await UserStorage.updateSubscriptionStatus(true);
          final user = await AuthService.getCurrentUser();
          emit(AuthAuthenticated(user));

        case BDAppsSubscriptionStatus.unregistered:
          await UserStorage.updateSubscriptionStatus(false);
          emit(AuthSubscriptionExpired(event.phone));

        case BDAppsSubscriptionStatus.initialChargingPending:
          emit(AuthSubscriptionPending(event.phone));

        case BDAppsSubscriptionStatus.unknown:
          // Treat unknown as authenticated to avoid blocking the user.
          final user = await AuthService.getCurrentUser();
          emit(AuthAuthenticated(user));
      }
    } catch (e) {
      // On network failure fall back to the locally cached status.
      final isActive = await UserStorage.getSubscriptionStatus();
      if (isActive) {
        final user = await AuthService.getCurrentUser();
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthSubscriptionExpired(event.phone));
      }
    }
  }

  // ── BDApps: Unsubscribe ───────────────────────────────────────────────────

  Future<void> _onUnsubscribeRequested(
    UnsubscribeRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthUnsubscribeLoading());
    try {
      final result = await BDAppsService.unsubscribe(event.phone);
      if (result.success) {
        await UserStorage.updateSubscriptionStatus(false);
        await AuthService.logout();
        emit(AuthUnsubscribeSuccess());
      } else {
        emit(AuthUnsubscribeFailure(
            result.errorMessage ?? 'Failed to unsubscribe.'));
      }
    } catch (e) {
      emit(AuthUnsubscribeFailure(_friendlyError(e)));
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('SocketException') || msg.contains('NetworkException')) {
      return 'No internet connection. Please try again.';
    }
    if (msg.contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    }
    return msg.isNotEmpty ? msg : 'An unexpected error occurred.';
  }
}
