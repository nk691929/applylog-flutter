import 'package:applylog/core/errors/result.dart';
import 'package:applylog/features/applications/data/repositories/firestore_application_repository_imp.dart';
import 'package:applylog/features/applications/domain/entities/application.dart';
import 'package:applylog/features/applications/domain/repositories/application_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final selectedStatusProvider = StateProvider<ApplicationStatus?>(
  (ref) => null,
);
final searchQueryProvider = StateProvider<String>((ref) => '');

final applicationRepositoryProvider = Provider<ApplicationRepository>((ref) {
  return FirestoreApplicationRepositoryImp(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );
});

final applicationStreamProvider = StreamProvider<Result<List<Application>>>((
  ref,
) {
  final applicationsStream = ref.watch(applicationRepositoryProvider);
  return applicationsStream.watchApplication();
});
