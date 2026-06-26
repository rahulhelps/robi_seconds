import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class SubmitPhoneNumber extends AuthEvent {
  final String phone;

  const SubmitPhoneNumber(this.phone);

  @override
  List<Object> get props => [phone];
}

class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class LoginSuccess extends AuthEvent {
  final String token;

  const LoginSuccess({required this.token});

  @override
  List<Object> get props => [token];
}

// ── OTP flow (platform_api, quickcv tenant) ───────────────────────────────────

/// Dispatched when the user submits their Robi/Airtel phone number.
/// Triggers POST /auth/otp/send.
class SendOtpRequested extends AuthEvent {
  final String phone;

  const SendOtpRequested(this.phone);

  @override
  List<Object> get props => [phone];
}

/// Dispatched when the user submits the OTP.
/// Triggers POST /auth/otp/verify, which also issues the JWT pair.
class OtpVerified extends AuthEvent {
  final String otp;
  final String referenceNo;
  final String phone;

  const OtpVerified({
    required this.otp,
    required this.referenceNo,
    required this.phone,
  });

  @override
  List<Object> get props => [otp, referenceNo, phone];
}

/// Dispatched on every app launch when a token already exists.
/// Triggers GET /auth/me to read subscription status.
class CheckSubscriptionStatus extends AuthEvent {
  final String phone;

  const CheckSubscriptionStatus(this.phone);

  @override
  List<Object> get props => [phone];
}

class UnsubscribeRequested extends AuthEvent {
  final String phone;

  const UnsubscribeRequested(this.phone);

  @override
  List<Object> get props => [phone];
}
