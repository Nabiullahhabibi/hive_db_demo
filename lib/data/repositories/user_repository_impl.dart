import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../local/hive_user_local_data_source.dart';
import '../models/user_model.dart';

class UserRepositoryImpl
    implements UserRepository {
  final HiveUserLocalDataSource localDataSource;

  UserRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<void> createUser(User user) {
    return localDataSource.createUser(
      UserModel.fromEntity(user),
    );
  }

  @override
  Future<List<User>> getUsers() async {
    final models =
    localDataSource.getUsers();

    return models
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<User?> getUser(String id) async {
    final model =
    localDataSource.getUser(id);

    return model?.toEntity();
  }

  @override
  Future<void> updateUser(User user) {
    return localDataSource.updateUser(
      UserModel.fromEntity(user),
    );
  }

  @override
  Future<void> deleteUser(String id) {
    return localDataSource.deleteUser(id);
  }

  @override
  Future<void> deleteAllUsers() {
    return localDataSource.deleteAllUsers();
  }

  @override
  Stream<void> watchUsers() {
    return localDataSource.watchUsers();
  }
}