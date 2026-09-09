import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'core/storage/hive_boxes.dart';
import 'data/local/hive_post_local_data_source.dart';
import 'data/local/hive_user_local_data_source.dart';
import 'data/models/post_model.dart';
import 'data/models/user_model.dart';
import 'data/repositories/post_repository_impl.dart';
import 'data/repositories/user_repository_impl.dart';
import 'domain/repositories/post_repository.dart';
import 'domain/repositories/user_repository.dart';
import 'presentation/pages/users_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(
    UserModelAdapter(),
  );

  Hive.registerAdapter(
    PostModelAdapter(),
  );

  final userLocalDataSource =
  HiveUserLocalDataSource();

  final postLocalDataSource =
  HivePostLocalDataSource();

  await userLocalDataSource.init();

  await postLocalDataSource.init();

  final UserRepository userRepository =
  UserRepositoryImpl(
    localDataSource:
    userLocalDataSource,
  );

  final PostRepository postRepository =
  PostRepositoryImpl(
    localDataSource:
    postLocalDataSource,
  );

  runApp(
    HiveDemoApp(
      userRepository: userRepository,
      postRepository: postRepository,
    ),
  );
}

class HiveDemoApp extends StatelessWidget {
  final UserRepository userRepository;
  final PostRepository postRepository;

  const HiveDemoApp({
    super.key,
    required this.userRepository,
    required this.postRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hive Demo',
      theme: ThemeData(
        colorScheme:
        ColorScheme.fromSeed(
          seedColor:
          Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: UsersPage(
        userRepository:
        userRepository,
        postRepository:
        postRepository,
      ),
    );
  }
}