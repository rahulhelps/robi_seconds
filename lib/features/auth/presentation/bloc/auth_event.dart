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

// ── BDApps OTP flow ───────────────────────────────────────────────────────────

/// Dispatched when the user submits their Robi/Airtel phone number.
/// Triggers POST /send_otp.php.
class SendOtpRequested extends AuthEvent {
  final String phone;

  const SendOtpRequested(this.phone);

  @override
  List<Object> get props => [phone];
}

/// Dispatched when the user submits the 6-digit OTP.
/// Triggers POST /verify_otp.php, then POST /auth/phone-auth for JWT.
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
/// Triggers POST /check_subscription.php.
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
