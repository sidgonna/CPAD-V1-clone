import 'package:flutter/material.dart';
import 'package:minddrop/controllers/theme_controller.dart';
import 'package:minddrop/services/database_service.dart'; // For cleanup
import 'package:package_info_plus/package_info_plus.dart'; // For app version
import 'package:provider/provider.dart';
import 'package:file_saver/file_saver.dart'; // For saving files
import 'dart:convert'; // For jsonEncode
import 'dart:typed_data'; // For Uint8List

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '...';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = 'Version ${packageInfo.version} (Build ${packageInfo.buildNumber})';
      });
    } catch (e) {
      setState(() {
        _appVersion = 'Version unknown';
      });
    }
  }

  Future<void> _performCleanup(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final dbService = DatabaseService(); // Consider providing via Provider if it has state or complex dependencies

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Cleaning up..."),
            ],
          ),
        );
      },
    );

    try {
      final count = await dbService.cleanUpOrphanedImages();
      Navigator.of(context).pop(); // Dismiss loading dialog
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('$count orphaned images cleaned.'), backgroundColor: Colors.green),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Dismiss loading dialog
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error during cleanup: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showExportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.data_object_rounded),
                title: const Text('Export as JSON'),
                onTap: () {
                  Navigator.of(bc).pop(); // Close bottom sheet
                  _exportDataAsJson(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.text_fields_rounded),
                title: const Text('Export as Plain Text'),
                onTap: () {
                  Navigator.of(bc).pop(); // Close bottom sheet
                  _exportDataAsPlainText(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _exportDataAsJson(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final dbService = DatabaseService();
    final String timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').substring(0, 19);
    final String fileName = 'minddrop_export_$timestamp.json';

    try {
      final data = await dbService.getAllDataForExport();
      final jsonString = jsonEncode(data);
      final Uint8List fileData = Uint8List.fromList(utf8.encode(jsonString));

      // Using file_saver
      String? path = await FileSaver.instance.saveFile(
          name: fileName,
          bytes: fileData,
          ext: 'json',
          mimeType: MimeType.json
      );

      if (path != null) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Data exported to JSON: $fileName'), backgroundColor: Colors.green),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('JSON Export cancelled or failed.'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error exporting JSON: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _exportDataAsPlainText(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final dbService = DatabaseService();
    final String timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').substring(0, 19);
    final String fileName = 'minddrop_export_$timestamp.txt';

    try {
      final textData = await dbService.getAllDataAsPlainText();
      final Uint8List fileData = Uint8List.fromList(utf8.encode(textData));

      String? path = await FileSaver.instance.saveFile(
          name: fileName,
          bytes: fileData,
          ext: 'txt',
          mimeType: MimeType.text
      );

      if (path != null) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Data exported to Text: $fileName'), backgroundColor: Colors.green),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Text Export cancelled or failed.'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error exporting Text: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: const Text('Theme'),
            trailing: DropdownButton<ThemeMode>(
              value: themeController.themeMode,
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('System Default'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('Light'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Dark'),
                ),
              ],
              onChanged: (ThemeMode? newMode) {
                if (newMode != null) {
                  themeController.setThemeMode(newMode);
                }
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Export Data'),
            subtitle: const Text('Save your ideas as JSON or Text.'),
            onTap: () => _showExportOptions(context),
          ),
          ListTile(
            leading: const Icon(Icons.cleaning_services_outlined),
            title: const Text('Clean Up Storage'),
            subtitle: const Text('Remove unused image files.'),
            onTap: () => _performCleanup(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About MindDrop'),
            subtitle: Text(_appVersion),
            onTap: () {
              // Could show a more detailed AboutDialog
              showAboutDialog(
                context: context,
                applicationName: 'MindDrop',
                applicationVersion: _appVersion,
                applicationLegalese: '© ${DateTime.now().year} Your Name/Company',
                children: <Widget>[
                  const SizedBox(height: 12),
                  const Text('A local-first idea management app designed with privacy and simplicity in mind.'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
