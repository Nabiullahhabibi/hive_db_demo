
import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/entities/post.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/post_repository.dart';

class UserPostsPage extends StatefulWidget {
  final User user;
  final PostRepository postRepository;

  const UserPostsPage({
    super.key,
    required this.user,
    required this.postRepository,
  });

  @override
  State<UserPostsPage> createState() =>
      _UserPostsPageState();
}

class _UserPostsPageState
    extends State<UserPostsPage> {
  List<Post> _posts = [];

  StreamSubscription<void>?
  _watchSubscription;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadPosts();

    _watchSubscription =
        widget.postRepository.watchPosts().listen(
              (_) {
            _loadPosts();
          },
        );
  }

  @override
  void dispose() {
    _watchSubscription?.cancel();

    super.dispose();
  }

  Future<void> _loadPosts() async {
    try {
      final posts =
      await widget.postRepository
          .getPostsByUser(
        widget.user.id,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Failed to load posts: $e',
      );
    }
  }

  Future<void> _createPost() async {
    final post =
    await _showPostForm();

    if (post == null) {
      return;
    }

    try {
      await widget.postRepository
          .createPost(post);

      _showMessage(
        'Post created successfully',
      );
    } catch (e) {
      _showMessage(
        'Failed to create post: $e',
      );
    }
  }

  Future<void> _editPost(Post post) async {
    final updatedPost =
    await _showPostForm(
      post: post,
    );

    if (updatedPost == null) {
      return;
    }

    try {
      await widget.postRepository
          .updatePost(updatedPost);

      _showMessage(
        'Post updated successfully',
      );
    } catch (e) {
      _showMessage(
        'Failed to update post: $e',
      );
    }
  }

  Future<void> _deletePost(Post post) async {
    final confirmed =
    await _showDeleteConfirmation(
      post,
    );

    if (!confirmed) {
      return;
    }

    try {
      await widget.postRepository
          .deletePost(post.id);

      _showMessage(
        'Post deleted successfully',
      );
    } catch (e) {
      _showMessage(
        'Failed to delete post: $e',
      );
    }
  }

  Future<Post?> _showPostForm({
    Post? post,
  }) async {
    final formKey =
    GlobalKey<FormState>();

    return showDialog<Post>(
      context: context,
      builder: (dialogContext) {
        return _PostFormDialog(
          formKey: formKey,
          userId: widget.user.id,
          post: post,
        );
      },
    );
  }

  Future<bool> _showDeleteConfirmation(
      Post post,
      ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Post?',
          ),
          content: Text(
            'Are you sure you want to '
                'delete "${post.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.user.name}\'s Posts',
        ),
      ),
      floatingActionButton:
      FloatingActionButton.extended(
        onPressed: _createPost,
        icon: const Icon(Icons.add),
        label: const Text('Add Post'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            const Icon(
              Icons.article_outlined,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'No posts found',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create the first post '
                  'for ${widget.user.name}.',
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding:
      const EdgeInsets.all(16),
      itemCount: _posts.length,
      separatorBuilder: (_, __) {
        return const SizedBox(height: 10);
      },
      itemBuilder: (context, index) {
        final post = _posts[index];

        return Card(
          child: ListTile(
            contentPadding:
            const EdgeInsets.all(16),
            title: Text(
              post.title,
              style: const TextStyle(
                fontWeight:
                FontWeight.bold,
              ),
            ),
            subtitle: Padding(
              padding:
              const EdgeInsets.only(
                top: 8,
              ),
              child: Text(
                post.content,
              ),
            ),
            trailing:
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _editPost(post);
                    break;

                  case 'delete':
                    _deletePost(post);
                    break;
                }
              },
              itemBuilder: (context) {
                return const [
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading:
                      Icon(Icons.edit),
                      title: Text('Edit'),
                      contentPadding:
                      EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading:
                      Icon(Icons.delete),
                      title: Text('Delete'),
                      contentPadding:
                      EdgeInsets.zero,
                    ),
                  ),
                ];
              },
            ),
          ),
        );
      },
    );
  }
}

class _PostFormDialog
    extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final String userId;
  final Post? post;

  const _PostFormDialog({
    required this.formKey,
    required this.userId,
    required this.post,
  });

  @override
  State<_PostFormDialog> createState() =>
      _PostFormDialogState();
}

class _PostFormDialogState
    extends State<_PostFormDialog> {
  late final TextEditingController
  _titleController;

  late final TextEditingController
  _contentController;

  @override
  void initState() {
    super.initState();

    _titleController =
        TextEditingController(
          text: widget.post?.title ?? '',
        );

    _contentController =
        TextEditingController(
          text: widget.post?.content ?? '',
        );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();

    super.dispose();
  }

  void _submit() {
    if (!widget.formKey.currentState!
        .validate()) {
      return;
    }

    final post = Post(
      id: widget.post?.id ??
          DateTime.now()
              .microsecondsSinceEpoch
              .toString(),
      userId: widget.userId,
      title: _titleController.text.trim(),
      content:
      _contentController.text.trim(),
      createdAt:
      widget.post?.createdAt ??
          DateTime.now(),
    );

    Navigator.of(context).pop(post);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing =
        widget.post != null;

    return AlertDialog(
      title: Text(
        isEditing
            ? 'Edit Post'
            : 'Create Post',
      ),
      content: Form(
        key: widget.formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              TextFormField(
                controller:
                _titleController,
                decoration:
                const InputDecoration(
                  labelText: 'Title',
                  prefixIcon:
                  Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Title is required';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller:
                _contentController,
                maxLines: 5,
                decoration:
                const InputDecoration(
                  labelText: 'Content',
                  alignLabelWithHint: true,
                  prefixIcon:
                  Icon(Icons.article),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Content is required';
                  }

                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(
            isEditing
                ? 'Save'
                : 'Create',
          ),
        ),
      ],
    );
  }
}