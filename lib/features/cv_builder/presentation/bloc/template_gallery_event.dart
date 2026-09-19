part of 'template_gallery_bloc.dart';

abstract class TemplateGalleryEvent {}

class LoadTemplates extends TemplateGalleryEvent {}

class TemplateFilterChanged extends TemplateGalleryEvent {
  final String filter;
  TemplateFilterChanged(this.filter);
}

class SelectTemplate extends TemplateGalleryEvent {
  final String title;
  final bool isPremium;
  final String templateId;
  SelectTemplate({required this.title, required this.isPremium, required this.templateId});
}

class CheckAccess extends TemplateGalleryEvent {
  final bool isPremium;
  CheckAccess(this.isPremium);
}
