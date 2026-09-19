import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:email_validator/email_validator.dart';
import '../../domain/cv_model.dart';
import '../../domain/cv_repository.dart';
import '../../domain/cv_list_item.dart';
import '../../domain/cv_validators.dart';
import '../../../../core/services/backend_service.dart';

// ── Events ───────────────────────────────────────────────────────────────────

abstract class CvEvent {
  const CvEvent();
}

/// Triggers GET /cvs to load the list.
class FetchCVs extends CvEvent {
  const FetchCVs();
}

/// Triggers DELETE /cvs/{id}.
class DeleteCv extends CvEvent {
  final String id;
  const DeleteCv(this.id);
}

/// Triggers POST /cvs/generate.
class GenerateCV extends CvEvent {
  const GenerateCV();
}

/// Triggers POST /cvs/ai-generate.
class GenerateCvWithAi extends CvEvent {
  final String jobTitle;
  final String industry;
  final String experienceLevel;
  final int yearsOfExperience;
  final List<String> keySkills;
  final String educationLevel;
  final String additionalDetails;
  final String? templateId;

  const GenerateCvWithAi({
    required this.jobTitle,
    required this.industry,
    required this.experienceLevel,
    required this.yearsOfExperience,
    required this.keySkills,
    required this.educationLevel,
    required this.additionalDetails,
    this.templateId,
  });
}

// ── Form Events (Migrated from CvBuilderBloc) ────────────────────────────────

class CvSetTemplateId extends CvEvent {
  final String templateId;
  const CvSetTemplateId(this.templateId);
}

class CvUpdateCareerObjective extends CvEvent {
  final String value;
  const CvUpdateCareerObjective(this.value);
}

class CvUpdatePersonalInfo extends CvEvent {
  final String field;
  final String value;
  const CvUpdatePersonalInfo(this.field, this.value);
}

class CvUpdatePersonalProfile extends CvEvent {
  final String field;
  final String value;
  const CvUpdatePersonalProfile(this.field, this.value);
}

class CvAddEducation extends CvEvent {
  const CvAddEducation();
}

class CvRemoveEducation extends CvEvent {
  final int index;
  const CvRemoveEducation(this.index);
}

class CvUpdateEducation extends CvEvent {
  final int index;
  final String field;
  final String value;
  const CvUpdateEducation(this.index, this.field, this.value);
}

class CvAddSkillCategory extends CvEvent {
  const CvAddSkillCategory();
}

class CvRemoveSkillCategory extends CvEvent {
  final int index;
  const CvRemoveSkillCategory(this.index);
}

class CvUpdateSkillCategory extends CvEvent {
  final int index;
  final String field;
  final String value;
  const CvUpdateSkillCategory(this.index, this.field, this.value);
}

class CvAddExperience extends CvEvent {
  const CvAddExperience();
}

class CvRemoveExperience extends CvEvent {
  final int index;
  const CvRemoveExperience(this.index);
}

class CvUpdateExperience extends CvEvent {
  final int index;
  final String field;
  final String value;
  const CvUpdateExperience(this.index, this.field, this.value);
}

class CvAddLanguage extends CvEvent {
  const CvAddLanguage();
}

class CvRemoveLanguage extends CvEvent {
  final int index;
  const CvRemoveLanguage(this.index);
}

class CvUpdateLanguage extends CvEvent {
  final int index;
  final String field;
  final String value;
  const CvUpdateLanguage(this.index, this.field, this.value);
}

class CvLoadModel extends CvEvent {
  final CvModel model;
  const CvLoadModel(this.model);
}

// ── States ───────────────────────────────────────────────────────────────────

abstract class CvState {
  final CvModel model;
  final bool showErrors;
  const CvState(this.model, {this.showErrors = false});

  CvState copyWith({CvModel? model, bool? showErrors});
}

/// Form is being filled or list has not been fetched yet.
class CvInitial extends CvState {
  const CvInitial(super.model, {super.showErrors});

  @override
  CvInitial copyWith({CvModel? model, bool? showErrors}) =>
      CvInitial(model ?? this.model, showErrors: showErrors ?? this.showErrors);
}

