import 'package:flutter/material.dart';
import 'package:minddrop/models/idea.dart';

class SearchController with ChangeNotifier {
  List<Idea> _searchResults = [];

  List<Idea> get searchResults => _searchResults;

  void search(String query, List<Idea> ideas) {
    if (query.isEmpty) {
      _searchResults = [];
    } else {
      _searchResults = ideas
          .where(
            (idea) =>
                idea.title.toLowerCase().contains(query.toLowerCase()) ||
                idea.content.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
    notifyListeners();
  }
}
