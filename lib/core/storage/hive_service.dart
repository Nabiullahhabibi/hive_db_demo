import 'package:hive_ce_flutter/hive_ce_flutter.dart';

class HiveService {
  HiveService._();

  static Future<void> init() async {
    await Hive.initFlutter();
  }

  static Future<Box<dynamic>> openBox(
      String name,
      ) async {
    if (Hive.isBoxOpen(name)) {
      return Hive.box<dynamic>(name);
    }

    return Hive.openBox<dynamic>(name);
  }

  static Box<dynamic> box(String name) {
    return Hive.box<dynamic>(name);
  }

  static Future<void> closeBox(
      String name,
      ) async {
    if (Hive.isBoxOpen(name)) {
      await Hive.box<dynamic>(name).close();
    }
  }
}