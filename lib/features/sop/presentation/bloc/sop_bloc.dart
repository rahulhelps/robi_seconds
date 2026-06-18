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

class SopDeleteRequested extends SopEvent {
  final String id;
  const SopDeleteRequested(this.id);
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
  final SavedSop? savedSop;
  final List<SavedSop>? history;
  final Uint8List? pdfBytes;
  final String? generatedPayload;
  final SopModel? model;
  
  const SopSuccess({this.savedSop, this.history, this.pdfBytes, this.generatedPayload, this.model});
}

class SopDeleteSuccess extends SopState {
  const SopDeleteSuccess();
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
    on<SopDeleteRequested>(_onDeleteRequested);
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
      
      // Make API call to create the SOP on the backend
      final result = await _repository.createSop(event.model);
      
      await result.fold(
        (failure) async {
          emit(SopFailure(failure.message));
        },
        (savedSop) async {
          // Generate fallback payload if backend returns empty fields
          final hasText = savedSop.header.isNotEmpty || savedSop.body.isNotEmpty;
          final headerText = hasText ? savedSop.header : 'Statement of Purpose';
          final footerText = hasText ? savedSop.footer : 'Sincerely,\n${event.model.name}';
          
          final bodyText = hasText ? savedSop.body : '''I am writing to express my profound interest in the ${event.model.programName} program at ${event.model.universityName}, ${event.model.country}. With a strong academic foundation and a clear vision for my future, I am confident that this program aligns perfectly with my career aspirations.

${event.model.academicBackground != null ? 'My academic journey in ${event.model.academicBackground} ' : 'My academic journey '}${event.model.gpa != null ? 'with a GPA of ${event.model.gpa} ' : ''}has equipped me with the analytical and technical skills necessary to thrive in a rigorous academic environment. 

${event.model.workExperience != null ? 'Professionally, my experience in ${event.model.workExperience} has further solidified my practical understanding and ability to apply theoretical concepts to real-world challenges. ' : ''}${event.model.researchExperience != null ? 'Additionally, my research on ${event.model.researchExperience} highlights my commitment to advancing knowledge in this field. ' : ''}

${event.model.whyThisUniversity != null ? 'I chose ${event.model.universityName} because of ${event.model.whyThisUniversity}. ' : 'The esteemed faculty, state-of-the-art facilities, and diverse community at ${event.model.universityName} make it the ideal place for me to pursue my studies. '}

Upon completing the ${event.model.programName} program, my goal is to ${event.model.goals ?? 'contribute meaningfully to the industry and society'}. ${event.model.skills != null ? 'My proficiency in ${event.model.skills} will be instrumental in achieving these objectives. ' : ''}

I look forward to the opportunity to contribute to and grow within your esteemed institution.''';

          // Generate the PDF bytes locally using the structured text from the saved SOP
          final sopText = '$headerText\n\n$bodyText\n\n$footerText';
          final pdfBytes = await _pdfGenerator.generatePdf(event.model, template, sopText);
          
          emit(SopSuccess(
            savedSop: savedSop, 
            pdfBytes: pdfBytes, 
            generatedPayload: sopText, 
            model: event.model,
          ));
          
          // Instant Counter Sync: immediately reload active SOP list history
          add(const SopHistoryRequested());
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

  Future<void> _onDeleteRequested(SopDeleteRequested event, Emitter<SopState> emit) async {
    emit(const SopLoading());
    final result = await _repository.deleteSop(event.id);
    await result.fold(
      (failure) async => emit(SopFailure(failure.message)),
      (_) async {
        emit(const SopDeleteSuccess());
        // Re-fetch history
        add(const SopHistoryRequested());
      },
    );
  }
}
