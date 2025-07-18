import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minddrop/controllers/ideas_controller.dart';
import 'package:minddrop/controllers/search_controller.dart' as md_search;
import 'package:minddrop/controllers/theme_controller.dart';
import 'package:minddrop/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Use the generated mock from ideas_controller_test.dart
import 'controllers/ideas_controller_test.mocks.dart';

import 'package:image_picker/image_picker.dart'; // For XFile and ImageSource
import 'package:plugin_platform_interface/plugin_platform_interface.dart'; // For MockPlatformInterfaceMixin

// Helper for SharedPreferences from theme_controller_test.dart
class InMemorySharedPreferencesStore implements SharedPreferencesStorePlatform {
  InMemorySharedPreferencesStore.empty() : _data = <String, Object>{};
  final Map<String, Object> _data;
  @override
  Future<bool> clear() { _data.clear(); return Future.value(true); }
  @override
  Future<Map<String, Object>> getAll() { return Future.value(_data); }
  @override
  Future<bool> remove(String key) { _data.remove(key); return Future.value(true); }
  @override
  Future<bool> setValue(String valueType, String key, Object value) { _data[key] = value; return Future.value(true); }
}

// Mock ImagePickerPlatform to control picked files in tests
class MockImagePickerPlatform extends Mock with MockPlatformInterfaceMixin implements ImagePickerPlatform {
  XFile? _pickedFile;
  List<XFile>? _pickedMultiImageFiles;
  Error? _pickError;

  void setPickedFile(XFile? file) {
    _pickedFile = file;
    _pickError = null;
  }

  void setPickedMultiImageFiles(List<XFile>? files) {
    _pickedMultiImageFiles = files;
    _pickError = null;
  }

  void setPickError(Error error) {
    _pickError = error;
    _pickedFile = null;
    _pickedMultiImageFiles = null;
  }

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    if (_pickError != null) throw _pickError!;
    return _pickedFile;
  }

  @override
  Future<List<XFile>?> pickMultiImage({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    if (_pickError != null) throw _pickError!;
    return _pickedMultiImageFiles;
  }
}


/// Wraps a widget with MaterialApp and necessary Providers for testing.
Widget createTestableWidget({
  required Widget child,
  MockDatabaseService? mockDatabaseService,
  ThemeController? themeController,
  IdeasController? ideasController,
  md_search.SearchController? searchController,
}) {
  final mockDB = mockDatabaseService ?? MockDatabaseService();

  // Ensure SharedPreferences are mocked for ThemeController if not provided
  SharedPreferencesStorePlatform.instance = InMemorySharedPreferencesStore.empty();
  SharedPreferences.setMockInitialValues({});

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<ThemeController>(
        create: (_) => themeController ?? ThemeController(),
      ),
      ChangeNotifierProvider<IdeasController>(
        create: (_) => ideasController ?? IdeasController(databaseService: mockDB),
      ),
      ChangeNotifierProvider<md_search.SearchController>(
        create: (_) => searchController ?? md_search.SearchController(),
      ),
    ],
    child: MaterialApp(
      home: child,
      // Define routes if tests involve navigation
      // onGenerateRoute: (settings) { ... }
    ),
  );
}

// You might also want a version for testing specific routes with arguments:
Widget createTestableWidgetWithRoutes({
  required String initialRoute,
  Map<String, WidgetBuilder>? routes,
  RouteFactory? onGenerateRoute,
  MockDatabaseService? mockDatabaseService,
  ThemeController? themeController,
  IdeasController? ideasController,
  md_search.SearchController? searchController,
}) {
  final mockDB = mockDatabaseService ?? MockDatabaseService();
  SharedPreferencesStorePlatform.instance = InMemorySharedPreferencesStore.empty();
  SharedPreferences.setMockInitialValues({});

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<ThemeController>(
        create: (_) => themeController ?? ThemeController(),
      ),
      ChangeNotifierProvider<IdeasController>(
        create: (_) => ideasController ?? IdeasController(databaseService: mockDB),
      ),
      ChangeNotifierProvider<md_search.SearchController>(
        create: (_) => searchController ?? md_search.SearchController(),
      ),
    ],
    child: MaterialApp(
      initialRoute: initialRoute,
      routes: routes, // Simplified for direct route testing
      onGenerateRoute: onGenerateRoute, // For more complex routing with arguments
    ),
  );
}
