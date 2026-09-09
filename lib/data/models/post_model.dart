import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../../domain/entities/post.dart';

part 'post_model.g.dart';

@HiveType(typeId: 1)
class PostModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String content;

  @HiveField(4)
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  factory PostModel.fromEntity(Post post) {
    return PostModel(
      id: post.id,
      userId: post.userId,
      title: post.title,
      content: post.content,
      createdAt: post.createdAt,
    );
  }

  Post toEntity() {
    return Post(
      id: id,
      userId: userId,
      title: title,
      content: content,
      createdAt: createdAt,
    );
  }
}