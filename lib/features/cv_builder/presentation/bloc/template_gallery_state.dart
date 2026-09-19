part of 'template_gallery_bloc.dart';

abstract class TemplateGalleryState {
  final String selectedFilter;
  final List<dynamic> templates;
  final bool isLoading;
  
  const TemplateGalleryState({
    this.selectedFilter = 'All Templates',
    this.templates = const [],
    this.isLoading = false,
  });
}

class TemplateGalleryInitial extends TemplateGalleryState {
  const TemplateGalleryInitial({
    super.selectedFilter,
    super.templates,
    super.isLoading,
  });
}

class TemplateAllowed extends TemplateGalleryState {
  final String templateTitle;
  final String templateId;
  const TemplateAllowed({
    super.selectedFilter, 
    super.templates,
    required this.templateTitle, 
    required this.templateId
  });
}

class TemplateBlocked extends TemplateGalleryState {
  const TemplateBlocked({super.selectedFilter, super.templates});
}

class TemplateError extends TemplateGalleryState {
  final String message;
  const TemplateError({super.selectedFilter, super.templates, required this.message});
}
