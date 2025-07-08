import 'dart:io';
import 'package:flutter/material.dart';
import 'package:minddrop/models/idea.dart';
import 'package:minddrop/controllers/ideas_controller.dart';
import 'package:minddrop/utils/random_style_generator.dart'; // For alignmentFromString
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart'; // For kTransparentImage
// Placeholder for EditIdeaScreen route - will be created in P2-CRUD-001
// import 'package:minddrop/utils/app_routes.dart';

class IdeaDetailScreen extends StatelessWidget {
  const IdeaDetailScreen({super.key});

  Widget _buildVisualContent(BuildContext context, Idea idea) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Make visual content larger on detail screen
    final double visualHeight = screenWidth * (9 / 16); // Maintain 16:9 aspect ratio

    if (idea.imagePath != null && idea.imagePath!.isNotEmpty) {
      return Container(
        width: screenWidth,
        height: visualHeight,
        child: FadeInImage(
          placeholder: MemoryImage(kTransparentImage),
          image: FileImage(File(idea.imagePath!)),
          fit: BoxFit.cover,
          imageErrorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(
                Icons.broken_image,
                size: 60,
                color: Theme.of(context).colorScheme.error,
              ),
            );
          },
          placeholderErrorBuilder: (context, error, stackTrace) {
             return Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 60,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
            );
          },
        ),
      );
    } else if (idea.randomStyle != null) {
      final style = idea.randomStyle!;
      return Container(
        width: screenWidth,
        height: visualHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: style.gradientColors.map((val) => Color(val)).toList(),
            begin: RandomStyleGenerator.alignmentFromString(style.beginAlignment),
            end: RandomStyleGenerator.alignmentFromString(style.endAlignment),
          ),
        ),
        child: Center(
          child: Icon(
            IconData(style.iconDataCodePoint,
                fontFamily: style.iconDataFontFamily,
                fontPackage: style.iconDataFontPackage),
            color: Color(style.iconColor),
            size: 80, // Larger icon for detail view
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final ideaId = ModalRoute.of(context)?.settings.arguments as String?;
    final ideasController = Provider.of<IdeasController>(context);

    if (ideaId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Idea ID not provided.')),
      );
    }

    // Find the idea. Note: If ideas list can be large, direct fetching by ID might be better.
    // IdeasController.getIdeaById(id) or similar would be more efficient.
    // For now, assume the idea is in the list loaded by HomeScreen.
    // A more robust way: ideasController.ideas.firstWhere((i) => i.id == ideaId, orElse: () => null);
    // Or even better, a dedicated method in IdeasController: getIdeaById(ideaId)

    // Let's make IdeasController responsible for providing a single idea
    // For this, we'll assume IdeasController has a method `getIdeaById(String id)`
    // or we enhance the consumer to watch a specific idea.
    // For simplicity, let's use a method in controller. (This needs adding to controller)

    // Attempt to find the idea in the current list of ideas.
    // This relies on the list being up-to-date.
    Idea? idea;
    try {
      idea = ideasController.ideas.firstWhere((i) => i.id == ideaId);
    } catch (e) {
      // Idea not found in the current list, could be an issue or deleted.
      idea = null;
    }


    if (idea == null) {
      // Attempt to fetch from DB directly if not in current controller list (e.g., deep link)
      // This is a simplified approach. A better way would be for the controller to handle this.
      // final dbIdea = DatabaseService().getIdea(ideaId); // This is synchronous, ensure getIdea in DBService is too or make this async
      // For now, if not in controller's list, show not found.
      return Scaffold(
        appBar: AppBar(title: const Text('Not Found')),
        body: const Center(child: Text('Idea not found or may have been deleted.')),
      );
    }

    // The favorite status on this screen should react to changes from the IconButton.
    // So, we consume the IdeasController to rebuild when the specific idea changes.
    // A more granular approach: use Selector for the specific idea.

    return Scaffold(
      // appBar: AppBar(title: Text(idea.title)), // Title can be long, let it be in body
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.width * (9 / 16), // Visual content height
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(idea.title, style: const TextStyle(fontSize: 16.0)), // Smaller title for app bar
              background: _buildVisualContent(context, idea),
            ),
            actions: [
              IconButton(
                icon: Icon(idea.isFavorite ? Icons.star : Icons.star_border),
                color: idea.isFavorite ? Colors.amber : Colors.white,
                tooltip: 'Favorite',
                onPressed: () {
                  idea.isFavorite = !idea.isFavorite;
                  ideasController.updateIdea(idea);
                },
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit Idea',
                onPressed: () {
                  // TODO: Navigate to EditIdeaScreen (P2-CRUD-001)
                  // Navigator.pushNamed(context, AppRoutes.editIdea, arguments: idea.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit functionality to be implemented.'))
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: 'Delete Idea',
                onPressed: () async {
                  // TODO: Implement delete with confirmation (P2-CRUD-002)
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Confirm Deletion'),
                      content: Text('Are you sure you want to delete "${idea.title}"?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                        TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await ideasController.deleteIdea(idea.id);
                    if (Navigator.canPop(context)) Navigator.pop(context); // Go back after deletion
                  }
                },
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  idea.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Created: ${idea.createdAt.toLocal().toString().substring(0, 16)} | Updated: ${idea.updatedAt.toLocal().toString().substring(0, 16)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                SelectableText(
                  idea.content,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 50), // Extra space at the bottom
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
