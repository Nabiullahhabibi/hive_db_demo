import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../local/hive_post_local_data_source.dart';
import '../models/post_model.dart';

class PostRepositoryImpl
    implements PostRepository {
  final HivePostLocalDataSource localDataSource;

  PostRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<void> createPost(Post post) {
    return localDataSource.createPost(
      PostModel.fromEntity(post),
    );
  }

  @override
  Future<List<Post>> getPosts() async {
    final models =
    localDataSource.getPosts();

    return models
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<Post>> getPostsByUser(
      String userId,
      ) async {
    final models =
    localDataSource.getPostsByUser(
      userId,
    );

    return models
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<Post?> getPost(String id) async {
    final model =
    localDataSource.getPost(id);

    return model?.toEntity();
  }

  @override
  Future<void> updatePost(Post post) {
    return localDataSource.updatePost(
      PostModel.fromEntity(post),
    );
  }

  @override
  Future<void> deletePost(String id) {
    return localDataSource.deletePost(id);
  }

  @override
  Future<void> deletePostsByUser(
      String userId,
      ) {
    return localDataSource.deletePostsByUser(
      userId,
    );
  }

  @override
  Future<void> deleteAllPosts() {
    return localDataSource.deleteAllPosts();
  }

  @override
  Stream<void> watchPosts() {
    return localDataSource.watchPosts();
  }
}