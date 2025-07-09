import 'package:flutter_test/flutter_test.dart';
import 'package:minddrop/controllers/ideas_controller.dart';
import 'package:minddrop/models/idea.dart';
import 'package:minddrop/models/random_style.dart';
import 'package:minddrop/services/database_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Generate mocks for DatabaseService by running:
// flutter pub run build_runner build --delete-conflicting-outputs
// This will create ideas_controller_test.mocks.dart
@GenerateMocks([DatabaseService])
import 'ideas_controller_test.mocks.dart'; // Import generated mocks

void main() {
  group('IdeasController', () {
    late MockDatabaseService mockDatabaseService;
    late IdeasController ideasController;

    // Helper to create a dummy idea
    Idea createDummyIdea({String id = '1', String title = 'Test Idea', bool isFavorite = false, String? randomStyleId}) {
      return Idea(
        id: id, // Assuming Idea model allows setting ID directly or has a factory for testing
        title: title,
        content: 'Test content for $title',
        isFavorite: isFavorite,
        randomStyleId: randomStyleId,
        // createdAt and updatedAt will be set by default
      );
    }

    RandomStyle createDummyRandomStyle({String id = 'rs1'}) {
        return RandomStyle(
            id: id,
            gradientColors: [0xFFFFFFFF, 0xFF000000],
            beginAlignment: 'Alignment.topLeft',
            endAlignment: 'Alignment.bottomRight',
            iconDataCodePoint: Icons.star.codePoint,
            iconDataFontFamily: Icons.star.fontFamily,
            iconColor: 0xFF00FF00
        );
    }


    setUp(() {
      mockDatabaseService = MockDatabaseService();
      ideasController = IdeasController(databaseService: mockDatabaseService);
    });

    test('initial ideas list is empty and filter is off', () {
      expect(ideasController.ideas, isEmpty);
      expect(ideasController.isFilterActive, isFalse);
    });

    test('loadIdeas fetches ideas from DatabaseService and notifies listeners', () async {
      final dummyIdeas = [createDummyIdea(id: '1'), createDummyIdea(id: '2')];
      when(mockDatabaseService.getAllIdeas()).thenReturn(dummyIdeas);

      bool listenerCalled = false;
      ideasController.addListener(() {
        listenerCalled = true;
      });

      await ideasController.loadIdeas();

      expect(ideasController.ideas, equals(dummyIdeas));
      expect(listenerCalled, isTrue);
      verify(mockDatabaseService.getAllIdeas()).called(1);
    });

    test('addIdea calls DatabaseService.addIdea (and addRandomStyle if provided) and reloads ideas', () async {
      final newIdea = createDummyIdea(id: 'new');
      final newStyle = createDummyRandomStyle(id: 'newStyleId');
      newIdea.randomStyleId = newStyle.id; // Link idea to style

      when(mockDatabaseService.addIdea(any)).thenAnswer((_) async {});
      when(mockDatabaseService.addRandomStyle(any)).thenAnswer((_) async {});
      when(mockDatabaseService.getAllIdeas()).thenReturn([newIdea]); // Simulate it being added

      await ideasController.addIdea(newIdea, randomStyle: newStyle);

      verify(mockDatabaseService.addRandomStyle(newStyle)).called(1);
      verify(mockDatabaseService.addIdea(newIdea)).called(1);
      verify(mockDatabaseService.getAllIdeas()).called(1); // Called by loadIdeas()
      expect(ideasController.ideas.contains(newIdea), isTrue);
    });

    test('addIdea without randomStyle only calls addIdea', () async {
      final newIdea = createDummyIdea(id: 'newNoStyle');

      when(mockDatabaseService.addIdea(any)).thenAnswer((_) async {});
      when(mockDatabaseService.getAllIdeas()).thenReturn([newIdea]);

      await ideasController.addIdea(newIdea); // No randomStyle provided

      verifyNever(mockDatabaseService.addRandomStyle(any));
      verify(mockDatabaseService.addIdea(newIdea)).called(1);
      expect(ideasController.ideas.contains(newIdea), isTrue);
    });


    test('updateIdea calls DatabaseService.updateIdea and reloads ideas', () async {
      final ideaToUpdate = createDummyIdea(id: 'updateMe');
      ideasController.ideas.add(ideaToUpdate); // Add to controller's list first (or load it)

      when(mockDatabaseService.updateIdea(any)).thenAnswer((_) async {});
      when(mockDatabaseService.getAllIdeas()).thenReturn([ideaToUpdate]); // Simulate updated list

      ideaToUpdate.title = 'Updated Title';
      await ideasController.updateIdea(ideaToUpdate);

      verify(mockDatabaseService.updateIdea(ideaToUpdate)).called(1);
      verify(mockDatabaseService.getAllIdeas()).called(1);
      expect(ideasController.ideas.first.title, 'Updated Title');
    });

    test('updateIdea with newRandomStyleToSave calls addRandomStyle', () async {
        final ideaToUpdate = createDummyIdea(id: 'updateStyle');
        final newStyle = createDummyRandomStyle(id: 'rsNew');
        ideaToUpdate.randomStyleId = newStyle.id; // Link idea to the new style ID

        when(mockDatabaseService.updateIdea(any)).thenAnswer((_) async {});
        when(mockDatabaseService.addRandomStyle(any)).thenAnswer((_) async {});
        when(mockDatabaseService.getAllIdeas()).thenReturn([ideaToUpdate]);

        await ideasController.updateIdea(ideaToUpdate, newRandomStyleToSave: newStyle);

        verify(mockDatabaseService.addRandomStyle(newStyle)).called(1);
        verify(mockDatabaseService.updateIdea(ideaToUpdate)).called(1);
    });


    test('deleteIdea calls DatabaseService.deleteIdea and reloads ideas', () async {
      final ideaIdToDelete = 'deleteMe';
      final initialIdeas = [createDummyIdea(id: '1'), createDummyIdea(id: ideaIdToDelete)];

      // Initial load
      when(mockDatabaseService.getAllIdeas()).thenReturn(initialIdeas);
      await ideasController.loadIdeas();
      expect(ideasController.ideas.length, 2);

      // Setup for deletion
      when(mockDatabaseService.deleteIdea(ideaIdToDelete)).thenAnswer((_) async {});
      when(mockDatabaseService.getAllIdeas()).thenReturn([createDummyIdea(id: '1')]); // Simulate list after deletion

      await ideasController.deleteIdea(ideaIdToDelete);

      verify(mockDatabaseService.deleteIdea(ideaIdToDelete)).called(1);
      verify(mockDatabaseService.getAllIdeas()).called(2); // Once for initial, once for reload
      expect(ideasController.ideas.length, 1);
      expect(ideasController.ideas.any((idea) => idea.id == ideaIdToDelete), isFalse);
    });

    test('toggleFilterFavorites updates isFilterActive and filters ideas', () async {
      final favIdea = createDummyIdea(id: 'fav1', isFavorite: true);
      final nonFavIdea = createDummyIdea(id: 'nonFav1', isFavorite: false);
      final allIdeas = [favIdea, nonFavIdea];

      when(mockDatabaseService.getAllIdeas()).thenReturn(allIdeas);
      await ideasController.loadIdeas();

      expect(ideasController.isFilterActive, isFalse);
      expect(ideasController.ideas, containsAll(allIdeas));

      bool listenerCalled = false;
      ideasController.addListener(() => listenerCalled = true);

      ideasController.toggleFilterFavorites();
      expect(ideasController.isFilterActive, isTrue);
      expect(ideasController.ideas, contains(favIdea));
      expect(ideasController.ideas, isNot(contains(nonFavIdea)));
      expect(listenerCalled, isTrue);

      listenerCalled = false;
      ideasController.toggleFilterFavorites();
      expect(ideasController.isFilterActive, isFalse);
      expect(ideasController.ideas, containsAll(allIdeas));
      expect(listenerCalled, isTrue);
    });

    test('loadIdeas throws exception if service fails', () async {
      when(mockDatabaseService.getAllIdeas()).thenThrow(Exception('DB Error'));
      expect(() => ideasController.loadIdeas(), throwsException);
    });

    test('addIdea throws exception if service fails', () async {
      final newIdea = createDummyIdea();
      when(mockDatabaseService.addIdea(any)).thenThrow(Exception('DB Error'));
      expect(() => ideasController.addIdea(newIdea), throwsException);
    });
  });
}

// Need to import Icons from material.dart for createDummyRandomStyle
// For tests, it's fine, but if this helper was in main code, it'd be odd.
// A better way for tests would be to use integer code points directly.
class Icons { static const star = IconData(0xe5f9, fontFamily: 'MaterialIcons'); }
