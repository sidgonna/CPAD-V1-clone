import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minddrop/controllers/ideas_controller.dart';
// Assuming models and services will be used later for actual saving
import 'package:minddrop/models/idea.dart';
import 'package:minddrop/models/random_style.dart';
// import 'package:minddrop/services/database_service.dart'; // Controller handles this
import 'package:minddrop/widgets/visual_selection_widget.dart';
import 'package:uuid/uuid.dart';

class AddIdeaScreen extends StatefulWidget {
  const AddIdeaScreen({super.key});

  @override
  State<AddIdeaScreen> createState() => _AddIdeaScreenState();
}

class _AddIdeaScreenState extends State<AddIdeaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = false;

  VisualType _selectedVisualType = VisualType.none;
  String? _visualValue; // image path or RandomStyle ID
  RandomStyle? _generatedRandomStyle; // Store the actual RandomStyle object if generated

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return; // Form is not valid
    }

    if (_selectedVisualType == VisualType.none || _visualValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mandatory: Please select an Image or a Random Style.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return; // Stop submission if no visual element is selected
    }

    setState(() {
      _isLoading = true;
    });

    final ideasController = Provider.of<IdeasController>(context, listen: false);
    final newIdea = Idea(
      id: const Uuid().v4(),
      title: _titleController.text,
      content: _contentController.text,
      createdAt: DateTime.now(),
      isFavorite: false,
      imagePath: _selectedVisualType == VisualType.image ? _visualValue : null,
      randomStyleId: _selectedVisualType == VisualType.randomStyle ? _visualValue : null,
    );

    try {
      // If a random style was generated, it needs to be passed to the controller to be saved.
      // The _visualValue for a random style is its ID.
      // The VisualSelectionWidget's onSelectionChanged callback for random styles
      // should also provide the actual RandomStyle object.
      // For now, we assume _generatedRandomStyle holds this if type is randomStyle.
      await ideasController.addIdea(
        newIdea,
        randomStyle: _selectedVisualType == VisualType.randomStyle ? _generatedRandomStyle : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${newIdea.title} added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding idea: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Idea'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: Center(child: CircularProgressIndicator(color: Colors.white)),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _submitForm,
              tooltip: 'Save Idea',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter the title of your idea',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  hintText: 'Describe your idea...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the content of your idea';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              VisualSelectionWidget(
                onSelectionChanged: (type, value, randomStyle) {
                  setState(() {
                    _selectedVisualType = type;
                    _visualValue = value;
                    if (type == VisualType.randomStyle) {
                      _generatedRandomStyle = randomStyle;
                    } else {
                      _generatedRandomStyle = null;
                    }
                  });
                },
                // We can pass initial values if we implement an edit mode later
                // initialVisualType: ...,
                // initialVisualValue: ...,
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                      )
                    : const Text('Save Idea'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
