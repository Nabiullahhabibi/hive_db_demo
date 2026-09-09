import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../../core/storage/hive_boxes.dart';
import '../../core/storage/hive_service.dart';
import '../models/user_model.dart';

class HiveUserLocalDataSource {
  late final Box<UserModel> _box;

  Future<void> init() async {
    if (Hive.isBoxOpen(HiveBoxes.users)) {
      _box = Hive.box<UserModel>(
        HiveBoxes.users,
      );

      return;
    }

    _box = await Hive.openBox<UserModel>(
      HiveBoxes.users,
    );
  }

  Future<void> createUser(
      UserModel user,
      ) async {
    await _box.put(
      user.id,
      user,
    );
  }

  UserModel? getUser(
      String id,
      ) {
    return _box.get(id);
  }

  List<UserModel> getUsers() {
    return _box.values.toList();
  }

  Future<void> updateUser(
      UserModel user,
      ) async {
    await _box.put(
      user.id,
      user,
    );
  }

  Future<void> deleteUser(
      String id,
      ) async {
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
}