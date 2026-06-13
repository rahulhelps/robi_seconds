import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../../../core/services/download_service.dart';

abstract class DownloadEvent extends Equatable {
  const DownloadEvent();
  @override
  List<Object?> get props => [];
}

class StartDownload extends DownloadEvent {
  final Uint8List? existingBytes;
  final String? networkUrl;
  final String? bearerToken;

  const StartDownload({this.existingBytes, this.networkUrl, this.bearerToken});
}

abstract class DownloadState extends Equatable {
  const DownloadState();
  @override
  List<Object?> get props => [];
}

class DownloadInitial extends DownloadState {}

class DownloadLoading extends DownloadState {}

class DownloadSuccess extends DownloadState {
  final String path;
  const DownloadSuccess(this.path);
  @override
  List<Object?> get props => [path];
}

class DownloadError extends DownloadState {
  final String message;
  const DownloadError(this.message);
  @override
  List<Object?> get props => [message];
}

class DownloadBloc extends Bloc<DownloadEvent, DownloadState> {
  DownloadBloc() : super(DownloadInitial()) {
    on<StartDownload>(_onStartDownload);
  }

  Future<void> _onStartDownload(StartDownload event, Emitter<DownloadState> emit) async {
    emit(DownloadLoading());

    try {
      final path = await DownloadService.downloadAndSaveFile(
        url: event.networkUrl,
        existingBytes: event.existingBytes,
        baseFileName: 'QuickCV_2026',
        fileExtension: 'pdf',
        bearerToken: event.bearerToken,
      );

      // 5. Emit Success
      emit(DownloadSuccess(path));

    } catch (e) {
      print("Download error: $e");
      emit(DownloadError('Failed to save file: ${e.toString()}'));
    }
  }
}
