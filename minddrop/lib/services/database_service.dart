import 'package:hive/hive.dart';
import 'package:minddrop/models/idea.dart';

class DatabaseService {
  final Box<Idea> _ideaBox = Hive.box<Idea>('ideas');

  // Create
  Future<void> addIdea(Idea idea) async {
    await _ideaBox.put(idea.id, idea);
  }

  // Read
  Idea? getIdea(String id) {
    return _ideaBox.get(id);
  }

  List<Idea> getAllIdeas() {
    return _ideaBox.values.toList();
  }

  // Update
  Future<void> updateIdea(Idea idea) async {
    await idea.save();
  }

  // Delete
  Future<void> deleteIdea(String id) async {
    await _ideaBox.delete(id);
  }
}
