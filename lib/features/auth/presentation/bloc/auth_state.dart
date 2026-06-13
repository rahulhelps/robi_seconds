import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthOtpRequired extends AuthState {}

class AuthEmailRequired extends AuthState {}

class AuthAuthenticated extends AuthState {
  final Map<String, dynamic>? user;

  const AuthAuthenticated([this.user]);

  @override
  List<Object> get props => [if (user != null) user!];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

// ── BDApps OTP flow states ────────────────────────────────────────────────────

/// OTP was sent successfully. Carries referenceNo and phone for the OTP screen.
class AuthOtpSent extends AuthState {
  final String referenceNo;
  final String phone;

  const AuthOtpSent({required this.referenceNo, required this.phone});

  @override
  List<Object> get props => [referenceNo, phone];
}

/// Subscription check returned UNREGISTERED.
class AuthSubscriptionExpired extends AuthState {
  final String phone;

  const AuthSubscriptionExpired(this.phone);

  @override
  List<Object> get props => [phone];
}

/// Subscription check returned INITIAL CHARGING PENDING.
class AuthSubscriptionPending extends AuthState {
  final String phone;

  const AuthSubscriptionPending(this.phone);

  @override
  List<Object> get props => [phone];
}

// ── Unsubscribe flow states ───────────────────────────────────────────────────

class AuthUnsubscribeLoading extends AuthState {}

class AuthUnsubscribeSuccess extends AuthState {}

class AuthUnsubscribeFailure extends AuthState {
  final String message;

  const AuthUnsubscribeFailure(this.message);

  @override
  List<Object> get props => [message];
}
