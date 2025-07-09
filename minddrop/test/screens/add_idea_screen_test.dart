import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minddrop/screens/add_idea_screen.dart';
import 'package:minddrop/widgets/visual_selection_widget.dart';
import 'package:minddrop/controllers/ideas_controller.dart';
import 'package:mockito/mockito.dart';
import '../test_helpers.dart'; // This now includes MockImagePickerPlatform
import '../controllers/ideas_controller_test.mocks.dart'; // For MockDatabaseService
import 'package:image_picker/image_picker.dart'; // For XFile and ImagePicker.platform setter
import 'dart:io'; // For File

// MockImagePickerPlatform is now in test_helpers.dart

void main() {
  late MockDatabaseService mockDatabaseService;
  late IdeasController ideasController;
  late MockImagePickerPlatform mockImagePickerPlatformGlobal; // Instance from test_helpers

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    ideasController = IdeasController(databaseService: mockDatabaseService);

    // Set the global ImagePicker.platform instance for all tests in this file
    mockImagePickerPlatformGlobal = MockImagePickerPlatform();
    ImagePicker.platform = mockImagePickerPlatformGlobal;

    // Default mock behaviors
    when(mockDatabaseService.addIdea(any)).thenAnswer((_) async {});
    when(mockDatabaseService.addRandomStyle(any)).thenAnswer((_) async {});
    when(mockDatabaseService.getAllIdeas()).thenReturn([]);
  });

  testWidgets('AddIdeaScreen displays form fields and visual selection', (WidgetTester tester) async {
    await tester.pumpWidget(createTestableWidget(
      child: const AddIdeaScreen(),
      ideasController: ideasController,
    ));

    expect(find.widgetWithText(AppBar, 'Add New Idea'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Title'), findsOneWidget); // Finds by labelText
    expect(find.widgetWithText(TextFormField, 'Content'), findsOneWidget);
    expect(find.byType(VisualSelectionWidget), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Save Idea'), findsOneWidget);
  });

  testWidgets('AddIdeaScreen shows validation error for empty title', (WidgetTester tester) async {
    await tester.pumpWidget(createTestableWidget(
      child: const AddIdeaScreen(),
      ideasController: ideasController,
    ));

    await tester.tap(find.widgetWithText(ElevatedButton, 'Save Idea'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a title'), findsOneWidget);
  });

  testWidgets('AddIdeaScreen shows validation error for empty content after title is filled', (WidgetTester tester) async {
    await tester.pumpWidget(createTestableWidget(
      child: const AddIdeaScreen(),
      ideasController: ideasController,
    ));

    await tester.enterText(find.byWidgetPredicate((widget) => widget is TextFormField && widget.decoration?.labelText == 'Title'), 'Test Title');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save Idea'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter the content of your idea'), findsOneWidget);
  });

  testWidgets('AddIdeaScreen shows validation error if no visual element selected', (WidgetTester tester) async {
    await tester.pumpWidget(createTestableWidget(
      child: const AddIdeaScreen(),
      ideasController: ideasController,
    ));

    await tester.enterText(find.byWidgetPredicate((widget) => widget is TextFormField && widget.decoration?.labelText == 'Title'), 'Test Title');
    await tester.enterText(find.byWidgetPredicate((widget) => widget is TextFormField && widget.decoration?.labelText == 'Content'), 'Test Content');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Save Idea'));
    await tester.pumpAndSettle();

    expect(find.text('Mandatory: Please select an Image or a Random Style.'), findsOneWidget);
    // SnackBar is shown, verify its presence
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('AddIdeaScreen submits form successfully with image', (WidgetTester tester) async {
    // Mock image picking
    final fakeImagePath = '${Directory.systemTemp.path}/add_idea_test_img.png';
    final fakeImageFile = File(fakeImagePath);
    if(!await fakeImageFile.exists()) {
      await fakeImageFile.create(recursive: true);
      await fakeImageFile.writeAsBytes([1,2,3]);
    }
    final xFile = XFile(fakeImagePath);
    mockImagePickerPlatformGlobal.setPickedFile(xFile); // Use the global mock instance

    // Mock navigator
    final mockObserver = MockNavigatorObserver();

    await tester.pumpWidget(createTestableWidgetWithRoutes(
      initialRoute: '/test-add-idea',
      routes: {
        '/test-add-idea': (_) => const AddIdeaScreen(),
        // Add other routes if AddIdeaScreen navigates elsewhere on success (e.g. back to home)
      },
      ideasController: ideasController,
      // navigatorObservers: [mockObserver], // Need to add navigatorObservers to createTestableWidgetWithRoutes
    ));

    // Fill form
    await tester.enterText(find.byWidgetPredicate((widget) => widget is TextFormField && widget.decoration?.labelText == 'Title'), 'Idea with Image');
    await tester.enterText(find.byWidgetPredicate((widget) => widget is TextFormField && widget.decoration?.labelText == 'Content'), 'Content for image idea.');

    // Select image
    await tester.tap(find.widgetWithText(ElevatedButton, 'Image')); // In VisualSelectionWidget
    await tester.pumpAndSettle(); // For bottom sheet and image picking

    // Submit
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save Idea'));
    await tester.pumpAndSettle(); // For async submission and snackbar/navigation

    verify(mockDatabaseService.addIdea(any)).called(1);
    expect(find.text('Idea with Image added successfully!'), findsOneWidget);
    // verify(mockObserver.didPop(any, any)).called(1); // If it pops on success

    await fakeImageFile.parent.delete(recursive: true);
  });

  // TODO: Add test for submitting form successfully with Random Style
  // TODO: Add test for EditIdeaScreen pre-population and update
  // TODO: Add test for HomeScreen (displaying list, empty states for search/filter)
  // TODO: Add test for SettingsScreen interactions
  // TODO: Add test for IdeaDetailScreen
}

// Mock NavigatorObserver if not already in a shared test helper
class MockNavigatorObserver extends Mock implements NavigatorObserver {}
