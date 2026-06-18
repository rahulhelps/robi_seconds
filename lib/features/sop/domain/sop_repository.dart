import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import 'sop_model.dart';

abstract class SopRepository {
  Future<Either<Failure, SavedSop>> createSop(SopModel data);
  Future<Either<Failure, List<SavedSop>>> getSopHistory();
  Future<Either<Failure, SavedSop>> getSopDetails(String id);
  Future<Either<Failure, void>> deleteSop(String id);
}
