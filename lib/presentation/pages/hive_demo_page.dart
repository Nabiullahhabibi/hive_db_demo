import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

class HiveDemoPage extends StatefulWidget {
  final UserRepository repository;

  const HiveDemoPage({
    super.key,
    required this.repository,
  });

  @override
  State<HiveDemoPage> createState() => _HiveDemoPageState();
}

class _HiveDemoPageState extends State<HiveDemoPage> {
  List<User> _users = [];

  StreamSubscription<void>? _watchSubscription;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadUsers();

    _watchSubscription = widget.repository.watchUsers().listen((_) {
      _loadUsers();
    });
  }

  @override
  void dispose() {
    _watchSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await widget.repository.getUsers();

      if (!mounted) {
        return;
      }

      setState(() {
        _users = users;
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
        'Failed to load users: $e',
      );
    }
  }

  Future<void> _createUser() async {
    final user = await _showUserForm();

    if (user == null) {
      return;
    }

    try {
      await widget.repository.createUser(user);

      _showMessage(
        'User created successfully',
      );
    } catch (e) {
      _showMessage(
        'Failed to create user: $e',
      );
    }
  }

  Future<void> _editUser(User user) async {
    final updatedUser = await _showUserForm(
      user: user,
    );

    if (updatedUser == null) {
      return;
    }

    try {
      await widget.repository.updateUser(
        updatedUser,
      );

      _showMessage(
        'User updated successfully',
      );
    } catch (e) {
      _showMessage(
        'Failed to update user: $e',
      );
    }
  }

  Future<void> _deleteUser(User user) async {
    final confirmed = await _showDeleteConfirmation(
      user,
    );

    if (!confirmed) {
      return;
    }

    try {
      await widget.repository.deleteUser(
        user.id,
      );

      _showMessage(
        'User deleted successfully',
      );
    } catch (e) {
      _showMessage(
        'Failed to delete user: $e',
      );
    }
  }

  Future<void> _deleteAllUsers() async {
    if (_users.isEmpty) {
      _showMessage(
        'There are no users to delete',
      );

      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete all users?',
          ),
          content: Text(
            'This will permanently remove '
                '${_users.length} users from Hive.',
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
              child: const Text('Delete all'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await widget.repository.deleteAllUsers();

      _showMessage(
        'All users deleted',
      );
    } catch (e) {
      _showMessage(
        'Failed to delete users: $e',
      );
    }
  }

  Future<User?> _showUserForm({
    User? user,
  }) async {
    final formKey = GlobalKey<FormState>();

    return showDialog<User>(
      context: context,
      builder: (dialogContext) {
        return _UserFormDialog(
          formKey: formKey,
          user: user,
        );
      },
    );
  }

  Future<bool> _showDeleteConfirmation(
      User user,
      ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete User?',
          ),
          content: Text(
            'Are you sure you want to delete '
                '${user.name}?',
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
        title: const Text(
          'Hive CRUD Demo',
        ),
        actions: [
          if (_users.isNotEmpty)
            IconButton(
              tooltip: 'Delete all users',
              onPressed: _deleteAllUsers,
              icon: const Icon(
                Icons.delete_sweep,
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createUser,
        icon: const Icon(Icons.add),
        label: const Text('Add User'),
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

    if (_users.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'No users found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tap "Add User" to create one.',
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      separatorBuilder: (_, __) {
        return const SizedBox(height: 10);
      },
      itemBuilder: (context, index) {
        final user = _users[index];

        return Card(
          child: ListTile(
            contentPadding:
            const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              child: Text(
                user.name.isNotEmpty
                    ? user.name[0].toUpperCase()
                    : '?',
              ),
            ),
            title: Text(
              user.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(
                top: 4,
              ),
              child: Text(
                '${user.email}\nAge: ${user.age}',
              ),
            ),
            isThreeLine: true,
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _editUser(user);
                    break;

                  case 'delete':
                    _deleteUser(user);
                    break;
                }
              },
              itemBuilder: (context) {
                return const [
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Edit'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(
                        Icons.delete,
                      ),
                      title: Text('Delete'),
                      contentPadding: EdgeInsets.zero,
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

class _UserFormDialog extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final User? user;

  const _UserFormDialog({
    required this.formKey,
    required this.user,
  });

  @override
  State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _ageController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.user?.name ?? '',
    );

    _emailController = TextEditingController(
      text: widget.user?.email ?? '',
    );

    _ageController = TextEditingController(
      text: widget.user?.age.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();

    super.dispose();
  }

  void _submit() {
    if (!widget.formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final age = int.parse(
      _ageController.text.trim(),
    );

    final user = User(
      id: widget.user?.id ??
          DateTime.now()
              .millisecondsSinceEpoch
              .toString(),
      name: name,
      email: email,
      age: age,
    );

    Navigator.of(context).pop(user);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.user != null;

    return AlertDialog(
      title: Text(
        isEditing
            ? 'Edit User'
            : 'Create User',
      ),
      content: Form(
        key: widget.formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                textInputAction:
                TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter user name',
                  prefixIcon: Icon(
                    Icons.person,
                  ),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Name is required';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                keyboardType:
                TextInputType.emailAddress,
                textInputAction:
                TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter user email',
                  prefixIcon: Icon(
                    Icons.email,
                  ),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Email is required';
                  }

                  if (!value.contains('@')) {
                    return 'Enter a valid email';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _ageController,
                keyboardType:
                TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  hintText: 'Enter user age',
                  prefixIcon: Icon(
                    Icons.cake,
                  ),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Age is required';
                  }

                  final age = int.tryParse(
                    value.trim(),
                  );

                  if (age == null) {
                    return 'Enter a valid age';
                  }

                  if (age <= 0 || age > 150) {
                    return 'Enter a valid age';
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
            isEditing ? 'Save' : 'Create',
          ),
        ),
      ],
    );
  }
}