import 'package:hive/hive.dart';

part 'random_style.g.dart';

@HiveType(typeId: 1)
class RandomStyle extends HiveObject {
  @HiveField(0)
  final List<int> gradientColors; // Storing Color.value as int

  @HiveField(1)
  final String beginAlignment; // Storing Alignment.toString()

  @HiveField(2)
  final String endAlignment; // Storing Alignment.toString()

  @HiveField(3)
  final int iconDataCodePoint;

  @HiveField(4)
  final String? iconDataFontFamily;

  @HiveField(5)
  final String? iconDataFontPackage; // For icons from packages

  @HiveField(6)
  final int iconColor; // Storing Color.value as int

  @HiveField(7)
  final String id; // Unique ID for this style

  RandomStyle({
    required this.id,
    required this.gradientColors,
    required this.beginAlignment,
    required this.endAlignment,
    required this.iconDataCodePoint,
    this.iconDataFontFamily,
    this.iconDataFontPackage,
    required this.iconColor,
  });
}
