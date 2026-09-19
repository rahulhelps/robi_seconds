import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/document_model.dart';
import '../../domain/document_repository.dart';

abstract class DocumentsEvent extends Equatable {
  const DocumentsEvent();

  @override
  List<Object?> get props => [];
}

final class DocumentsFetchRequested extends DocumentsEvent {
  final DocumentType? type;
  final DocumentStatus? status;

  const DocumentsFetchRequested({this.type, this.status});

  @override
  List<Object?> get props => [type, status];
}

final class DocumentsCreateRequested extends DocumentsEvent {
  final CreateDocumentRequest request;

  const DocumentsCreateRequested(this.request);

  @override
  List<Object?> get props => [request];
}

final class DocumentsUpdateRequested extends DocumentsEvent {
  final String id;
  final Map<String, dynamic> updates;

  const DocumentsUpdateRequested(this.id, this.updates);

  @override
  List<Object?> get props => [id, updates];
}

final class DocumentsDeleteRequested extends DocumentsEvent {
  final String id;

  const DocumentsDeleteRequested(this.id);

  @override
  List<Object?> get props => [id];
}

abstract class DocumentsState extends Equatable {
  const DocumentsState();

  @override
  List<Object?> get props => [];
}

class DocumentsInitial extends DocumentsState {}

class DocumentsLoading extends DocumentsState {}

class DocumentsLoaded extends DocumentsState {
  final List<DocumentModel> documents;

  const DocumentsLoaded({required this.documents});

  @override
  List<Object?> get props => [documents];
}

class DocumentsCreated extends DocumentsState {
  final DocumentModel document;

  const DocumentsCreated({required this.document});

  @override
  List<Object?> get props => [document];
}

class DocumentsUpdated extends DocumentsState {
  final DocumentModel document;

  const DocumentsUpdated({required this.document});

  @override
  List<Object?> get props => [document];
}

class DocumentsDeleted extends DocumentsState {}

class DocumentsError extends DocumentsState {
  final String message;

  const DocumentsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class DocumentsBloc extends Bloc<DocumentsEvent, DocumentsState> {
  final DocumentRepository repository;

  DocumentsBloc(this.repository) : super(DocumentsInitial()) {
    on<DocumentsFetchRequested>(_onFetchRequested);
    on<DocumentsCreateRequested>(_onCreateRequested);
    on<DocumentsUpdateRequested>(_onUpdateRequested);
    on<DocumentsDeleteRequested>(_onDeleteRequested);
  }

  Future<void> _onFetchRequested(
    DocumentsFetchRequested event,
    Emitter<DocumentsState> emit,
  ) async {
    emit(DocumentsLoading());
    try {
      final documents = await repository.fetchDocuments(
        type: event.type,
        status: event.status,
      );
      emit(DocumentsLoaded(documents: documents));
    } catch (e) {
      emit(DocumentsError(message: e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    DocumentsCreateRequested event,
    Emitter<DocumentsState> emit,
  ) async {
    emit(DocumentsLoading());
    try {
      final document = await repository.createDocument(event.request);
      emit(DocumentsCreated(document: document));
    } catch (e) {
      emit(DocumentsError(message: e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    DocumentsUpdateRequested event,
    Emitter<DocumentsState> emit,
  ) async {
    emit(DocumentsLoading());
    try {
      final document = await repository.updateDocument(event.id, event.updates);
      emit(DocumentsUpdated(document: document));
    } catch (e) {
      emit(DocumentsError(message: e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    DocumentsDeleteRequested event,
    Emitter<DocumentsState> emit,
  ) async {
    emit(DocumentsLoading());
    try {
      await repository.deleteDocument(event.id);
      emit(DocumentsDeleted());
    } catch (e) {
      emit(DocumentsError(message: e.toString()));
    }
  }
}
