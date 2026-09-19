import '../../../../core/services/auth_service.dart';
import '../domain/document_model.dart';

class DocumentsDatasource {
  Future<List<DocumentModel>> fetchDocuments({
    DocumentType? type,
    DocumentStatus? status,
  }) async {
    final queryParams = <String, String>{};
    if (type != null) queryParams['type'] = type.apiValue;
    if (status != null) queryParams['status'] = status.apiValue;

    final uri = Uri(
      path: '/documents',
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );

    final responseMap = await AuthService.authenticatedGet(uri.toString());

    final rawData = responseMap['data'];
    if (rawData is! List) {
      return [];
    }

    return rawData
        .whereType<Map<String, dynamic>>()
        .map(DocumentModel.fromJson)
        .toList();
  }

  Future<DocumentModel> createDocument(CreateDocumentRequest request) async {
    final responseMap = await AuthService.authenticatedPost(
      '/documents',
      request.toJson(),
    );

    final success = responseMap['success'] == true;
    final data = responseMap['data'] as Map<String, dynamic>?;

    if (success && data != null) {
      return DocumentModel.fromJson(data);
    }

    throw responseMap['message']?.toString() ?? 'Failed to create document';
  }

  Future<DocumentModel> updateDocument(String id, Map<String, dynamic> updates) async {
    final responseMap = await AuthService.authenticatedPatch(
      '/documents/$id',
      updates,
    );

    final data = responseMap['data'] as Map<String, dynamic>?;
    if (data != null) {
      return DocumentModel.fromJson(data);
    }

    throw responseMap['message']?.toString() ?? 'Failed to update document';
  }

  Future<void> deleteDocument(String id) async {
    await AuthService.authenticatedDelete('/documents/$id');
  }
}
