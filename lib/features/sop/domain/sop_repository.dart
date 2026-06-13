import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import 'sop_model.dart';

abstract class SopRepository {
  Future<Either<Failure, String>> generateSop(SopModel data);
  Future<Either<Failure, List<SopModel>>> getSopHistory();
}
