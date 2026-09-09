import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final int age;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
  });

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      age: user.age,
    );
  }

  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
      age: age,
    );
  }
}