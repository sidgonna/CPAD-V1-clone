import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:minddrop/models/idea.dart';
import 'package:minddrop/models/random_style.dart';
import 'package:path_provider/path_provider.dart';

class HiveService {
  static Future<void> init() async {
    if (!kIsWeb) {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDocumentDir.path);
    } else {
      await Hive.initFlutter();
    }

    // Register adapters
    Hive.registerAdapter(IdeaAdapter());
    Hive.registerAdapter(RandomStyleAdapter());

    // Open boxes
    await Hive.openBox<Idea>('ideas');
  }
}
