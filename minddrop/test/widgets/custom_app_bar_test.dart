import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minddrop/widgets/custom_app_bar.dart';
import 'package:minddrop/controllers/search_controller.dart' as md_search;
import 'package:minddrop/controllers/ideas_controller.dart';
import 'package:provider/provider.dart';
import '../test_helpers.dart'; // For createTestableWidget and mocks
import '../controllers/ideas_controller_test.mocks.dart'; // For MockDatabaseService


void main() {
  late MockDatabaseService mockDatabaseService;
  late IdeasController ideasController;
  late md_search.SearchController searchController;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    // It's important that controllers are fresh for each test or state is managed.
    ideasController = IdeasController(databaseService: mockDatabaseService);
    searchController = md_search.SearchController();
  });


  testWidgets('CustomAppBar displays title and search icon initially', (WidgetTester tester) async {
    await tester.pumpWidget(createTestableWidget(
      child: Scaffold(appBar: CustomAppBar(title: 'MindDrop')),
      ideasController: ideasController, // Provide controllers
      searchController: searchController,
    ));

    expect(find.text('MindDrop'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('CustomAppBar transitions to search mode on search icon tap', (WidgetTester tester) async {
    await tester.pumpWidget(createTestableWidget(
      child: Scaffold(appBar: CustomAppBar(title: 'MindDrop')),
      ideasController: ideasController,
      searchController: searchController,
    ));

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle(); // Allow state changes and rebuilds

    expect(find.text('MindDrop'), findsNothing); // Title should be replaced
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    expect(find.byIcon(Icons.clear), findsOneWidget);
    expect(searchController.isSearchActive, isTrue);
  });

  testWidgets('CustomAppBar exits search mode on back arrow tap', (WidgetTester tester) async {
    await tester.pumpWidget(createTestableWidget(
      child: Scaffold(appBar: CustomAppBar(title: 'MindDrop')),
      ideasController: ideasController,
      searchController: searchController,
    ));

    // Enter search mode
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    expect(searchController.isSearchActive, isTrue);

    // Exit search mode
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('MindDrop'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(searchController.isSearchActive, isFalse);
    expect(searchController.query, isEmpty);
  });

  testWidgets('CustomAppBar clear button clears text field or exits search mode', (WidgetTester tester) async {
    await tester.pumpWidget(createTestableWidget(
      child: Scaffold(appBar: CustomAppBar(title: 'MindDrop')),
      ideasController: ideasController,
      searchController: searchController,
    ));

    // Enter search mode
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    // Enter text
    await tester.enterText(find.byType(TextField), 'test query');
    await tester.pumpAndSettle(); // Allow controller to process

    // Wait for debounce in SearchController if it affects the query state immediately
    // For this test, we are checking TextField's controller and searchController's query
    // The onSearchQueryChanged will be called.
    // To ensure SearchController's internal query is updated for assertion:
    await tester.pump(const Duration(milliseconds: 301)); // Elapse debounce

    expect(find.widgetWithText(TextField, 'test query'), findsOneWidget);
    // Check controller's query after debounce
    expect(searchController.query, 'test query');


    // Tap clear button (should clear text)
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 301)); // Elapse debounce for empty query

    expect(find.widgetWithText(TextField, ''), findsOneWidget); // Text field is empty
    expect(searchController.query, ''); // Controller query should be empty

    // Tap clear button again (should exit search mode)
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();

    expect(find.text('MindDrop'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(searchController.isSearchActive, isFalse);
  });

  testWidgets('CustomAppBar calls SearchController.onSearchQueryChanged on text input', (WidgetTester tester) async {
     await tester.pumpWidget(createTestableWidget(
      child: Scaffold(appBar: CustomAppBar(title: 'MindDrop')),
      ideasController: ideasController,
      searchController: searchController, // Pass the instance
    ));

    // Enter search mode
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'flutter');
    await tester.pumpAndSettle(); // Let UI update
    await tester.pump(const Duration(milliseconds: 301)); // Elapse debounce

    expect(searchController.query, 'flutter');
    // Further assertions on searchController.searchResults would require mocking ideasController.ideas
    // or providing a list of ideas to searchController.onSearchQueryChanged, which it does.
  });

  testWidgets('CustomAppBar displays filter button and toggles filter', (WidgetTester tester) async {
    // Initial state: filter is off
    expect(ideasController.isFilterActive, isFalse);

    await tester.pumpWidget(createTestableWidget(
      child: Scaffold(appBar: CustomAppBar(title: 'MindDrop')),
      ideasController: ideasController,
      searchController: searchController,
    ));

    // Find initial filter icon (filter_list_rounded)
    expect(find.byIcon(Icons.filter_list_rounded), findsOneWidget);
    expect(find.byIcon(Icons.filter_list_off_rounded), findsNothing);

    // Tap filter button
    await tester.tap(find.byIcon(Icons.filter_list_rounded));
    await tester.pumpAndSettle(); // Rebuild with new icon

    // Check if filter is active and icon changed
    expect(ideasController.isFilterActive, isTrue);
    expect(find.byIcon(Icons.filter_list_off_rounded), findsOneWidget);
    expect(find.byIcon(Icons.filter_list_rounded), findsNothing);

    // Tap filter button again
    await tester.tap(find.byIcon(Icons.filter_list_off_rounded));
    await tester.pumpAndSettle();

    // Check if filter is inactive and icon reverted
    expect(ideasController.isFilterActive, isFalse);
    expect(find.byIcon(Icons.filter_list_rounded), findsOneWidget);
  });

}
