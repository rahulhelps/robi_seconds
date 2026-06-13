import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/secure_storage_helper.dart';

part 'template_gallery_event.dart';
part 'template_gallery_state.dart';

class TemplateGalleryBloc extends Bloc<TemplateGalleryEvent, TemplateGalleryState> {
  TemplateGalleryBloc() : super(const TemplateGalleryInitial()) {
    on<TemplateFilterChanged>(_onFilterChanged);
    on<SelectTemplate>(_onSelectTemplate);
    on<CheckAccess>(_onCheckAccess);
  }

  void _onFilterChanged(
    TemplateFilterChanged event,
    Emitter<TemplateGalleryState> emit,
  ) {
    emit(TemplateGalleryInitial(selectedFilter: event.filter));
  }

  Future<void> _onSelectTemplate(
    SelectTemplate event,
    Emitter<TemplateGalleryState> emit,
  ) async {
    if (!event.isPremium) {
      emit(TemplateAllowed(
        selectedFilter: state.selectedFilter,
        templateTitle: event.title,
        templateId: event.templateId,
      ));
      return;
    }

    final isPremiumActive = await SecureStorageHelper.getSubscriptionStatus();
    if (isPremiumActive) {
      emit(TemplateAllowed(
        selectedFilter: state.selectedFilter,
        templateTitle: event.title,
        templateId: event.templateId,
      ));
    } else {
      emit(TemplateBlocked(selectedFilter: state.selectedFilter));
    }
  }

  Future<void> _onCheckAccess(
    CheckAccess event,
    Emitter<TemplateGalleryState> emit,
  ) async {
    if (!event.isPremium) {
      // Free template
      return;
    }
    
    final isPremiumActive = await SecureStorageHelper.getSubscriptionStatus();
    if (!isPremiumActive) {
      emit(TemplateBlocked(selectedFilter: state.selectedFilter));
    }
  }
}
