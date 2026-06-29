import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../domain/email_model.dart';
import '../domain/email_repository.dart';
import 'email_datasource.dart';

class EmailRepositoryImpl implements EmailRepository {
  final EmailDatasource _datasource;

  EmailRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, SavedEmail>> createEmail(EmailModel data) async {
    try {
      final result = await _datasource.createEmail(data);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SavedEmail>>> getEmailHistory() async {
    try {
      final result = await _datasource.fetchEmailHistory();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SavedEmail>> getEmailDetails(String id) async {
    try {
      final result = await _datasource.getEmailDetails(id);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEmail(String id) async {
    try {
      await _datasource.deleteEmail(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
