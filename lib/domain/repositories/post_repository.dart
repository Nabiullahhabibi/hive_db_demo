import '../entities/post.dart';

abstract class PostRepository {
  Future<void> createPost(Post post);

  Future<List<Post>> getPosts();

  Future<List<Post>> getPostsByUser(
      String userId,
      );

  Future<Post?> getPost(String id);

  Future<void> updatePost(Post post);

  Future<void> deletePost(String id);

  Future<void> deletePostsByUser(String userId);

  Future<void> deleteAllPosts();

  Stream<void> watchPosts();
}