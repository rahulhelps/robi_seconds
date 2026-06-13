import 'package:flutter_bloc/flutter_bloc.dart';

part 'personal_info_event.dart';
part 'personal_info_state.dart';

class PersonalInfoBloc extends Bloc<PersonalInfoEvent, PersonalInfoState> {
  PersonalInfoBloc() : super(const PersonalInfoState()) {
    on<PersonalInfoFieldChanged>(_onFieldChanged);
    on<SaveDraftClicked>(_onSaveDraft);
    on<ContinueClicked>(_onContinue);
  }

  void _onFieldChanged(
    PersonalInfoFieldChanged event,
    Emitter<PersonalInfoState> emit,
  ) {
    switch (event.field) {
      case 'fullName':
        emit(state.copyWith(fullName: event.value));
        break;
      case 'jobTitle':
        emit(state.copyWith(jobTitle: event.value));
        break;
      case 'email':
        emit(state.copyWith(email: event.value));
        break;
      case 'phone':
        emit(state.copyWith(phone: event.value));
        break;
      case 'location':
        emit(state.copyWith(location: event.value));
        break;
      case 'bio':
        emit(state.copyWith(bio: event.value));
        break;
    }
  }

  void _onSaveDraft(
    SaveDraftClicked event,
    Emitter<PersonalInfoState> emit,
  ) {
    // Logic intended for saving as draft
  }

  void _onContinue(
    ContinueClicked event,
    Emitter<PersonalInfoState> emit,
  ) {
    // Logic intended for continuing to the next step
  }
}
