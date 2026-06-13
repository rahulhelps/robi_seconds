import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:email_validator/email_validator.dart';
import '../../../../core/services/auth_service.dart';

part 'email_registration_event.dart';
part 'email_registration_state.dart';

class EmailRegistrationBloc
    extends Bloc<EmailRegistrationEvent, EmailRegistrationState> {
  EmailRegistrationBloc() : super(const EmailRegistrationInitial()) {
    on<EmailChanged>(_onEmailChanged);
    on<EmailSubmitted>(_onEmailSubmitted);
  }

  /// Real-time validation on every keystroke.
  /// Transitions between Initial ↔ Valid ↔ Invalid.
  void _onEmailChanged(
    EmailChanged event,
    Emitter<EmailRegistrationState> emit,
  ) {
    final email = event.email.trim();
    if (email.isEmpty) {
      emit(const EmailRegistrationInitial());
    } else if (EmailValidator.validate(email)) {
      emit(const EmailRegistrationValid());
    } else {
      emit(const EmailRegistrationInvalid('Enter a valid email address'));
    }
  }

  /// Submit handler:
  ///  1. Re-validates (defensive)
  ///  2. Calls PUT /profile
  ///  3. Emits Loading → Success | Error
  Future<void> _onEmailSubmitted(
    EmailSubmitted event,
    Emitter<EmailRegistrationState> emit,
  ) async {
    final email = event.email.trim();

    // Defensive re-validation before API call
    if (!EmailValidator.validate(email)) {
      emit(const EmailRegistrationInvalid('Enter a valid email address'));
      return;
    }

    emit(const EmailRegistrationLoading());

    try {
      final response = await AuthService.authenticatedPut(
        '/profile',
        {'email': email},
      );

      final bool success = response['success'] == true;
      if (!success) {
        final msg = response['message'] ?? 'Failed to update email.';
        emit(EmailRegistrationError(msg.toString()));
        return;
      }

      emit(const EmailRegistrationSuccess());
    } catch (e) {
      emit(EmailRegistrationError(_friendlyError(e.toString())));
    }
  }

  String _friendlyError(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('socket') || lower.contains('connection')) {
      return 'No internet connection. Please try again.';
    }
    if (lower.contains('401') || lower.contains('unauthorized')) {
      return 'Session expired. Please log in again.';
    }
    return raw;
  }
}
