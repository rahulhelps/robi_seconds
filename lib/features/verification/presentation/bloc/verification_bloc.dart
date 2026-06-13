import 'package:flutter_bloc/flutter_bloc.dart';
import 'verification_event.dart';
import 'verification_state.dart';

class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
  VerificationBloc() : super(const VerificationInitial()) {
    on<VerificationCodeSubmitted>(_onCodeSubmitted);
  }

  Future<void> _onCodeSubmitted(VerificationCodeSubmitted event, Emitter<VerificationState> emit) async {
    emit(const VerificationLoading());
    // Mock network request to verify the OTP code
    await Future.delayed(const Duration(seconds: 2));
    // Assume success for all mock inputs
    emit(const VerificationSuccess());
  }
}
