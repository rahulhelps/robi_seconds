import '../../../../core/services/backend_service.dart';
import 'job_portal_model.dart';

class JobPortalDataSource {
  final BackendService _backendService = BackendService();

  Future<List<JobPortal>> getJobPortals({String? category}) async {
    try {
      final rawList = await _backendService.getJobPortals(category: category);
      if (rawList.isNotEmpty) {
        return rawList.map((item) => JobPortal.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      // Fallback below
    }

    // Return fallback list if API is unreachable or empty
    if (category == null || category.isEmpty || category == 'all') {
      return defaultJobPortals;
    }
    return defaultJobPortals.where((portal) => portal.category == category).toList();
  }
}
