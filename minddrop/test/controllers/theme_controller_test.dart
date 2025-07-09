import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minddrop/controllers/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

// Helper class for SharedPreferences testing from official docs/tests
class InMemorySharedPreferencesStore implements SharedPreferencesStore {
  InMemorySharedPreferencesStore.empty() : _data = <String, Object>{};

  final Map<String, Object> _data;

  @override
  Future<bool> clear() {
    _data.clear();
    return Future<bool>.value(true);
  }

  @override
  Future<Map<String, Object>> getAll() {
    return Future<Map<String, Object>>.value(_data);
  }

  @override
  Future<bool> remove(String key) {
    return Future<bool>.value(_data.remove(key) != null);
  }

  @override
  Future<bool> setValue(String valueType, String key, Object value) {
    _data[key] = value;
    return Future<bool>.value(true);
  }
}


void main() {
  group('ThemeController', () {
    late ThemeController themeController;

    setUp(() async {
      // Use in-memory SharedPreferences for testing
      SharedPreferencesStorePlatform.instance = InMemorySharedPreferencesStore.empty();
      SharedPreferences.setMockInitialValues({}); // Clear any previous mock values

      // SharedPreferences are loaded asynchronously in the constructor
      themeController = ThemeController();
      // Wait for async operations in constructor to complete (if any significant ones existed)
      // For ThemeController, it's mainly _loadThemePreference
      await themeController.initializationComplete;
    });

    test('initial themeMode is system', () {
      expect(themeController.themeMode, ThemeMode.system);
    });

    test('setThemeMode updates themeMode and notifies listeners', () async {
      bool listenerCalled = false;
      themeController.addListener(() {
        listenerCalled = true;
      });

      themeController.setThemeMode(ThemeMode.dark);
      expect(themeController.themeMode, ThemeMode.dark);
      expect(listenerCalled, isTrue);

      // Check persistence
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('themeMode'), 'ThemeMode.dark');
    });

    test('setThemeMode to light persists correctly', () async {
      themeController.setThemeMode(ThemeMode.light);
      expect(themeController.themeMode, ThemeMode.light);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('themeMode'), 'ThemeMode.light');
    });

    test('setThemeMode to system persists correctly', () async {
      // Set it to something else first
      themeController.setThemeMode(ThemeMode.dark);
      // Then set to system
      themeController.setThemeMode(ThemeMode.system);
      expect(themeController.themeMode, ThemeMode.system);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('themeMode'), 'ThemeMode.system');
    });

    test('loadThemePreference correctly loads saved theme', () async {
      // Save a preference directly
      SharedPreferences.setMockInitialValues({'themeMode': 'ThemeMode.light'});
      final newController = ThemeController();
      await newController.initializationComplete; // Wait for async constructor part

      expect(newController.themeMode, ThemeMode.light);

      SharedPreferences.setMockInitialValues({'themeMode': 'ThemeMode.dark'});
      final newControllerDark = ThemeController();
      await newControllerDark.initializationComplete;
      expect(newControllerDark.themeMode, ThemeMode.dark);

      // Test invalid value fallback to system
      SharedPreferences.setMockInitialValues({'themeMode': 'invalidValue'});
      final newControllerInvalid = ThemeController();
      await newControllerInvalid.initializationComplete;
      expect(newControllerInvalid.themeMode, ThemeMode.system);
    });
  });
}
