import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../../core/storage/hive_boxes.dart';
import '../../core/storage/hive_service.dart';
import '../../domain/entities/user.dart';

class HiveUserLocalDataSource {
  late final Box<dynamic> _box;

  Future<void> init() async {
    _box = await HiveService.openBox(
      HiveBoxes.users,
    );
  }

  Future<void> createUser(User user) async {
    await _box.put(
      user.id,
      _userToMap(user),
    );
  }

  User? getUser(String id) {
    final data = _box.get(id);

    if (data == null) {
      return null;
    }

    return _mapToUser(data);
  }

  List<User> getUsers() {
    return _box.values
        .map(_mapToUser)
        .toList();
  }

  Future<void> updateUser(User user) async {
    await _box.put(
      user.id,
      _userToMap(user),
    );
  }

  Future<void> deleteUser(String id) async {
    await _box.delete(id);
  }

  Future<void> deleteAllUsers() async {
    await _box.clear();
  }

  Stream<void> watchUsers() async* {
    await for (final _ in _box.watch()) {
      yield null;
    }
  }

  Map<String, dynamic> _userToMap(User user) {
    return {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'age': user.age,
    };
  }

  User _mapToUser(dynamic data) {
    final map = Map<String, dynamic>.from(
      data as Map,
    );

    return User(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      age: map['age'] as int,
    );
  }
}