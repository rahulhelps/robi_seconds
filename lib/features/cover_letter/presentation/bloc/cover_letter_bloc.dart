import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/cover_letter_model.dart';
import '../../domain/cover_letter_repository.dart';

// ── Events ───────────────────────────────────────────────────────────────────

abstract class CoverLetterEvent {
  const CoverLetterEvent();
}

/// Triggers GET /cover-letters/templates
class LoadTemplates extends CoverLetterEvent {
  const LoadTemplates();
}

/// Triggers GET /cover-letters/templates/:id and updates model
class SelectTemplate extends CoverLetterEvent {
  final String id;
  final int index;
  const SelectTemplate(this.id, this.index);
}

class UpdateCoverLetterField extends CoverLetterEvent {
  final String field;
  final String value;
  const UpdateCoverLetterField(this.field, this.value);
}

/// Triggers POST /cover-letters.
class CreateCoverLetter extends CoverLetterEvent {
  const CreateCoverLetter();
}

/// Triggers GET /cover-letters.
class FetchCoverLetters extends CoverLetterEvent {
  const FetchCoverLetters();
}

// ── States ───────────────────────────────────────────────────────────────────

abstract class CoverLetterState {
  final CoverLetterModel model;
  final List<CoverLetterTemplate> templates;
  const CoverLetterState(this.model, {this.templates = const []});
}

class CoverLetterInitial extends CoverLetterState {
  const CoverLetterInitial(super.model, {super.templates});
}

class CoverLetterLoading extends CoverLetterState {
  const CoverLetterLoading(super.model, {super.templates});
}

/// Emitted after successful POST /cover-letters.
class CoverLetterSuccess extends CoverLetterState {
  final SavedCoverLetter saved;
  const CoverLetterSuccess(super.model, this.saved, {super.templates});
}

/// Emitted after successful GET /cover-letters.
class CoverLetterLoaded extends CoverLetterState {
  final List<SavedCoverLetter> items;
  const CoverLetterLoaded(super.model, this.items, {super.templates});
}

class CoverLetterError extends CoverLetterState {
  final String message;
  const CoverLetterError(super.model, this.message, {super.templates});
}

// ── BLoC ─────────────────────────────────────────────────────────────────────

class CoverLetterBloc extends Bloc<CoverLetterEvent, CoverLetterState> {
  final CoverLetterRepository _repository;

  CoverLetterBloc(this._repository)
      : super(
          const CoverLetterInitial(
            CoverLetterModel(),
            templates: [],
          ),
        ) {
    on<LoadTemplates>(_onLoadTemplates);
    on<SelectTemplate>(_onSelectTemplate);
    on<UpdateCoverLetterField>(_onUpdateField);
    on<CreateCoverLetter>(_onCreateCoverLetter);
    on<FetchCoverLetters>(_onFetchCoverLetters);
  }

  Future<void> _onLoadTemplates(LoadTemplates event, Emitter<CoverLetterState> emit) async {
    if (state.templates.isNotEmpty) return; // Already loaded

    emit(CoverLetterLoading(state.model, templates: state.templates));
    try {
      final templates = await _repository.fetchTemplates();
      emit(CoverLetterInitial(state.model, templates: templates));

      // Auto-select the first one if model is empty
      if (templates.isNotEmpty && state.model.header.isEmpty && state.model.body.isEmpty) {
        add(SelectTemplate(templates.first.id, 0));
      }
    } catch (e) {
      if (kDebugMode) {
        print('[CoverLetterBloc] Fetch templates error: $e');
      }
      emit(CoverLetterError(state.model, 'Failed to load templates: $e', templates: state.templates));
    }
  }

  Future<void> _onSelectTemplate(SelectTemplate event, Emitter<CoverLetterState> emit) async {
    emit(CoverLetterLoading(state.model, templates: state.templates));
    try {
      final details = await _repository.fetchTemplateDetails(event.id);
      
      final updatedModel = state.model.copyWith(
        templateIndex: event.index,
        title: details.title,
        header: details.header,
        body: details.body,
        footer: details.footer,
      );

      emit(CoverLetterInitial(updatedModel, templates: state.templates));
    } catch (e) {
      if (kDebugMode) {
        print('[CoverLetterBloc] Select template error: $e');
      }
      emit(CoverLetterError(state.model, 'Failed to load template details.', templates: state.templates));
    }
  }

  void _onUpdateField(UpdateCoverLetterField event, Emitter<CoverLetterState> emit) {
    final updated = switch (event.field) {
      'header' => state.model.copyWith(header: event.value),
      'body' => state.model.copyWith(body: event.value),
      'footer' => state.model.copyWith(footer: event.value),
      _ => state.model,
    };
    emit(CoverLetterInitial(updated, templates: state.templates));
  }

  Future<void> _onCreateCoverLetter(CreateCoverLetter event, Emitter<CoverLetterState> emit) async {
    if (state.model.header.isEmpty || state.model.body.isEmpty || state.model.footer.isEmpty) {
      emit(CoverLetterError(state.model, 'All fields are required.', templates: state.templates));
      return;
    }

    emit(CoverLetterLoading(state.model, templates: state.templates));
    try {
      final saved = await _repository.postCoverLetter(state.model);
      emit(CoverLetterSuccess(state.model, saved, templates: state.templates));
    } catch (e) {
      if (kDebugMode) {
        print('[CoverLetterBloc] Create error: $e');
      }
      emit(CoverLetterError(state.model, 'Failed to create cover letter.', templates: state.templates));
    }
  }

  Future<void> _onFetchCoverLetters(FetchCoverLetters event, Emitter<CoverLetterState> emit) async {
    emit(CoverLetterLoading(state.model, templates: state.templates));
    try {
      final items = await _repository.fetchCoverLetters();
      emit(CoverLetterLoaded(state.model, items, templates: state.templates));
    } catch (e) {
      if (kDebugMode) {
        print('[CoverLetterBloc] Fetch error: $e');
      }
      emit(CoverLetterError(state.model, 'Failed to fetch cover letters.', templates: state.templates));
    }
  }
}
