import 'package:hive/hive.dart';

part 'random_style.g.dart';

@HiveType(typeId: 1)
class RandomStyle extends HiveObject {
  @HiveField(0)
  final String color;

  @HiveField(1)
  final String icon;

  RandomStyle({required this.color, required this.icon});
}
