import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../../core/storage/hive_boxes.dart';
import '../models/post_model.dart';

class HivePostLocalDataSource {
  late final Box<PostModel> _box;

  Future<void> init() async {
    if (Hive.isBoxOpen(HiveBoxes.posts)) {
      _box = Hive.box<PostModel>(
        HiveBoxes.posts,
      );

      return;
    }

    _box = await Hive.openBox<PostModel>(
      HiveBoxes.posts,
    );
  }

  Future<void> createPost(
      PostModel post,
      ) async {
    await _box.put(
      post.id,
      post,
    );
  }

  PostModel? getPost(
      String id,
      ) {
    return _box.get(id);
  }

  List<PostModel> getPosts() {
    return _box.values.toList();
  }

  List<PostModel> getPostsByUser(
      String userId,
      ) {
    return _box.values
        .where(
          (post) => post.userId == userId,
    )
        .toList();
  }

  Future<void> updatePost(
      PostModel post,
      ) async {
    await _box.put(
      post.id,
      post,
    );
  }

  Future<void> deletePost(
      String id,
      ) async {
    await _box.delete(id);
  }

  Future<void> deletePostsByUser(
      String userId,
      ) async {
    final keys = _box.keys.where((key) {
      final post = _box.get(key);

      return post?.userId == userId;
    }).toList();

    await _box.deleteAll(keys);
  }

  Future<void> deleteAllPosts() async {
    await _box.clear();
  }

  Stream<void> watchPosts() async* {
    await for (final _ in _box.watch()) {
      yield null;
    }
  }
}