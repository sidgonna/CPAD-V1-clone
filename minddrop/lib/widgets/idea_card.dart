import 'dart:io';
import 'package:flutter/material.dart';
import 'package:minddrop/models/idea.dart';
import 'package:minddrop/models/random_style.dart'; // For RandomStyle type
import 'package:minddrop/utils/app_routes.dart';
import 'package:minddrop/utils/random_style_generator.dart'; // For alignmentFromString
import 'package:provider/provider.dart'; // To potentially access controllers for actions
import 'package:minddrop/controllers/ideas_controller.dart'; // For favorite action
import 'package:transparent_image/transparent_image.dart'; // For kTransparentImage

/// A widget that displays a summary of an [Idea] in a card format.
///
/// Includes the idea's title, a preview of its content, its visual element
/// (image or random style), a favorite indicator/toggle, and navigates to
/// the [IdeaDetailScreen] on tap.
class IdeaCard extends StatelessWidget {
  /// The [Idea] to display.
  final Idea idea;

  const IdeaCard({super.key, required this.idea});

  Widget _buildVisualContent(BuildContext context) {
    if (idea.imagePath != null && idea.imagePath!.isNotEmpty) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
          child: FadeInImage(
            placeholder: MemoryImage(kTransparentImage),
            image: FileImage(File(idea.imagePath!)),
            fit: BoxFit.cover,
            imageErrorBuilder: (context, error, stackTrace) {
              return Center(
                child: Icon(
                  Icons.broken_image,
                  size: 40,
                  color: Theme.of(context).colorScheme.error,
                ),
              );
            },
            placeholderErrorBuilder: (context, error, stackTrace) {
              // Fallback for placeholder itself failing (rare for kTransparentImage)
               return Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  size: 40,
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
              );
            },
          ),
        ),
      );
    } else if (idea.randomStyle != null) {
      final style = idea.randomStyle!;
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: style.gradientColors.map((val) => Color(val)).toList(),
              begin: RandomStyleGenerator.alignmentFromString(style.beginAlignment),
              end: RandomStyleGenerator.alignmentFromString(style.endAlignment),
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
          ),
          child: Center(
            child: Icon(
              IconData(style.iconDataCodePoint,
                  fontFamily: style.iconDataFontFamily,
                  fontPackage: style.iconDataFontPackage),
              color: Color(style.iconColor),
              size: 50,
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink(); // No visual content
  }

  @override
  Widget build(BuildContext context) {
    final ideasController = Provider.of<IdeasController>(context, listen: false);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 2.0,
      clipBehavior: Clip.antiAlias, // Important for rounded corners on visual content
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.ideaDetail, arguments: idea.id);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVisualContent(context),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          idea.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          idea.isFavorite ? Icons.star : Icons.star_border,
                          color: idea.isFavorite ? Colors.amber : Theme.of(context).iconTheme.color,
                        ),
                        onPressed: () {
                          idea.isFavorite = !idea.isFavorite;
                          ideasController.updateIdea(idea); // This will save and notifyListeners
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    idea.content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    // Basic date formatting, can be improved with `intl` package
                    'Created: ${idea.createdAt.toLocal().toString().substring(0, 16)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
