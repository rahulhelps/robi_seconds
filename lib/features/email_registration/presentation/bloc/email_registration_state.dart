part of 'email_registration_bloc.dart';

abstract class EmailRegistrationState {
  const EmailRegistrationState();
}

/// No email entered yet — button is disabled.
class EmailRegistrationInitial extends EmailRegistrationState {
  const EmailRegistrationInitial();
}

/// Email passes format validation — button is enabled.
class EmailRegistrationValid extends EmailRegistrationState {
  const EmailRegistrationValid();
}

/// Email fails format validation — show inline error.
class EmailRegistrationInvalid extends EmailRegistrationState {
  final String errorMessage;
  const EmailRegistrationInvalid(this.errorMessage);
}

/// PUT /profile API call in progress.
class EmailRegistrationLoading extends EmailRegistrationState {
  const EmailRegistrationLoading();
}

/// API returned success.
class EmailRegistrationSuccess extends EmailRegistrationState {
  const EmailRegistrationSuccess();
}

/// API returned error or network failure.
class EmailRegistrationError extends EmailRegistrationState {
  final String message;
  const EmailRegistrationError(this.message);
}
