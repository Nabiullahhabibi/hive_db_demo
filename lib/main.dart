import 'package:flutter/material.dart';

import 'core/storage/hive_service.dart';
import 'data/local/hive_user_local_data_source.dart';
import 'data/repositories/user_repository_impl.dart';
import 'domain/repositories/user_repository.dart';
import 'presentation/pages/hive_demo_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.init();

  final localDataSource =
  HiveUserLocalDataSource();

  await localDataSource.init();

  final UserRepository repository =
  UserRepositoryImpl(
    localDataSource: localDataSource,
  );

  runApp(
    HiveDemoApp(
      repository: repository,
    ),
  );
}

class HiveDemoApp extends StatelessWidget {
  final UserRepository repository;

  const HiveDemoApp({
    super.key,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hive Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: HiveDemoPage(
        repository: repository,
      ),
    );
  }
}