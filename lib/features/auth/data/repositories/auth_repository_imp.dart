import 'package:applylog/core/errors/failure.dart';
import 'package:applylog/core/errors/result.dart';
import 'package:applylog/features/auth/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthRepositoryImpl extends AuthRepository {
  final FirebaseAuth _auth;
  FirebaseAuthRepositoryImpl({required this._auth});
  @override
  Future<Result<void>> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return const Success(null);
    } on FirebaseAuthException catch (e) {
      return Error(NetworkFailure(e.message ?? 'Sign in failed'));
    }
  }

  @override
  Future<Result<void>> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return const Success(null);
    } on FirebaseAuthException catch (e) {
      return Error(NetworkFailure(e.message ?? 'Sign up failed'));
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Stream<bool> watchAuthState() {
    return _auth.authStateChanges().map((user) => user != null);
  }
}
