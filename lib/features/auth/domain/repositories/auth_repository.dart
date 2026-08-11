import 'package:applylog/core/errors/result.dart';

abstract class AuthRepository {
  Future<Result<void>> signIn(String email,String password);
  Future<Result<void>> signUp(String email,String password);
  Future<void> signout();
}