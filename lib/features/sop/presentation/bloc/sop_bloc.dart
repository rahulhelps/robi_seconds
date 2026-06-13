import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/download_service.dart';
import '../../data/sop_pdf_generator.dart';
import '../../domain/sop_model.dart';
import '../../domain/sop_repository.dart';

// ── Events ───────────────────────────────────────────────────────────────────

abstract class SopEvent {
  const SopEvent();
}

class SopFormUpdated extends SopEvent {
  final SopModel model;
  const SopFormUpdated(this.model);
}

class SopTemplateSelected extends SopEvent {
  final String templateId;
  const SopTemplateSelected(this.templateId);
}

class SopGenerateRequested extends SopEvent {
  final SopModel model;
  const SopGenerateRequested(this.model);
}

class SopDownloadRequested extends SopEvent {
  final Uint8List pdfBytes;
  const SopDownloadRequested(this.pdfBytes);
}

class SopHistoryRequested extends SopEvent {
  const SopHistoryRequested();
}

// ── States ───────────────────────────────────────────────────────────────────

abstract class SopState {
  const SopState();
}

class SopInitial extends SopState {
  const SopInitial();
}

class SopFormState extends SopState {
  final SopModel model;
  const SopFormState(this.model);
}

class SopLoading extends SopState {
  const SopLoading();
}

class SopDownloadLoading extends SopState {
  const SopDownloadLoading();
}

class SopDownloadSuccess extends SopState {
  final String path;
  const SopDownloadSuccess(this.path);
}

class SopSuccess extends SopState {
  final String? result;
  final List<SopModel>? history;
  final Uint8List? pdfBytes;
  
  const SopSuccess({this.result, this.history, this.pdfBytes});
}

class SopFailure extends SopState {
  final String errorMessage;
  const SopFailure(this.errorMessage);
}

// ── BLoC ─────────────────────────────────────────────────────────────────────

class SopBloc extends Bloc<SopEvent, SopState> {
  final SopRepository _repository;
  final SopPdfGenerator _pdfGenerator;
  
  SopModel _currentModel = const SopModel(
    name: '',
    programName: '',
    universityName: '',
    country: '',
  );

  SopBloc(this._repository, this._pdfGenerator) : super(const SopInitial()) {
    on<SopFormUpdated>(_onFormUpdated);
    on<SopTemplateSelected>(_onTemplateSelected);
    on<SopGenerateRequested>(_onGenerateRequested);
    on<SopDownloadRequested>(_onDownloadRequested);
    on<SopHistoryRequested>(_onHistoryRequested);
  }

  void _onFormUpdated(SopFormUpdated event, Emitter<SopState> emit) {
    _currentModel = event.model;
    emit(SopFormState(_currentModel));
  }

  void _onTemplateSelected(SopTemplateSelected event, Emitter<SopState> emit) {
    _currentModel = _currentModel.copyWith(templateId: event.templateId);
    emit(SopFormState(_currentModel));
  }

  Future<void> _onGenerateRequested(SopGenerateRequested event, Emitter<SopState> emit) async {
    emit(const SopLoading());
    
    try {
      final template = SopTemplate(
        id: event.model.templateId ?? 'classic_academic', 
        title: 'Template', 
      );
      
      // Fetch the AI text first so we can embed it in the PDF
      final result = await _repository.generateSop(event.model);
      
      await result.fold(
        (failure) async {
          emit(SopFailure(failure.message));
        },
        (sopText) async {
          // Generate the PDF bytes locally using the structured text
          final pdfBytes = await _pdfGenerator.generatePdf(event.model, template, sopText);
          emit(SopSuccess(result: sopText, pdfBytes: pdfBytes));
        },
      );
    } catch (e) {
      emit(SopFailure(e.toString()));
    }
  }

  Future<void> _onDownloadRequested(SopDownloadRequested event, Emitter<SopState> emit) async {
    emit(const SopDownloadLoading());
    try {
      final savedPath = await DownloadService.downloadAndSaveFile(
        existingBytes: event.pdfBytes,
        baseFileName: 'StatementOfPurpose',
        fileExtension: 'pdf',
        subDirectory: 'SOP',
      );
      emit(SopDownloadSuccess(savedPath));
    } catch (e) {
      emit(SopFailure(e.toString()));
    }
  }

  Future<void> _onHistoryRequested(SopHistoryRequested event, Emitter<SopState> emit) async {
    emit(const SopLoading());
    final result = await _repository.getSopHistory();
    result.fold(
      (failure) => emit(SopFailure(failure.message)),
      (history) => emit(SopSuccess(history: history)),
    );
  }
}
