import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/download_service.dart';
import '../../data/email_pdf_generator.dart';
import '../../domain/email_model.dart';
import '../../domain/email_repository.dart';

// ignore_for_file: avoid_print

// ── Events ───────────────────────────────────────────────────────────────────

abstract class EmailEvent {
  const EmailEvent();
}

class EmailFormUpdated extends EmailEvent {
  final EmailModel model;
  const EmailFormUpdated(this.model);
}

class EmailTemplateSelected extends EmailEvent {
  final String templateId;
  const EmailTemplateSelected(this.templateId);
}

class EmailGenerateRequested extends EmailEvent {
  final EmailModel model;
  const EmailGenerateRequested(this.model);
}

class EmailDownloadRequested extends EmailEvent {
  final Uint8List pdfBytes;
  const EmailDownloadRequested(this.pdfBytes);
}

class EmailHistoryRequested extends EmailEvent {
  const EmailHistoryRequested();
}

class EmailDeleteRequested extends EmailEvent {
  final String id;
  const EmailDeleteRequested(this.id);
}

// ── States ───────────────────────────────────────────────────────────────────

abstract class EmailState {
  const EmailState();
}

class EmailInitial extends EmailState {
  const EmailInitial();
}

class EmailFormState extends EmailState {
  final EmailModel model;
  const EmailFormState(this.model);
}

class EmailLoading extends EmailState {
  const EmailLoading();
}

class EmailDownloadLoading extends EmailState {
  const EmailDownloadLoading();
}

class EmailDownloadSuccess extends EmailState {
  final String path;
  const EmailDownloadSuccess(this.path);
}

class EmailSuccess extends EmailState {
  final SavedEmail? savedEmail;
  final List<SavedEmail>? history;
  final Uint8List? pdfBytes;
  final String? generatedBody;
  final EmailModel? model;

  const EmailSuccess({
    this.savedEmail,
    this.history,
    this.pdfBytes,
    this.generatedBody,
    this.model,
  });
}

class EmailDeleteSuccess extends EmailState {
  const EmailDeleteSuccess();
}

class EmailFailure extends EmailState {
  final String errorMessage;
  const EmailFailure(this.errorMessage);
}

// ── BLoC ─────────────────────────────────────────────────────────────────────

class EmailBloc extends Bloc<EmailEvent, EmailState> {
  final EmailRepository _repository;
  final EmailPdfGenerator _pdfGenerator;

  EmailModel _currentModel = const EmailModel(
    emailType: 'Job Application Email',
    senderName: '',
    recipientName: '',
    recipientDesignation: '',
    companyName: '',
    subject: '',
  );

  EmailBloc(this._repository, this._pdfGenerator)
      : super(const EmailInitial()) {
    on<EmailFormUpdated>(_onFormUpdated);
    on<EmailTemplateSelected>(_onTemplateSelected);
    on<EmailGenerateRequested>(_onGenerateRequested);
    on<EmailDownloadRequested>(_onDownloadRequested);
    on<EmailHistoryRequested>(_onHistoryRequested);
    on<EmailDeleteRequested>(_onDeleteRequested);
  }

  void _onFormUpdated(EmailFormUpdated event, Emitter<EmailState> emit) {
    _currentModel = event.model;
    emit(EmailFormState(_currentModel));
  }

  void _onTemplateSelected(
      EmailTemplateSelected event, Emitter<EmailState> emit) {
    _currentModel = _currentModel.copyWith(templateId: event.templateId);
    emit(EmailFormState(_currentModel));
  }

  Future<void> _onGenerateRequested(
      EmailGenerateRequested event, Emitter<EmailState> emit) async {
    emit(const EmailLoading());

    // Build fallback email body locally (used if backend fails or is unavailable)
    final fallbackBody = _buildFallbackBody(event.model);

    try {
      // ── Attempt backend save (graceful on failure) ────────────────────────
      final result = await _repository.createEmail(event.model);

      await result.fold(
        (failure) async {
          // Backend failed — still generate PDF locally
          print('[EmailBloc] Backend failed: ${failure.message}. Generating PDF locally.');
          final pdfBytes =
              await _pdfGenerator.generatePdf(event.model, fallbackBody);
          emit(EmailSuccess(
            pdfBytes: pdfBytes,
            generatedBody: fallbackBody,
            model: event.model,
          ));
          // Reload history (may return empty if backend is down)
          add(const EmailHistoryRequested());
        },
        (savedEmail) async {
          // Backend succeeded — use backend body if available, else fallback
          final bodyText =
              savedEmail.body.isNotEmpty ? savedEmail.body : fallbackBody;

          final pdfBytes =
              await _pdfGenerator.generatePdf(event.model, bodyText);

          emit(EmailSuccess(
            savedEmail: savedEmail,
            pdfBytes: pdfBytes,
            generatedBody: bodyText,
            model: event.model,
          ));

          // Instant counter sync
          add(const EmailHistoryRequested());
        },
      );
    } catch (e) {
      // Absolute fallback — generate PDF locally even on unexpected errors
      print('[EmailBloc] Unexpected error: $e. Generating PDF locally.');
      try {
        final pdfBytes =
            await _pdfGenerator.generatePdf(event.model, fallbackBody);
        emit(EmailSuccess(
          pdfBytes: pdfBytes,
          generatedBody: fallbackBody,
          model: event.model,
        ));
      } catch (pdfError) {
        emit(EmailFailure(pdfError.toString()));
      }
    }
  }

