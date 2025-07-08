import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:minddrop/models/random_style.dart';
import 'package:minddrop/utils/random_style_generator.dart';
// Import DatabaseService if saving the style directly here, or pass it up.
// For now, we generate and pass RandomStyle object's ID or its properties.
// Let's assume for now that the style object itself isn't saved yet,
// but its properties are generated and the preview is built.
// The actual saving of RandomStyle to Hive will be handled by IdeasController/DatabaseService.

enum VisualType { none, image, randomStyle }

class VisualSelectionWidget extends StatefulWidget {
  // Callback now includes an optional RandomStyle object
  final Function(VisualType type, String? value, RandomStyle? randomStyle) onSelectionChanged;
  final VisualType initialVisualType;
  final String? initialVisualValue; // image path or RandomStyle ID
  final RandomStyle? initialRandomStyle; // Full RandomStyle object if type is randomStyle

  const VisualSelectionWidget({
    super.key,
    required this.onSelectionChanged,
    this.initialVisualType = VisualType.none,
    this.initialVisualValue,
    this.initialRandomStyle,
  });

  @override
  State<VisualSelectionWidget> createState() => _VisualSelectionWidgetState();
}

class _VisualSelectionWidgetState extends State<VisualSelectionWidget> {
  VisualType _selectedType = VisualType.none;
  String? _selectedValue; // For image path or RandomStyle ID
  File? _pickedImageFile; // To hold the picked image file for preview
  RandomStyle? _generatedStyle; // To hold the generated style for preview

  final ImagePicker _picker = ImagePicker();
  // Uuid is already used in _saveImageLocally, RandomStyleGenerator also uses its own.

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialVisualType;
    _selectedValue = widget.initialVisualValue; // This is image path or RandomStyle ID

    if (_selectedType == VisualType.image && _selectedValue != null) {
      _pickedImageFile = File(_selectedValue!);
      _generatedStyle = null;
    } else if (_selectedType == VisualType.randomStyle && widget.initialRandomStyle != null) {
      _generatedStyle = widget.initialRandomStyle;
      _pickedImageFile = null;
    } else {
      // Default to none or handle error if inconsistent initial values are passed
      _selectedType = VisualType.none;
      _selectedValue = null;
      _pickedImageFile = null;
      _generatedStyle = null;
    }
  }

  Future<String?> _saveImageLocally(XFile imageXFile) async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String imagesDirPath = '${appDocDir.path}/idea_images';
      final Directory imagesDir = Directory(imagesDirPath);
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final String fileExtension = imageXFile.path.split('.').last;
      final String uniqueFileName = '${_uuid.v4()}.$fileExtension';
      final String localFilePath = '$imagesDirPath/$uniqueFileName';

      final File imageFile = File(imageXFile.path);

      // Compress image
      final XFile? compressedXFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        '$imagesDirPath/temp_${uniqueFileName}', // temp path for compressed file
        quality: 80, // Adjust quality as needed
        minWidth: 1024, // Adjust dimensions as needed
        minHeight: 1024,
      );

      if (compressedXFile == null) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image compression failed.')),
        );
        return null;
      }

      // Move compressed file to final path
      await File(compressedXFile.path).rename(localFilePath);

      return localFilePath;
    } catch (e) {
      debugPrint('Error saving image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving image: $e')),
      );
      return null;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedXFile = await _picker.pickImage(source: source);
      if (pickedXFile != null) {
        final String? savedPath = await _saveImageLocally(pickedXFile);
        if (savedPath != null) {
          setState(() {
            _selectedType = VisualType.image;
            _selectedValue = savedPath;
            _pickedImageFile = File(savedPath);
            _stylePreview = null; // This was a typo, should be _generatedStyle
            _generatedStyle = null;
          });
          widget.onSelectionChanged(_selectedType, _selectedValue, null); // Pass null for RandomStyle
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image selected and saved: $savedPath')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () {
                    _pickImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  }),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }


  void _handleRandomStyleSelection() {
    // This will be implemented in P2-CREATE-004 (Random Style Generator)
    // Generate a new style
    _generatedStyle = RandomStyleGenerator.generate();

    setState(() {
      _selectedType = VisualType.randomStyle;
      // The _selectedValue will be the ID of the RandomStyle object.
      // This ID will be used to fetch the style from the database later.
      _selectedValue = _generatedStyle!.id;
      _pickedImageFile = null; // Clear any selected image
    });

    // Pass the ID of the generated style. The parent widget (AddIdeaScreen)
    // will be responsible for ensuring this RandomStyle object is saved
    // to Hive before the Idea itself is saved.
    widget.onSelectionChanged(_selectedType, _selectedValue, _generatedStyle);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Random Style generated. ID: ${_generatedStyle!.id}')),
    );
  }

  Widget _buildStylePreview(RandomStyle style) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: style.gradientColors.map((val) => Color(val)).toList(),
          begin: RandomStyleGenerator.alignmentFromString(style.beginAlignment),
          end: RandomStyleGenerator.alignmentFromString(style.endAlignment),
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(
        child: Icon(
          IconData(style.iconDataCodePoint, fontFamily: style.iconDataFontFamily, fontPackage: style.iconDataFontPackage),
          color: Color(style.iconColor),
          size: 50,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Visual Element (Mandatory)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.image_search),
                label: const Text('Image'),
                onPressed: () => _showImageSourceActionSheet(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedType == VisualType.image
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.palette_outlined),
                label: const Text('Style'),
                onPressed: _handleRandomStyleSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedType == VisualType.randomStyle
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        // Preview area
        if (_selectedType != VisualType.none)
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Center(
              child: _selectedType == VisualType.image
                  ? (_pickedImageFile != null
                      ? Image.file(_pickedImageFile!, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                      : const Text('Image Preview Area'))
                  : (_generatedStyle != null
                      ? _buildStylePreview(_generatedStyle!)
                      : const Text('Style Preview Area')),
            ),
          )
        else
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Center(
              child: Text(
                'Select an Image or Random Style',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          ),
      ],
    );
  }
}
