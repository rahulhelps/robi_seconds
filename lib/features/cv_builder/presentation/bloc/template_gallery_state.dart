part of 'template_gallery_bloc.dart';

abstract class TemplateGalleryState {
  final String selectedFilter;
  const TemplateGalleryState({this.selectedFilter = 'All Templates'});
}

class TemplateGalleryInitial extends TemplateGalleryState {
  const TemplateGalleryInitial({super.selectedFilter});
}

class TemplateAllowed extends TemplateGalleryState {
  final String templateTitle;
  final int templateId;
  const TemplateAllowed({super.selectedFilter, required this.templateTitle, required this.templateId});
}

class TemplateBlocked extends TemplateGalleryState {
  const TemplateBlocked({super.selectedFilter});
}

class TemplateError extends TemplateGalleryState {
  final String message;
  const TemplateError({super.selectedFilter, required this.message});
}
