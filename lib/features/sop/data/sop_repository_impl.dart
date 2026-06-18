import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../domain/sop_model.dart';
import '../domain/sop_repository.dart';
import 'sop_datasource.dart';

class SopRepositoryImpl implements SopRepository {
  final SopDatasource _datasource;

  SopRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, SavedSop>> createSop(SopModel data) async {
    try {
      final result = await _datasource.createSop(data);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SavedSop>>> getSopHistory() async {
    try {
      final result = await _datasource.fetchSopHistory();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SavedSop>> getSopDetails(String id) async {
    try {
      final result = await _datasource.getSopDetails(id);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSop(String id) async {
    try {
      await _datasource.deleteSop(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
