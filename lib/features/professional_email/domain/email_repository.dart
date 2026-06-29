import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import 'email_model.dart';

abstract class EmailRepository {
  Future<Either<Failure, SavedEmail>> createEmail(EmailModel data);
  Future<Either<Failure, List<SavedEmail>>> getEmailHistory();
  Future<Either<Failure, SavedEmail>> getEmailDetails(String id);
  Future<Either<Failure, void>> deleteEmail(String id);
}
