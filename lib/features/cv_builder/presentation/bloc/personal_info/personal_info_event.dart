part of 'personal_info_bloc.dart';

abstract class PersonalInfoEvent {}

class PersonalInfoFieldChanged extends PersonalInfoEvent {
  final String field;
  final String value;
  PersonalInfoFieldChanged(this.field, this.value);
}

class SaveDraftClicked extends PersonalInfoEvent {}

class ContinueClicked extends PersonalInfoEvent {}