  Future<void> _onDownloadRequested(
      EmailDownloadRequested event, Emitter<EmailState> emit) async {
    emit(const EmailDownloadLoading());
    try {
      final savedPath = await DownloadService.downloadAndSaveFile(
        existingBytes: event.pdfBytes,
        baseFileName: 'ProfessionalEmail',
        fileExtension: 'pdf',
        subDirectory: 'Professional Email',
      );
      emit(EmailDownloadSuccess(savedPath));
    } catch (e) {
      emit(EmailFailure(e.toString()));
    }
  }

  Future<void> _onHistoryRequested(
      EmailHistoryRequested event, Emitter<EmailState> emit) async {
    // Do NOT emit loading here — it would disrupt the output screen state.
    // Silently fetch and update history.
    try {
      final result = await _repository.getEmailHistory();
      result.fold(
        (failure) {
          print('[EmailBloc] History fetch failed: ${failure.message}');
          // Don't emit failure — just log it. History is optional.
        },
        (history) => emit(EmailSuccess(history: history)),
      );
    } catch (e) {
      print('[EmailBloc] History fetch error: $e');
    }
  }

  Future<void> _onDeleteRequested(
      EmailDeleteRequested event, Emitter<EmailState> emit) async {
    emit(const EmailLoading());
    final result = await _repository.deleteEmail(event.id);
    await result.fold(
      (failure) async => emit(EmailFailure(failure.message)),
      (_) async {
        emit(const EmailDeleteSuccess());
        // Re-fetch history
        add(const EmailHistoryRequested());
      },
    );
  }

  // ── Fallback Email Body Generator ─────────────────────────────────────────

  String _buildFallbackBody(EmailModel email) {
    final typeContext = _getTypeContext(email.emailType);
    final keyPointsPara = email.keyPoints?.isNotEmpty == true
        ? '\n\nKey points I would like to highlight: ${email.keyPoints}'
        : '';
    final requestPara = email.specificRequest?.isNotEmpty == true
        ? '\n\n${email.specificRequest}'
        : '';
    final deadlinePara = email.deadline?.isNotEmpty == true
        ? '\n\nI would appreciate a response by ${email.deadline}.'
        : '';

    return '''$typeContext

I am reaching out to you at ${email.companyName} regarding ${email.subject}. ${email.senderDesignation != null ? 'As a ${email.senderDesignation}${email.senderCompany != null ? ' at ${email.senderCompany}' : ''}, I' : 'I'} believe this communication will be of mutual benefit.$keyPointsPara$requestPara$deadlinePara

I am available for a meeting or call at your earliest convenience and look forward to the opportunity to discuss this further.

Thank you for your time and consideration.''';
  }

  String _getTypeContext(String emailType) {
    switch (emailType) {
      case 'Job Application Email':
        return 'I am writing to express my strong interest in joining your esteemed organization and to submit my application for a suitable position.';
      case 'Internship Request':
        return 'I am writing to inquire about internship opportunities at your organization, as I am eager to gain practical experience in a professional environment.';
      case 'Business Proposal':
        return 'I am pleased to present a business proposal that I believe offers significant mutual value and opportunity for collaboration.';
      case 'Follow-up Email':
        return 'I am following up on our previous communication and wanted to reiterate my interest and enthusiasm regarding the matter discussed.';
      case 'Thank You Email':
        return 'I am writing to express my sincere gratitude for your time, consideration, and the opportunity you have extended to me.';
      case 'Networking Email':
        return 'I am reaching out to connect and explore potential opportunities for professional collaboration and knowledge sharing.';
      case 'Resignation Letter':
        return 'I am writing to formally notify you of my decision to resign from my current position, effective from a mutually agreed-upon date.';
      case 'Recommendation Request':
        return 'I am writing to respectfully request a letter of recommendation, which I believe you are best positioned to provide given our professional relationship.';
      case 'Cold Outreach':
        return 'I am reaching out as I have followed your work closely and believe there is a compelling opportunity for us to connect and collaborate.';
      case 'Client Communication':
        return 'I am writing to provide an update and ensure we remain aligned on the objectives and progress of our ongoing collaboration.';
      default:
        return 'I am writing to communicate an important matter that I believe warrants your attention and consideration.';
    }
  }
}
