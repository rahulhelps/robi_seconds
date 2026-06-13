part of 'template_gallery_bloc.dart';

abstract class TemplateGalleryEvent {}

class TemplateFilterChanged extends TemplateGalleryEvent {
  final String filter;
  TemplateFilterChanged(this.filter);
}

class SelectTemplate extends TemplateGalleryEvent {
  final String title;
  final bool isPremium;
  final int templateId; // 1-based index (1–5)
  SelectTemplate({required this.title, required this.isPremium, required this.templateId});
}

class CheckAccess extends TemplateGalleryEvent {
  final bool isPremium;
  CheckAccess(this.isPremium);
}
