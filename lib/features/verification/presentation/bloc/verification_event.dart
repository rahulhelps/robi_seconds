abstract class VerificationEvent {
  const VerificationEvent();
}

class VerificationCodeSubmitted extends VerificationEvent {
  final String code;
  
  const VerificationCodeSubmitted(this.code);
}
