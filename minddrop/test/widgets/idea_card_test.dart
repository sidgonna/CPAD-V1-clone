import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minddrop/models/idea.dart';
import 'package:minddrop/models/random_style.dart';
import 'package:minddrop/widgets/idea_card.dart';
import 'package:mockito/mockito.dart';
import '../test_helpers.dart'; // Assuming MockDatabaseService is accessible or re-mocked here
import '../controllers/ideas_controller_test.mocks.dart'; // For MockDatabaseService
import 'package:minddrop/controllers/ideas_controller.dart'; // Actual controller
import 'package:provider/provider.dart';

// To avoid conflicts with material.Icons if Icons class is defined in tests
import 'package:flutter/src/widgets/icon_data.dart' as material_icons;


void main() {
  late MockDatabaseService mockDatabaseService;
  late IdeasController ideasController;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    ideasController = IdeasController(databaseService: mockDatabaseService);
    // Mock the methods that IdeaCard might indirectly cause to be called if deep
    when(mockDatabaseService.updateIdea(any)).thenAnswer((_) async {});
    when(mockDatabaseService.getAllIdeas()).thenReturn([]); // Default for loadIdeas
  });


  Idea createTestIdea({
    String id = '1',
    String title = 'Test Title',
    String content = 'Test content preview here, could be longer.',
    bool isFavorite = false,
    String? imagePath,
    String? randomStyleId,
  }) {
    return Idea(
      id: id,
      title: title,
      content: content,
      isFavorite: isFavorite,
      imagePath: imagePath,
      randomStyleId: randomStyleId,
    );
  }

  RandomStyle createTestRandomStyle(String id) {
    return RandomStyle(
      id: id,
      gradientColors: [Colors.blue.value, Colors.green.value],
      beginAlignment: Alignment.topLeft.toString(),
      endAlignment: Alignment.bottomRight.toString(),
      iconDataCodePoint: material_icons.Icons.lightbulb_outline.codePoint,
      iconDataFontFamily: material_icons.Icons.lightbulb_outline.fontFamily,
      iconColor: Colors.white.value,
    );
  }

  testWidgets('IdeaCard displays title, content, and date', (WidgetTester tester) async {
    final idea = createTestIdea();

    await tester.pumpWidget(createTestableWidget(child: IdeaCard(idea: idea), ideasController: ideasController));

    expect(find.text('Test Title'), findsOneWidget);
    expect(find.textContaining('Test content preview here'), findsOneWidget); // Using textContaining for previews
    expect(find.textContaining('Created:'), findsOneWidget);
  });

  testWidgets('IdeaCard displays favorite star correctly (not favorited)', (WidgetTester tester) async {
    final idea = createTestIdea(isFavorite: false);
    await tester.pumpWidget(createTestableWidget(child: IdeaCard(idea: idea), ideasController: ideasController));
    expect(find.byIcon(material_icons.Icons.star_border), findsOneWidget);
    expect(find.byIcon(material_icons.Icons.star), findsNothing);
  });

  testWidgets('IdeaCard displays favorite star correctly (favorited)', (WidgetTester tester) async {
    final idea = createTestIdea(isFavorite: true);
    await tester.pumpWidget(createTestableWidget(child: IdeaCard(idea: idea), ideasController: ideasController));
    expect(find.byIcon(material_icons.Icons.star), findsOneWidget);
    expect(find.byIcon(material_icons.Icons.star_border), findsNothing);
  });

  testWidgets('IdeaCard favorite star toggles when tapped', (WidgetTester tester) async {
    final idea = createTestIdea(isFavorite: false);

    // Provide the specific IdeasController instance that will be modified
    await tester.pumpWidget(createTestableWidget(child: IdeaCard(idea: idea), ideasController: ideasController));

    expect(find.byIcon(material_icons.Icons.star_border), findsOneWidget);

    await tester.tap(find.byIcon(material_icons.Icons.star_border));
    await tester.pumpAndSettle(); // Allow for state changes and rebuilds

    // Verify controller method was called
    verify(mockDatabaseService.updateIdea(any)).called(1);

    // The card itself rebuilds based on the idea object passed to it.
    // If ideasController.updateIdea internally calls notifyListeners which updates the idea instance
    // that HomeScreen holds, then the card would get the new idea.
    // For this isolated test, we check the interaction. A fuller test in HomeScreen_test would verify UI change.
    // To see the star change in THIS test, the 'idea' object itself needs to change, or we need to pump a new widget.
    // The current setup tests the interaction.
  });

  // Test for image display (requires mock file system or skipping if File operations are problematic in test env)
  // For now, we'll assume imagePath means it *should* try to render an image.
  testWidgets('IdeaCard attempts to display image if imagePath is provided', (WidgetTester tester) async {
    // Create a dummy file for testing. This is tricky in pure widget tests without platform channels.
    // We'll test for the presence of FadeInImage, assuming it handles file loading/errors.
    final tempDir = await Directory.systemTemp.createTemp('test_img');
    final fakeImageFile = File('${tempDir.path}/fake_image.png');
    await fakeImageFile.writeAsBytes([1,2,3]); // Minimal content for a file to exist

    final ideaWithImage = createTestIdea(imagePath: fakeImageFile.path);

    await tester.pumpWidget(createTestableWidget(child: IdeaCard(idea: ideaWithImage), ideasController: ideasController));

    expect(find.byType(FadeInImage), findsOneWidget);

    await tempDir.delete(recursive: true);
  });

  testWidgets('IdeaCard displays random style if randomStyle is provided', (WidgetTester tester) async {
    final style = createTestRandomStyle('style1');
    final ideaWithStyle = createTestIdea(randomStyleId: 'style1');
    when(mockDatabaseService.getRandomStyle('style1')).thenReturn(style);

    await tester.pumpWidget(createTestableWidget(child: IdeaCard(idea: ideaWithStyle), ideasController: ideasController));

    // Check for elements indicative of style rendering, e.g., a Container with a gradient
    // and an Icon that matches the style's icon.
    expect(find.byIcon(material_icons.Icons.lightbulb_outline), findsOneWidget);
    // More specific checks could look for a DecoratedBox with a Gradient.
    final decoratedBoxFinder = find.byWidgetPredicate((widget) =>
        widget is AspectRatio && widget.aspectRatio == 16/9 &&
        widget.child is Container && (widget.child as Container).decoration is BoxDecoration &&
        ((widget.child as Container).decoration as BoxDecoration).gradient is LinearGradient
    );
    expect(decoratedBoxFinder, findsOneWidget);
  });

  // Test navigation on tap - requires a Navigator and routes.
  testWidgets('IdeaCard navigates on tap', (WidgetTester tester) async {
    final idea = createTestIdea();
    bool navigated = false;

    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider( // Need providers for the IdeaCard's context
          providers: [
            ChangeNotifierProvider<IdeasController>.value(value: ideasController),
            // Add other necessary providers if IdeaCard or its children depend on them directly
          ],
          child: Scaffold(body: IdeaCard(idea: idea)),
        ),
        onGenerateRoute: (settings) {
          if (settings.name == '/idea-detail') { // AppRoutes.ideaDetail
            navigated = true;
            expect(settings.arguments, idea.id);
            return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Detail Screen')));
          }
          return null;
        },
      )
    );

    await tester.tap(find.byType(IdeaCard));
    await tester.pumpAndSettle(); // Allow navigation to complete

    expect(navigated, isTrue);
  });
}