/// API call in progress (Generation or Fetching).
class CvLoading extends CvState {
  const CvLoading(super.model, {super.showErrors});

  @override
  CvLoading copyWith({CvModel? model, bool? showErrors}) =>
      CvLoading(model ?? this.model, showErrors: showErrors ?? this.showErrors);
}

/// List of CVs loaded successfully. [cvId] is set if just generated.
class CvLoaded extends CvState {
  final List<CvListItem> items;
  final String? cvId;
  final String? token;
  
  const CvLoaded(super.model, this.items, {this.cvId, this.token, super.showErrors});

  @override
  CvLoaded copyWith({CvModel? model, bool? showErrors, List<CvListItem>? items, String? cvId, String? token}) =>
      CvLoaded(
        model ?? this.model,
        items ?? this.items,
        cvId: cvId ?? this.cvId,
        token: token ?? this.token,
        showErrors: showErrors ?? this.showErrors,
      );
}

/// Error state.
class CvError extends CvState {
  final String message;
  const CvError(super.model, this.message, {super.showErrors});

  @override
  CvError copyWith({CvModel? model, bool? showErrors, String? message}) =>
      CvError(
        model ?? this.model,
        message ?? this.message,
        showErrors: showErrors ?? this.showErrors,
      );
}

// ── BLoC ────────────────────────────────────────────────────────────────────

class CvBloc extends Bloc<CvEvent, CvState> {
  final CvRepository _repository;

  CvBloc(this._repository)
      : super(
          const CvInitial(
            CvModel(),
          ),
        ) {
    // API Events
    on<FetchCVs>(_onFetchCVs);
    on<DeleteCv>(_onDeleteCv);
    on<GenerateCV>(_onGenerateCV);
    on<GenerateCvWithAi>(_onGenerateCvWithAi);

    // Form Events
    on<CvSetTemplateId>((e, emit) => emit(CvInitial(state.model.copyWith(templateId: e.templateId), showErrors: state.showErrors)));
    on<CvUpdateCareerObjective>((e, emit) => emit(CvInitial(state.model.copyWith(careerObjective: e.value), showErrors: state.showErrors)));
    on<CvUpdatePersonalInfo>(_onUpdatePersonalInfo);
    on<CvUpdatePersonalProfile>(_onUpdatePersonalProfile);
    on<CvAddEducation>(_onAddEducation);
    on<CvRemoveEducation>(_onRemoveEducation);
    on<CvUpdateEducation>(_onUpdateEducation);
    on<CvAddSkillCategory>(_onAddSkillCategory);
    on<CvRemoveSkillCategory>(_onRemoveSkillCategory);
    on<CvUpdateSkillCategory>(_onUpdateSkillCategory);
    on<CvAddExperience>(_onAddExperience);
    on<CvRemoveExperience>(_onRemoveExperience);
    on<CvUpdateExperience>(_onUpdateExperience);
    on<CvAddLanguage>(_onAddLanguage);
    on<CvRemoveLanguage>(_onRemoveLanguage);
    on<CvUpdateLanguage>(_onUpdateLanguage);
    on<CvLoadModel>((e, emit) => emit(CvInitial(e.model, showErrors: false)));
  }

  // ── API Handlers ──────────────────────────────────────────────────────────

  Future<void> _onFetchCVs(FetchCVs e, Emitter<CvState> emit) async {
    emit(CvLoading(state.model));
    try {
      final items = await _repository.fetchCvList();
      final token = await _repository.getAccessToken() ?? '';
      debugPrint('[CVBloc] Token for PDF viewer: $token');
      emit(CvLoaded(state.model, items, token: token));
    } catch (err) {
      debugPrint('[CVBloc] Fetch error: $err');
      emit(CvError(state.model, _friendlyError(err.toString())));
    }
  }

  Future<void> _onDeleteCv(DeleteCv e, Emitter<CvState> emit) async {
    emit(CvLoading(state.model));
    try {
      await _repository.deleteCv(e.id);
      final items = await _repository.fetchCvList();
      final token = await _repository.getAccessToken() ?? '';
      emit(CvLoaded(state.model, items, token: token));
    } catch (err) {
      debugPrint('[CVBloc] Delete error: $err');
      emit(CvError(state.model, _friendlyError(err.toString())));
    }
  }

