import 'dart:io'; // For File operations
import 'package:flutter/foundation.dart'; // for debugPrint
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart'; // For getApplicationDocumentsDirectory
import 'package:minddrop/models/idea.dart';
import 'package:minddrop/models/random_style.dart';

class DatabaseService {
  // It's good practice to ensure boxes are open before using them.
  // This is typically handled in HiveService or main.dart during initialization.
  // For simplicity here, we assume they are open.
  late final Box<Idea> _ideaBox;
  late final Box<RandomStyle> _randomStyleBox;

  DatabaseService() {
    // Initialize boxes - this assumes they are already opened by HiveService
    _ideaBox = Hive.box<Idea>('ideas');
    _randomStyleBox = Hive.box<RandomStyle>('randomStyles');
  }

  // --- Idea Operations ---

  Future<void> addIdea(Idea idea) async {
    await _ideaBox.put(idea.id, idea);
  }

  Idea? getIdea(String id) {
    return _ideaBox.get(id);
  }

  List<Idea> getAllIdeas() {
    var ideas = _ideaBox.values.toList();
    // For each idea, if randomStyleId is present, fetch and attach RandomStyle
    for (var idea in ideas) {
      if (idea.randomStyleId != null) {
        idea.randomStyle = getRandomStyle(idea.randomStyleId!);
      }
    }
    ideas.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return ideas;
  }

  // Also update getIdea to do the same
  Idea? getIdea(String id) {
    final idea = _ideaBox.get(id);
    if (idea != null && idea.randomStyleId != null) {
      idea.randomStyle = getRandomStyle(idea.randomStyleId!);
    }
    return idea;
  }

  Future<void> updateIdea(Idea idea) async {
    // HiveObjects can be saved directly if they are already in a box and have changed.
    // Using put ensures it's added if not present or updated if present.
    await _ideaBox.put(idea.id, idea);
  }

  Future<void> deleteIdea(String id) async {
    final ideaToDelete = getIdea(id); // Fetch idea first to get imagePath and randomStyleId

    if (ideaToDelete != null) {
      // 1. Delete associated image file if it exists
      if (ideaToDelete.imagePath != null && ideaToDelete.imagePath!.isNotEmpty) {
        try {
          final imageFile = File(ideaToDelete.imagePath!);
          if (await imageFile.exists()) {
            await imageFile.delete();
            debugPrint('Deleted image file: ${ideaToDelete.imagePath}');
          }
        } catch (e) {
          debugPrint('Error deleting image file ${ideaToDelete.imagePath}: $e');
          // Non-fatal, proceed with deleting the idea entry
        }
      }

      // 2. Delete associated RandomStyle if it's not used by other ideas
      if (ideaToDelete.randomStyleId != null) {
        final styleId = ideaToDelete.randomStyleId!;
        // Check if any other idea uses this style
        final otherIdeasWithStyle = _ideaBox.values.where(
          (idea) => idea.id != id && idea.randomStyleId == styleId
        ).toList();

        if (otherIdeasWithStyle.isEmpty) {
          await deleteRandomStyle(styleId); // Call the existing deleteRandomStyle
          debugPrint('Deleted random style: $styleId as it was no longer used.');
        } else {
          debugPrint('Random style $styleId is still used by other ideas.');
        }
      }
    }

    await _ideaBox.delete(id); // Delete the idea entry itself
    debugPrint('Deleted idea from box: $id');
  }

  // --- RandomStyle Operations ---

  Future<void> addRandomStyle(RandomStyle style) async {
    await _randomStyleBox.put(style.id, style);
  }

  RandomStyle? getRandomStyle(String id) {
    return _randomStyleBox.get(id);
  }

  Future<void> deleteRandomStyle(String id) async {
    // Check if this style is used by any other idea before deleting.
    // This is a more complex check, for now, direct delete.
    // Proper cleanup might involve reference counting or specific checks during idea deletion.
    await _randomStyleBox.delete(id);
  }

  // --- Image Cleanup Operations ---
  Future<int> cleanUpOrphanedImages() async {
    debugPrint('Starting orphaned image cleanup...');
    int cleanedFilesCount = 0;
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String imagesDirPath = '${appDocDir.path}/idea_images';
      final Directory imagesDir = Directory(imagesDirPath);

      if (!await imagesDir.exists()) {
        debugPrint('Image directory does not exist. No cleanup needed.');
        return 0;
      }

      final List<FileSystemEntity> imageFiles = imagesDir.listSync();
      if (imageFiles.isEmpty) {
        debugPrint('Image directory is empty. No cleanup needed.');
        return 0;
      }

      final Set<String> referencedImagePaths = {};
      final List<Idea> allIdeas = _ideaBox.values.toList();
      for (final idea in allIdeas) {
        if (idea.imagePath != null && idea.imagePath!.isNotEmpty) {
          referencedImagePaths.add(idea.imagePath!);
        }
      }

      debugPrint('Found ${imageFiles.length} files in images directory.');
      debugPrint('Found ${referencedImagePaths.length} referenced images in database.');

      for (final fileEntity in imageFiles) {
        if (fileEntity is File) {
          if (!referencedImagePaths.contains(fileEntity.path)) {
            try {
              await fileEntity.delete();
              cleanedFilesCount++;
              debugPrint('Deleted orphaned image: ${fileEntity.path}');
            } catch (e) {
              debugPrint('Error deleting orphaned image ${fileEntity.path}: $e');
            }
          }
        }
      }
      debugPrint('Orphaned image cleanup finished. Deleted $cleanedFilesCount files.');
      return cleanedFilesCount;
    } catch (e) {
      debugPrint('Error during orphaned image cleanup process: $e');
      return cleanedFilesCount; // Return count even if process interrupted by other error
    }
  }
}
