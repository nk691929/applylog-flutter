import 'package:applylog/core/errors/result.dart';
import 'package:applylog/features/applications/domain/entities/application.dart';

abstract class ApplicationRepository {
  Stream<Result<List<Application>>> watchApplication();
  Future<Result<String>> addApplication(Application application);
  Future<Result<void>> updateApplication(Application application);
  Future<Result<void>> updateStatus(
    String id,
    ApplicationStatus status,
  );
  Future<Result<void>> deleteApplication(String id);
}
