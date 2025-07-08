import 'package:flutter/foundation.dart'; // For ChangeNotifier
import 'package:minddrop/models/idea.dart';
import 'package:minddrop/models/random_style.dart';
import 'package:minddrop/services/database_service.dart';
// import 'dart:math';

class IdeasController with ChangeNotifier {
  // Allow DatabaseService to be injected for testability, or use a singleton/service locator
  final DatabaseService _databaseService;

  IdeasController({DatabaseService? databaseService})
    : _databaseService = databaseService ?? DatabaseService();

  List<Idea> _allIdeas = []; // Stores all ideas fetched from DB
  bool _filterFavorites = false;

  List<Idea> get ideas { // This getter will now apply the filter
    if (_filterFavorites) {
      return _allIdeas.where((idea) => idea.isFavorite).toList();
    }
    return _allIdeas;
  }

  bool get isFilterActive => _filterFavorites;

  Future<void> loadIdeas() async {
    try {
      _allIdeas = _databaseService.getAllIdeas();
      notifyListeners();
    } catch (e) {
      debugPrint("Error in loadIdeas controller: $e");
      // Propagate error or set an error state for UI to consume
      // For now, just printing, UI might not know loading failed unless it handles this.
      // Consider adding an error property to the controller.
      throw Exception("Failed to load ideas: $e");
    }
  }

  void toggleFilterFavorites() {
    _filterFavorites = !_filterFavorites;
    notifyListeners();
  }

  // Ensure add, update, delete operations work on _allIdeas and then notify,
  // so the filtered list is correctly derived.
  // `loadIdeas()` is already called after these operations, which re-populates _allIdeas.

  Future<void> addIdea(Idea idea, {RandomStyle? randomStyle}) async {
    try {
      if (randomStyle != null) {
        // Ensure the idea's randomStyleId matches the style being saved
        if (idea.randomStyleId != randomStyle.id) {
          throw Exception("Idea's randomStyleId does not match the provided RandomStyle object's ID.");
        }
        await _databaseService.addRandomStyle(randomStyle);
      }
      await _databaseService.addIdea(idea);
      await loadIdeas(); // Reload ideas to reflect the new addition
    } catch (e) {
      // Consider more specific error handling or re-throwing
      debugPrint("Error in addIdea controller: $e");
      throw Exception("Failed to add idea: $e");
    }
  }

  Future<void> updateIdea(Idea idea, {RandomStyle? newRandomStyleToSave}) async {
    try {
      // If a new random style was generated and needs to be saved
      if (newRandomStyleToSave != null) {
         // Ensure the idea's randomStyleId points to this new style
        if (idea.randomStyleId != newRandomStyleToSave.id) {
          throw Exception("Idea's randomStyleId does not match the new RandomStyle object's ID to be saved.");
        }
        await _databaseService.addRandomStyle(newRandomStyleToSave);
        // The idea object itself should already have its randomStyleId updated before calling this.
        // And idea.randomStyle object reference updated.
      }
      // If the idea was switched from a random style to an image,
      // or to a *different* random style, the old RandomStyle object might be orphaned.
      // Proper cleanup of orphaned RandomStyle objects is complex (e.g., reference counting)
      // and is deferred (marked as TODO for P2-CRUD-002 or later).

      await _databaseService.updateIdea(idea);
      await loadIdeas(); // Reload ideas to reflect the update
    } catch (e) {
      debugPrint("Error in updateIdea controller: $e");
      throw Exception("Failed to update idea: $e");
    }
  }

  Future<void> deleteIdea(String id) async {
    try {
      await _databaseService.deleteIdea(id);
      await loadIdeas(); // Reload ideas to reflect the deletion
    } catch (e) {
      debugPrint("Error in deleteIdea controller: $e");
      throw Exception("Failed to delete idea: $e");
    }
  }
}
