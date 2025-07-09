import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minddrop/models/random_style.dart';
import 'package:minddrop/widgets/visual_selection_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import '../test_helpers.dart'; // For createTestableWidget

// Mock ImagePicker
class MockImagePicker extends Mock implements ImagePicker {}

// Mock ImagePickerPlatform to control picked files
class MockImagePickerPlatform extends Mock with MockPlatformInterfaceMixin implements ImagePickerPlatform {
  XFile? _pickedFile;
  Error? _pickError;

  void setPickedFile(XFile? file) {
    _pickedFile = file;
    _pickError = null;
  }

  void setPickError(Error error) {
    _pickError = error;
    _pickedFile = null;
  }

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    if (_pickError != null) {
      throw _pickError!;
    }
    return _pickedFile;
  }

  // Implement other methods if VisualSelectionWidget uses them, like pickMultiImage, etc.
  // For now, only pickImage is critical.
}


void main() {
  late MockImagePickerPlatform mockImagePickerPlatform;

  setUpAll(() async {
    // Create a temporary directory for fake images
    final tempDir = await Directory.systemTemp.create('__test_visual_selection__');
    addTearDown(() async {
      await tempDir.delete(recursive: true);
    });
  });


  setUp(() {
    mockImagePickerPlatform = MockImagePickerPlatform();
    ImagePicker.platform = mockImagePickerPlatform;
  });

  testWidgets('VisualSelectionWidget initial state and displays selection buttons', (WidgetTester tester) async {
    await tester.pumpWidget(createTestableWidget(
      child: VisualSelectionWidget(onSelectionChanged: (type, value, style) {}),
    ));

    expect(find.text('Choose Visual Element (Mandatory)'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Image'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Style'), findsOneWidget);
    expect(find.text('Select an Image or Random Style'), findsOneWidget); // Initial preview text
  });

  testWidgets('VisualSelectionWidget selects image and calls onSelectionChanged', (WidgetTester tester) async {
    VisualType? selectedType;
    String? selectedValue;
    RandomStyle? selectedStyleObj;

    // Create a dummy XFile
    final fakeImagePath = '${Directory.systemTemp.path}/__test_visual_selection__/fake_image_picker.png';
    final fakeImageFile = File(fakeImagePath);
    if (!await fakeImageFile.exists()) {
      await fakeImageFile.create(recursive: true);
      await fakeImageFile.writeAsBytes([1,2,3,4,5]); // Dummy content
    }
    final xFile = XFile(fakeImagePath);
    mockImagePickerPlatform.setPickedFile(xFile);

    await tester.pumpWidget(createTestableWidget(
      child: VisualSelectionWidget(onSelectionChanged: (type, value, style) {
        selectedType = type;
        selectedValue = value;
        selectedStyleObj = style;
      }),
    ));

    await tester.tap(find.widgetWithText(ElevatedButton, 'Image'));
    await tester.pumpAndSettle(); // For modal bottom sheet to appear and pick image

    // Simulate choosing from gallery (or camera) - pickImage in widget will be called
    // The mock handles the result.
    // Need to wait for async operations in _pickImage and _saveImageLocally
    // This might involve multiple pumpAndSettle calls if there are chained futures.

    // After _pickImage completes and calls setState:
    expect(selectedType, VisualType.image);
    expect(selectedValue, isNotNull);
    expect(selectedValue, endsWith('.png')); // Check if it's a path (uuid generated)
    expect(selectedStyleObj, isNull);
    expect(find.byType(Image), findsOneWidget); // Check for Image.file preview
    expect(find.text('Select an Image or Random Style'), findsNothing);
  });

  testWidgets('VisualSelectionWidget selects random style and calls onSelectionChanged', (WidgetTester tester) async {
    VisualType? selectedType;
    String? selectedValue; // This will be the ID of the RandomStyle
    RandomStyle? selectedStyleObj;

    await tester.pumpWidget(createTestableWidget(
      child: VisualSelectionWidget(onSelectionChanged: (type, value, style) {
        selectedType = type;
        selectedValue = value;
        selectedStyleObj = style;
      }),
    ));

    await tester.tap(find.widgetWithText(ElevatedButton, 'Style'));
    await tester.pumpAndSettle();

    expect(selectedType, VisualType.randomStyle);
    expect(selectedValue, isNotNull); // Should be the ID of the style
    expect(selectedStyleObj, isA<RandomStyle>());
    expect(selectedStyleObj!.id, selectedValue);

    // Check for elements indicating style preview
    expect(find.byIcon(selectedStyleObj!.iconData), findsOneWidget); // Check for the specific icon
    expect(find.text('Select an Image or Random Style'), findsNothing);
  });

  testWidgets('VisualSelectionWidget initializes with image if provided', (WidgetTester tester) async {
    final tempDir = await Directory.systemTemp.create('test_init_img_vsw');
    final fakeInitialImagePath = '${tempDir.path}/initial_image.png';
    await File(fakeInitialImagePath).writeAsBytes([1,2,3]);

    await tester.pumpWidget(createTestableWidget(
      child: VisualSelectionWidget(
        initialVisualType: VisualType.image,
        initialVisualValue: fakeInitialImagePath,
        onSelectionChanged: (type, value, style) {},
      ),
    ));

    expect(find.byType(Image), findsOneWidget); // Image.file should be displayed
    // Check that the 'Image' button might appear selected (e.g. different background)
    final imageButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Image'));
    expect(imageButton.style?.backgroundColor?.resolve({}), equals(Theme.of(tester.element(find.byType(VisualSelectionWidget))).colorScheme.primaryContainer));

    await tempDir.delete(recursive: true);
  });

   testWidgets('VisualSelectionWidget initializes with random style if provided', (WidgetTester tester) async {
    final initialStyle = RandomStyle(
        id: 'initStyle1',
        gradientColors: [Colors.red.value, Colors.orange.value],
        beginAlignment: Alignment.centerLeft.toString(),
        endAlignment: Alignment.centerRight.toString(),
        iconDataCodePoint: Icons.wb_sunny.codePoint,
        iconDataFontFamily: Icons.wb_sunny.fontFamily,
        iconColor: Colors.yellow.value
    );

    await tester.pumpWidget(createTestableWidget(
      child: VisualSelectionWidget(
        initialVisualType: VisualType.randomStyle,
        initialVisualValue: initialStyle.id, // Pass the ID
        initialRandomStyle: initialStyle,    // Pass the full object
        onSelectionChanged: (type, value, style) {},
      ),
    ));

    expect(find.byIcon(Icons.wb_sunny), findsOneWidget); // Check for the specific icon
    final styleButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Style'));
    expect(styleButton.style?.backgroundColor?.resolve({}), equals(Theme.of(tester.element(find.byType(VisualSelectionWidget))).colorScheme.primaryContainer));
  });

}

// Helper extension for IconData comparison in tests if needed
extension IconDataMatcher on IconData {
  Finder get finder => find.byWidgetPredicate((Widget widget) => widget is Icon && widget.icon == this);
}
