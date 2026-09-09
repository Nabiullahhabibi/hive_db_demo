class Post {
  final String id;
  final String userId;
  final String title;
  final String content;
  final DateTime createdAt;

  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  Post copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    DateTime? createdAt,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Post('
        'id: $id, '
        'userId: $userId, '
        'title: $title, '
        'content: $content, '
        'createdAt: $createdAt'
        ')';
  }
}