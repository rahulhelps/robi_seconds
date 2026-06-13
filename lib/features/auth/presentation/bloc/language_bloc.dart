import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// ── Events ──────────────────────────────────────────────────────────────────

abstract class LanguageEvent extends Equatable {
  const LanguageEvent();

  @override
  List<Object> get props => [];
}

class ChangeLanguage extends LanguageEvent {
  final String languageCode;

  const ChangeLanguage(this.languageCode);

  @override
  List<Object> get props => [languageCode];
}

// ── States ──────────────────────────────────────────────────────────────────

class LanguageState extends Equatable {
  final String languageCode;

  const LanguageState(this.languageCode);

  @override
  List<Object> get props => [languageCode];
}

// ── Bloc ────────────────────────────────────────────────────────────────────

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  LanguageBloc() : super(const LanguageState('en')) {
    on<ChangeLanguage>((event, emit) {
      emit(LanguageState(event.languageCode));
    });
  }
}
