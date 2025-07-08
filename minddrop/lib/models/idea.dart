import 'package:hive/hive.dart';
import 'package:minddrop/models/random_style.dart';
import 'package:uuid/uuid.dart';

part 'idea.g.dart';

@HiveType(typeId: 0)
class Idea extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  DateTime updatedAt;

  @HiveField(5)
  String? imagePath;

  @HiveField(6)
  RandomStyle? randomStyle;

  @HiveField(7)
  bool isFavorite;

  Idea({
    required this.title,
    required this.content,
    this.imagePath,
    this.randomStyle,
    this.isFavorite = false,
  }) : id = const Uuid().v4(),
       createdAt = DateTime.now(),
       updatedAt = DateTime.now();
}