  Future<void> _onGenerateCV(GenerateCV e, Emitter<CvState> emit) async {
    emit(state.copyWith(showErrors: true));
    final model = state.model;
    
    // 1. Validate
    final validationError = _validate(model);
    if (validationError != null) {
      emit(CvError(model, validationError, showErrors: true));
      return;
    }

    emit(CvLoading(model));
    try {
      final sanitised = _sanitise(model);
      final cvId = await _repository.generateCv(sanitised);
      final token = await _repository.getAccessToken() ?? '';
      
      // Upload CV snapshot for backup to Laravel Backend
      BackendService().uploadCvSnapshot(sanitised.toJson()).then((success) {
        if (success) {
          debugPrint('[CVBloc] Successfully backed up CV snapshot to backend.');
        } else {
          debugPrint('[CVBloc] Failed to back up CV snapshot.');
        }
      });
      
      // Immediately refresh the list after successful generation
      final items = await _repository.fetchCvList();
      
      emit(CvLoaded(model, items, cvId: cvId, token: token));
    } catch (err) {
      debugPrint('[CVBloc] Generation error: $err');
      emit(CvError(model, _friendlyError(err.toString())));
    }
  }

  Future<void> _onGenerateCvWithAi(GenerateCvWithAi e, Emitter<CvState> emit) async {
    emit(CvLoading(state.model));
    try {
      final result = await _repository.generateCvWithAi(
        jobTitle: e.jobTitle,
        industry: e.industry,
        experienceLevel: e.experienceLevel,
        yearsOfExperience: e.yearsOfExperience,
        keySkills: e.keySkills,
        educationLevel: e.educationLevel,
        additionalDetails: e.additionalDetails,
        templateId: e.templateId,
      );

      final cvId = result['cvId'] as String;
      final token = await _repository.getAccessToken() ?? '';
      final items = await _repository.fetchCvList();

      emit(CvLoaded(state.model, items, cvId: cvId, token: token));
    } catch (err) {
      debugPrint('[CVBloc] AI generation error: $err');
      emit(CvError(state.model, _friendlyError(err.toString())));
    }
  }

  // ── Form Handlers ─────────────────────────────────────────────────────────

  void _onUpdatePersonalInfo(CvUpdatePersonalInfo e, Emitter<CvState> emit) {
    final pi = state.model.personalInfo;
    final updated = switch (e.field) {
      'name'    => pi.copyWith(name: e.value),
      'email'   => pi.copyWith(email: e.value),
      'phone'   => pi.copyWith(phone: e.value),
      'address' => pi.copyWith(address: e.value),
      _ => pi,
    };
    emit(CvInitial(state.model.copyWith(personalInfo: updated), showErrors: state.showErrors));
  }

  void _onUpdatePersonalProfile(CvUpdatePersonalProfile e, Emitter<CvState> emit) {
    final p = state.model.personalProfile;
    final updated = switch (e.field) {
      'fatherName' => p.copyWith(fatherName: e.value),
      'dateOfBirth' => p.copyWith(dateOfBirth: e.value),
      'nationality' => p.copyWith(nationality: e.value),
      'maritalStatus' => p.copyWith(maritalStatus: e.value),
      'gender' => p.copyWith(gender: e.value),
      'strength' => p.copyWith(strength: e.value),
      'hobbies' => p.copyWith(hobbies: e.value),
      _ => p,
    };
    emit(CvInitial(state.model.copyWith(personalProfile: updated), showErrors: state.showErrors));
  }

  void _onAddEducation(CvAddEducation e, Emitter<CvState> emit) {
    final list = List<Education>.from(state.model.education)..add(const Education());
    emit(CvInitial(state.model.copyWith(education: list), showErrors: state.showErrors));
  }

  void _onRemoveEducation(CvRemoveEducation e, Emitter<CvState> emit) {
    final list = List<Education>.from(state.model.education)..removeAt(e.index);
    emit(CvInitial(state.model.copyWith(education: list), showErrors: state.showErrors));
  }

