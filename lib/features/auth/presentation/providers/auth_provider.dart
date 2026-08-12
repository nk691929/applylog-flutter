import 'package:applylog/features/auth/data/repositories/auth_repository_imp.dart';
import 'package:applylog/features/auth/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => FirebaseAuthRepositoryImpl(auth: FirebaseAuth.instance),
);


final authStateProvider=StreamProvider<bool>((ref){
  return ref.watch(authRepositoryProvider).watchAuthState();
});