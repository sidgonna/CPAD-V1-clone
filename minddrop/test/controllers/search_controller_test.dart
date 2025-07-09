import 'package:flutter_test/flutter_test.dart';
import 'package:minddrop/controllers/search_controller.dart';
import 'package:minddrop/models/idea.dart';
import 'package:fake_async/fake_async.dart'; // For testing debounce

void main() {
  group('SearchController', () {
    late SearchController searchController;
    List<Idea> allIdeas;

    // Helper to create a dummy idea
    Idea createDummyIdea({required String id, required String title, required String content}) {
      return Idea(id: id, title: title, content: content);
    }

    setUp(() {
      searchController = SearchController();
      allIdeas = [
        createDummyIdea(id: '1', title: 'Flutter App', content: 'Build an awesome app with Flutter'),
        createDummyIdea(id: '2', title: 'Dart Basics', content: 'Learn Dart fundamentals'),
        createDummyIdea(id: '3', title: 'State Management', content: 'Explore Provider and Riverpod'),
        createDummyIdea(id: '4', title: 'Flutter Widgets', content: 'Deep dive into widgets'),
      ];
    });

    tearDown(() {
      searchController.dispose(); // Ensure debounce timer is cancelled
    });

    test('initial state is correct', () {
      expect(searchController.query, isEmpty);
      expect(searchController.searchResults, isEmpty);
      expect(searchController.isSearchActive, isFalse);
    });

    test('activateSearch sets isSearchActive to true and notifies listeners', () {
      bool listenerCalled = false;
      searchController.addListener(() => listenerCalled = true);

      searchController.activateSearch();

      expect(searchController.isSearchActive, isTrue);
      expect(listenerCalled, isTrue);
    });

    test('deactivateSearch clears query, results, sets isSearchActive to false, and notifies listeners', () {
      // Activate and set some query
      searchController.activateSearch();
      searchController.onSearchQueryChanged('test', allIdeas);

      // Use fakeAsync to ensure debounce timer completes if any
      fakeAsync((async) {
        async.elapse(const Duration(milliseconds: 301)); // Elapse debounce time
        expect(searchController.query, 'test'); // Query should be set
      });


      bool listenerCalled = false;
      searchController.addListener(() => listenerCalled = true);

      searchController.deactivateSearch();

      expect(searchController.query, isEmpty);
      expect(searchController.searchResults, isEmpty);
      expect(searchController.isSearchActive, isFalse);
      expect(listenerCalled, isTrue);
    });

    test('clearSearch behaves like deactivateSearch', () {
       searchController.activateSearch();
       searchController.onSearchQueryChanged('test', allIdeas);
       fakeAsync((async) {
        async.elapse(const Duration(milliseconds: 301));
       });

      bool listenerCalled = false;
      searchController.addListener(() => listenerCalled = true);
      searchController.clearSearch();

      expect(searchController.query, isEmpty);
      expect(searchController.searchResults, isEmpty);
      expect(searchController.isSearchActive, isFalse); // clearSearch now sets isSearchActive to false
      expect(listenerCalled, isTrue);
    });


    test('onSearchQueryChanged updates query and searchResults after debounce', () {
      fakeAsync((async) {
        bool listenerCalled = false;
        searchController.addListener(() {
          listenerCalled = true;
        });

        searchController.onSearchQueryChanged('Flutter', allIdeas);

        // Immediately after call, query and results should not have changed yet
        expect(searchController.query, isEmpty); // Query updates only after debounce
        expect(searchController.searchResults, isEmpty);
        expect(listenerCalled, isFalse);

        async.elapse(const Duration(milliseconds: 299)); // Before debounce time
        expect(searchController.query, isEmpty);
        expect(searchController.searchResults, isEmpty);
        expect(listenerCalled, isFalse);

        async.elapse(const Duration(milliseconds: 2)); // Pass debounce time (300ms total)
        expect(searchController.query, 'Flutter');
        expect(searchController.searchResults.length, 2); // "Flutter App", "Flutter Widgets"
        expect(searchController.searchResults.any((idea) => idea.id == '1'), isTrue);
        expect(searchController.searchResults.any((idea) => idea.id == '4'), isTrue);
        expect(listenerCalled, isTrue);
      });
    });

    test('onSearchQueryChanged with empty query clears results after debounce', () {
      // First, perform a search to populate results
      searchController.onSearchQueryChanged('Flutter', allIdeas);
      fakeAsync((async) {
        async.elapse(const Duration(milliseconds: 301));
        expect(searchController.searchResults, isNotEmpty);
      });

      // Then, search with an empty query
      fakeAsync((async) {
        bool listenerCalled = false;
        searchController.addListener(() => listenerCalled = true);

        searchController.onSearchQueryChanged('  ', allIdeas); // Empty query (after trim)

        async.elapse(const Duration(milliseconds: 301));
        expect(searchController.query, '');
        expect(searchController.searchResults, isEmpty);
        expect(listenerCalled, isTrue);
      });
    });

    test('onSearchQueryChanged cancels previous debounce timer', () {
      fakeAsync((async) {
        int callCount = 0;
        searchController.addListener(() {
          callCount++;
        });

        searchController.onSearchQueryChanged('Flu', allIdeas); // First call
        async.elapse(const Duration(milliseconds: 100)); // Elapse some time, but less than debounce

        searchController.onSearchQueryChanged('Flutter', allIdeas); // Second call, should cancel first

        async.elapse(const Duration(milliseconds: 299)); // Just before second debounce finishes
        // Listener should not have been called yet from the second effective search
        expect(callCount, 0, reason: "Listener should not be called before debounce of second query");

        async.elapse(const Duration(milliseconds: 2)); // Finish second debounce

        // Listener should only be called ONCE for the second, effective query ("Flutter")
        expect(callCount, 1, reason: "Listener should only be called once for the effective query");
        expect(searchController.query, 'Flutter');
        expect(searchController.searchResults.length, 2);
      });
    });

    // Fuzzy search specific tests (assuming cutoff is around 60)
    test('fuzzy search matches relevant ideas and sorts by score', () {
        // Note: fuzzywuzzy scores can vary. These are illustrative.
        // Exact scores depend on the specific strings and algorithm details.
        // The key is relative ordering and inclusion based on a reasonable cutoff.
        final ideasForFuzzy = [
            createDummyIdea(id: 'f1', title: 'Flutter App Development', content: 'How to build apps.'),
            createDummyIdea(id: 'f2', title: 'Advanced Dart', content: 'Exploring Dart language features.'),
            createDummyIdea(id: 'f3', title: 'Flatter Application', content: 'A typo, but should match "Flutter".'),
            createDummyIdea(id: 'f4', title: 'UX Design', content: 'User experience principles.'),
        ];

        fakeAsync((async) {
            searchController.onSearchQueryChanged('Fluttar App', ideasForFuzzy);
            async.elapse(const Duration(milliseconds: 301));

            expect(searchController.searchResults, isNotEmpty);
            // Expect f1 and f3 to be in results, and f1 likely before f3
            if (searchController.searchResults.isNotEmpty) {
                 expect(searchController.searchResults.any((i) => i.id == 'f1'), isTrue);
                 expect(searchController.searchResults.any((i) => i.id == 'f3'), isTrue);
                 // Check order if possible, assuming f1 scores higher than f3 for "Fluttar App"
                 if (searchController.searchResults.length >= 2 &&
                     searchController.searchResults.any((i) => i.id == 'f1') &&
                     searchController.searchResults.any((i) => i.id == 'f3')) {
                    expect(searchController.searchResults.indexWhere((i) => i.id == 'f1'),
                           lessThan(searchController.searchResults.indexWhere((i) => i.id == 'f3')));
                 }
            }
            expect(searchController.searchResults.any((i) => i.id == 'f2'), isFalse); // "Advanced Dart"
            expect(searchController.searchResults.any((i) => i.id == 'f4'), isFalse); // "UX Design"
        });
    });


  });
}
