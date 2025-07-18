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
  String? randomStyleId;

  @HiveField(7)
  bool isFavorite;

  // This field is not persisted in Hive. It's for runtime use.
  RandomStyle? randomStyle;

  Idea({
    String? id,
    required this.title,
    required this.content,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.imagePath,
    this.randomStyleId,
    this.isFavorite = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // copyWith method
  Idea copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imagePath,
    String? randomStyleId,
    bool? isFavorite,
  }) {
    return Idea(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imagePath: imagePath ?? this.imagePath,
      randomStyleId: randomStyleId ?? this.randomStyleId,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
