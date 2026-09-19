import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/secure_storage_helper.dart';
import '../../../../core/services/backend_service.dart';

part 'template_gallery_event.dart';
part 'template_gallery_state.dart';

class TemplateGalleryBloc extends Bloc<TemplateGalleryEvent, TemplateGalleryState> {
  final BackendService backendService;

  TemplateGalleryBloc({required this.backendService}) : super(const TemplateGalleryInitial()) {
    on<LoadTemplates>(_onLoadTemplates);
    on<TemplateFilterChanged>(_onFilterChanged);
    on<SelectTemplate>(_onSelectTemplate);
    on<CheckAccess>(_onCheckAccess);
  }

  Future<void> _onLoadTemplates(
    LoadTemplates event,
    Emitter<TemplateGalleryState> emit,
  ) async {
    emit(TemplateGalleryInitial(
      selectedFilter: state.selectedFilter,
      templates: state.templates,
      isLoading: true,
    ));

    final templates = await backendService.getTemplates();

    emit(TemplateGalleryInitial(
      selectedFilter: state.selectedFilter,
      templates: templates,
      isLoading: false,
    ));
  }

  void _onFilterChanged(
    TemplateFilterChanged event,
    Emitter<TemplateGalleryState> emit,
  ) {
    emit(TemplateGalleryInitial(
      selectedFilter: event.filter,
      templates: state.templates,
    ));
  }

  Future<void> _onSelectTemplate(
    SelectTemplate event,
    Emitter<TemplateGalleryState> emit,
  ) async {
    if (!event.isPremium) {
      emit(TemplateAllowed(
        selectedFilter: state.selectedFilter,
        templates: state.templates,
        templateTitle: event.title,
        templateId: event.templateId,
      ));
      return;
    }

    final isPremiumActive = await SecureStorageHelper.getSubscriptionStatus();
    if (isPremiumActive) {
      emit(TemplateAllowed(
        selectedFilter: state.selectedFilter,
        templates: state.templates,
        templateTitle: event.title,
        templateId: event.templateId,
      ));
    } else {
      emit(TemplateBlocked(
        selectedFilter: state.selectedFilter,
        templates: state.templates,
      ));
    }
  }

  Future<void> _onCheckAccess(
    CheckAccess event,
    Emitter<TemplateGalleryState> emit,
  ) async {
    if (!event.isPremium) {
      return;
    }
    
    final isPremiumActive = await SecureStorageHelper.getSubscriptionStatus();
    if (!isPremiumActive) {
      emit(TemplateBlocked(
        selectedFilter: state.selectedFilter,
        templates: state.templates,
      ));
    }
  }
}