  void _onUpdateEducation(CvUpdateEducation e, Emitter<CvState> emit) {
    final list = List<Education>.from(state.model.education);
    final item = list[e.index];
    list[e.index] = switch (e.field) {
      'institution' => item.copyWith(institution: e.value),
      'degree' => item.copyWith(degree: e.value),
      'fieldOfStudy' => item.copyWith(fieldOfStudy: e.value),
      'startDate' => item.copyWith(startDate: e.value),
      'endDate' => item.copyWith(endDate: e.value, passingYear: e.value),
      'board' => item.copyWith(board: e.value),
      'passingYear' => item.copyWith(passingYear: e.value, endDate: e.value),
      'result' => item.copyWith(result: e.value),
      _ => item,
    };
    emit(CvInitial(state.model.copyWith(education: list), showErrors: state.showErrors));
  }

  void _onAddSkillCategory(CvAddSkillCategory e, Emitter<CvState> emit) {
    final list = List<SkillCategory>.from(state.model.skills)..add(const SkillCategory());
    emit(CvInitial(state.model.copyWith(skills: list), showErrors: state.showErrors));
  }

  void _onRemoveSkillCategory(CvRemoveSkillCategory e, Emitter<CvState> emit) {
    final list = List<SkillCategory>.from(state.model.skills)..removeAt(e.index);
    emit(CvInitial(state.model.copyWith(skills: list), showErrors: state.showErrors));
  }

  void _onUpdateSkillCategory(CvUpdateSkillCategory e, Emitter<CvState> emit) {
    final list = List<SkillCategory>.from(state.model.skills);
    final item = list[e.index];
    list[e.index] = switch (e.field) {
      'category' => item.copyWith(category: e.value),
      'skills' => item.copyWith(skills: e.value.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList()),
      _ => item,
    };
    emit(CvInitial(state.model.copyWith(skills: list), showErrors: state.showErrors));
  }

  void _onAddExperience(CvAddExperience e, Emitter<CvState> emit) {
    final list = List<WorkExperience>.from(state.model.workExperience)..add(const WorkExperience());
    emit(CvInitial(state.model.copyWith(workExperience: list), showErrors: state.showErrors));
  }

  void _onRemoveExperience(CvRemoveExperience e, Emitter<CvState> emit) {
    final list = List<WorkExperience>.from(state.model.workExperience)..removeAt(e.index);
    emit(CvInitial(state.model.copyWith(workExperience: list), showErrors: state.showErrors));
  }

  void _onUpdateExperience(CvUpdateExperience e, Emitter<CvState> emit) {
    final list = List<WorkExperience>.from(state.model.workExperience);
    final item = list[e.index];
    list[e.index] = switch (e.field) {
      'company' => item.copyWith(company: e.value),
      'position' => item.copyWith(position: e.value),
      'startDate' => item.copyWith(startDate: e.value),
      'endDate' => item.copyWith(endDate: e.value),
      'description' => item.copyWith(description: e.value),
      'bullets' => item.copyWith(bullets: e.value.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList()),
      _ => item,
    };
    emit(CvInitial(state.model.copyWith(workExperience: list), showErrors: state.showErrors));
  }

  void _onAddLanguage(CvAddLanguage e, Emitter<CvState> emit) {
    final list = List<Language>.from(state.model.languages)..add(const Language(proficiency: 'Beginner'));
    emit(CvInitial(state.model.copyWith(languages: list), showErrors: state.showErrors));
  }

  void _onRemoveLanguage(CvRemoveLanguage e, Emitter<CvState> emit) {
    final list = List<Language>.from(state.model.languages)..removeAt(e.index);
    emit(CvInitial(state.model.copyWith(languages: list), showErrors: state.showErrors));
  }

