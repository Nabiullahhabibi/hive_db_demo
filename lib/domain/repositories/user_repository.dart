import '../entities/user.dart';

abstract class UserRepository {
  Future<void> createUser(User user);

  Future<List<User>> getUsers();

  Future<User?> getUser(String id);

  Future<void> updateUser(User user);

  Future<void> deleteUser(String id);

  Future<void> deleteAllUsers();

  Stream<void> watchUsers();
}