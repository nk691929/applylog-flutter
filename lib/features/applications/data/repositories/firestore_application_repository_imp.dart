import 'package:applylog/core/errors/failure.dart';
import 'package:applylog/core/errors/result.dart';
import 'package:applylog/features/applications/data/models/application_model.dart';
import 'package:applylog/features/applications/domain/entities/application.dart';
import 'package:applylog/features/applications/domain/repositories/application_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreApplicationRepositoryImp extends ApplicationRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  FirestoreApplicationRepositoryImp({
    required this.auth,
    required this.firestore,
  });

  CollectionReference<Map<String, dynamic>> get _collection {
    final uid = auth.currentUser!.uid;
    return firestore.collection('users').doc(uid).collection('applications');
  }

  @override
  Future<Result<void>> addApplication(Application application) async {
    try {
      final model = ApplicationModel(
        id: application.id,
        companyName: application.companyName,
        roleTitle: application.roleTitle,
        status: application.status,
        dateApplied: application.dateApplied,
        source: application.source,
        notes: application.notes,
        followUpDate: application.followUpDate,
      );
      await _collection.add(model.toFireStore());
      return const Success(null);
    } catch (e) {
      return Error(ServerFailure('Failed to add application: $e'));
    }
  }

  @override
  Future<Result<void>> deleteApplication(String id) async {
    try {
      await _collection.doc(id).delete();
      return const Success(null);
    } catch (e) {
      return Error(ServerFailure('Failed to delete application: $e'));
    }
  }

  @override
  Future<Result<void>> updateApplication(Application application) async {
    try {
      final model = ApplicationModel(
        id: application.id,
        companyName: application.companyName,
        roleTitle: application.roleTitle,
        status: application.status,
        dateApplied: application.dateApplied,
        source: application.source,
        notes: application.notes,
        followUpDate: application.followUpDate,
      );
      await _collection.doc(application.id).update(model.toFireStore());
      return const Success(null);
    } catch (e) {
      return Error(ServerFailure('Failed to update application: $e'));
    }
  }

  @override
  Stream<Result<List<Application>>> watchApplication() {
    return _collection.orderBy('dateApplied', descending: true).snapshots().map(
      (snapshot) {
        try {
          final applications = snapshot.docs
              .map((doc) => ApplicationModel.fromFireStore(doc.data(), doc.id))
              .toList();
          return Success(applications);
        } catch (e) {
          return Error(ParsingFailure('Failed to parse applications: $e'));
        }
      },
    );
  }

  @override
  Future<Result<void>> updateApplicationStatus(
    String id,
    ApplicationStatus status,
  ) async {
    try {
      await _collection.doc(id).update({'status': status.name});
      return const Success(null);
    } catch (e) {
      return Error(ServerFailure('Failed to update status: $e'));
    }
  }
}
