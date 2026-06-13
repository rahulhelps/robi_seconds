part of 'email_registration_bloc.dart';

abstract class EmailRegistrationEvent {
  const EmailRegistrationEvent();
}

/// Fired on every keystroke — validates format, enables/disables the button.
class EmailChanged extends EmailRegistrationEvent {
  final String email;
  const EmailChanged(this.email);
}

/// Fired when the user taps the submit button — calls PUT /profile.
class EmailSubmitted extends EmailRegistrationEvent {
  final String email;
  const EmailSubmitted(this.email);
}
