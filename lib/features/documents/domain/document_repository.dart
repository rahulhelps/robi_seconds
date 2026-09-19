import '../data/documents_datasource.dart';
import '../domain/document_model.dart';

class DocumentRepository {
  final DocumentsDatasource _datasource;

  DocumentRepository(this._datasource);

  Future<List<DocumentModel>> fetchDocuments({
    DocumentType? type,
    DocumentStatus? status,
  }) {
    return _datasource.fetchDocuments(type: type, status: status);
  }

  Future<DocumentModel> createDocument(CreateDocumentRequest request) {
    return _datasource.createDocument(request);
  }

  Future<DocumentModel> updateDocument(String id, Map<String, dynamic> updates) {
    return _datasource.updateDocument(id, updates);
  }

  Future<void> deleteDocument(String id) {
    return _datasource.deleteDocument(id);
  }
}
