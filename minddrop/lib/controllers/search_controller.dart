import 'dart:async'; // For Timer (debouncing)
import 'package:flutter/material.dart';
import 'package:minddrop/models/idea.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart' as fuzzy;
import 'package:fuzzywuzzy/algorithms/token_set_ratio.dart'; // Example algorithm

class SearchController with ChangeNotifier {
  String _query = '';
  List<Idea> _searchResults = [];
  bool _isSearchActive = false;
  Timer? _debounce;

  String get query => _query;
  List<Idea> get searchResults => _searchResults;
  bool get isSearchActive => _isSearchActive; // To control UI state in HomeScreen

  // This method will be called by the UI when the search text changes
  void onSearchQueryChanged(String newQuery, List<Idea> allIdeas) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      _query = newQuery.trim();
      if (_query.isEmpty) {
        _searchResults = [];
        // _isSearchActive = false; // Keep search active to show "type to search" or clear button
      } else {
        // Fuzzy search logic
        _searchResults = [];
        if (_query.isNotEmpty) {
          List<Map<String, dynamic>> scoredIdeas = [];

          for (var idea in allIdeas) {
            // Calculate scores for title and content separately
            // Using tokenSetRatio for more flexibility with word order and partial matches
            int titleScore = fuzzy.extractOne(
              query: _query,
              choices: [idea.title],
              cutoff: 60, // Minimum score to consider a match (0-100)
              getter: (s) => s, // Choices are already strings
              algorithm: TokenSetRatio()
            )?.score ?? 0;

            int contentScore = fuzzy.extractOne(
              query: _query,
              choices: [idea.content],
              cutoff: 60,
              getter: (s) => s,
              algorithm: TokenSetRatio()
            )?.score ?? 0;

            // Combine scores, prioritizing title matches slightly or using the higher score
            int combinedScore = (titleScore > contentScore ? titleScore : contentScore);
            // Or a weighted average: int combinedScore = (titleScore * 0.6 + contentScore * 0.4).round();

            if (combinedScore >= 60) { // Overall cutoff
              scoredIdeas.add({'idea': idea, 'score': combinedScore});
            }
          }

          // Sort by score descending
          scoredIdeas.sort((a, b) => b['score'].compareTo(a['score']));
          _searchResults = scoredIdeas.map((item) => item['idea'] as Idea).toList();
        }
      }
      notifyListeners();
    });
  }

  void clearSearch() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _query = '';
    _searchResults = [];
    _isSearchActive = false; // When explicitly cleared, deactivate search mode
    notifyListeners();
  }

  void activateSearch() {
    _isSearchActive = true;
    notifyListeners();
  }

  void deactivateSearch() {
    // Called when search UI is dismissed, not just when query is empty
    clearSearch(); // This will set _isSearchActive to false and notify
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