  void _onUpdateLanguage(CvUpdateLanguage e, Emitter<CvState> emit) {
    final list = List<Language>.from(state.model.languages);
    final item = list[e.index];
    list[e.index] = switch (e.field) {
      'language' => item.copyWith(language: e.value),
      'proficiency' => item.copyWith(proficiency: e.value),
      _ => item,
    };
    emit(CvInitial(state.model.copyWith(languages: list), showErrors: state.showErrors));
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String? _validate(CvModel cv) {
    final missing = <String>[];

    if (cv.templateId.trim().isEmpty) missing.add('Template');
    if (cv.careerObjective.trim().isEmpty) missing.add('Career Objective');
    if (cv.personalInfo.name.trim().isEmpty) missing.add('Full Name');

    final email = cv.personalInfo.email.trim();
    if (email.isEmpty) {
      missing.add('Email');
    } else if (!EmailValidator.validate(email)) {
      return 'Please enter a valid email address (e.g. name@example.com)';
    }

    final phone = cv.personalInfo.phone.trim();
    if (phone.isEmpty) {
      missing.add('Phone Number');
    } else if (!CvValidators.isValidPhone(phone)) {
      return 'Please enter a valid phone number (e.g. +880 17XXXXXXXX)';
    }

    if (cv.education.isEmpty) {
      missing.add('Education (at least 1 entry)');
    } else {
      for (var edu in cv.education) {
        if (edu.degree.trim().isEmpty) missing.add('Education Level');
        if (edu.institution.trim().isEmpty) missing.add('Education Institution');
        if (edu.board.trim().isEmpty) missing.add('Education Board');
        if (edu.endDate.trim().isEmpty && edu.passingYear.trim().isEmpty) missing.add('Passing Year');
      }
    }

    if (cv.skills.isEmpty) {
      missing.add('Skills');
    } else {
      for (var skill in cv.skills) {
        if (skill.category.trim().isEmpty) missing.add('Skill Category');
        if (skill.skills.isEmpty) missing.add('Skill Items');
      }
    }

    if (missing.isEmpty) return null;
    return 'Missing: ${missing.join(', ')}';
  }

  CvModel _sanitise(CvModel cv) {
    return cv.copyWith(
      templateId: cv.templateId.trim(),
      careerObjective: cv.careerObjective.trim(),
      personalInfo: cv.personalInfo.copyWith(
        name: cv.personalInfo.name.trim(),
        email: cv.personalInfo.email.trim(),
        phone: cv.personalInfo.phone.trim(),
        address: cv.personalInfo.address.trim(),
      ),
      personalProfile: cv.personalProfile.copyWith(
        fatherName: cv.personalProfile.fatherName.trim(),
        dateOfBirth: cv.personalProfile.dateOfBirth.trim(),
        nationality: cv.personalProfile.nationality.trim(),
        maritalStatus: cv.personalProfile.maritalStatus.trim(),
        gender: cv.personalProfile.gender.trim(),
        strength: cv.personalProfile.strength.trim(),
        hobbies: cv.personalProfile.hobbies.trim(),
      ),
      education: cv.education.map((e) => e.copyWith(
        institution: e.institution.trim(),
        degree: e.degree.trim(),
        fieldOfStudy: e.fieldOfStudy.trim(),
        startDate: e.startDate.trim(),
        endDate: e.endDate.trim().isNotEmpty ? e.endDate.trim() : e.passingYear.trim(),
        board: e.board.trim(),
        passingYear: e.passingYear.trim().isNotEmpty ? e.passingYear.trim() : e.endDate.trim(),
        result: e.result.trim(),
      )).toList(),
      skills: cv.skills.map((s) => s.copyWith(
        category: s.category.trim(),
        skills: s.skills.map((str) => str.trim()).where((str) => str.isNotEmpty).toList(),
      )).toList(),
      workExperience: cv.workExperience.map((w) => w.copyWith(
        company: w.company.trim(),
        position: w.position.trim(),
        startDate: w.startDate.trim(),
        endDate: w.endDate.trim(),
        description: w.description.trim(),
        bullets: w.bullets.map((str) => str.trim()).where((str) => str.isNotEmpty).toList(),
      )).toList(),
      languages: cv.languages.map((l) => l.copyWith(
        language: l.language.trim(),
        proficiency: l.proficiency.trim(),
      )).toList(),
    );
  }

  String _friendlyError(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('socket') || lower.contains('connection')) return 'No internet connection.';
    if (lower.contains('401') || lower.contains('unauthorized')) return 'Session expired. Please log in again.';
    return raw;
  }
}
