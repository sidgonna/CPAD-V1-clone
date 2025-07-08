import 'package:flutter/material.dart';
import 'package:minddrop/models/idea.dart';
import 'package:minddrop/services/database_service.dart';
// import 'dart:math';

class IdeasController with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<Idea> _ideas = [];

  List<Idea> get ideas => _ideas;

  Future<void> loadIdeas() async {
    _ideas = _databaseService.getAllIdeas();
    notifyListeners();
  }

  Future<void> addIdea(Idea idea) async {
    await _databaseService.addIdea(idea);
    await loadIdeas();
  }

  Future<void> updateIdea(Idea idea) async {
    await _databaseService.updateIdea(idea);
    await loadIdeas();
  }

  Future<void> deleteIdea(String id) async {
    await _databaseService.deleteIdea(id);
    await loadIdeas();
  }
}
