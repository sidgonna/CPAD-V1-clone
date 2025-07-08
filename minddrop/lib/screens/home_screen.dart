import 'package:flutter/material.dart';
import 'package:minddrop/controllers/ideas_controller.dart';
import 'package:minddrop/utils/app_routes.dart';
import 'package:minddrop/widgets/custom_app_bar.dart';
import 'package:minddrop/widgets/empty_state.dart';
import 'package:minddrop/widgets/idea_card.dart';
import 'package:provider/provider.dart';
import 'package:minddrop/controllers/search_controller.dart' as md_search; // Alias to avoid conflict
import 'package:minddrop/models/idea.dart'; // For type hinting

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true; // Start with loading true

  @override
  void initState() {
    super.initState();
    _fetchIdeas();
  }

  Future<void> _fetchIdeas({bool isRefresh = false}) async {
    if (!isRefresh) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      await Provider.of<IdeasController>(context, listen: false).loadIdeas();
    } catch (e) {
      if (mounted) {
        // The exception from IdeasController.loadIdeas already includes "Failed to load ideas: "
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      // Ensure isLoading is set to false even if there's an error during initial load,
      // so the UI doesn't stay stuck on a global spinner. Error message will be shown.
      if (mounted && !isRefresh) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use a Consumer for SearchController to react to search status
    return Consumer<md_search.SearchController>(
      builder: (context, searchController, _) {
        return Scaffold(
          appBar: CustomAppBar(
            title: 'MindDrop',
            // Example of adding other actions to the AppBar if needed
            // baseActions: [
            //   IconButton(icon: Icon(Icons.settings), onPressed: () => Navigator.pushNamed(context, AppRoutes.settings)),
            // ],
          ),
          body: Consumer<IdeasController>(
            builder: (context, ideasController, child) {
              if (_isLoading && ideasController.ideas.isEmpty && !searchController.isSearchActive) {
                return const Center(child: CircularProgressIndicator());
              }

              final List<Idea> ideasToDisplay = searchController.isSearchActive && searchController.query.isNotEmpty
                  ? searchController.searchResults
                  : ideasController.ideas;

              final bool isDisplayingSearchResults = searchController.isSearchActive && searchController.query.isNotEmpty;
              final bool isFilterActive = ideasController.isFilterActive;

              if (ideasToDisplay.isEmpty) {
                String emptyMessage = "No ideas yet. Add one!";
                IconData emptyIcon = Icons.lightbulb_outline_rounded;
                bool showDefaultEmptyState = true;

                if (isDisplayingSearchResults) {
                  emptyMessage = 'No results found for "${searchController.query}".';
                  emptyIcon = Icons.search_off_rounded;
                  showDefaultEmptyState = false; // Custom text, no main CTA needed
                } else if (isFilterActive) {
                  emptyMessage = 'No favorite ideas found.';
                  emptyIcon = Icons.star_outline_rounded;
                  // Still use EmptyState, but with a specific message.
                  // The default CTA in EmptyState might still be relevant (to add any idea).
                  // Or we could pass a custom CTA like "Clear filter".
                } else if (searchController.isSearchActive && searchController.query.isEmpty) {
                   // Actively searching but query is empty, show "type to search" or similar
                  return Center(
                    child: Text(
                      'Type to search ideas...',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                // For other empty cases (not searching, no filter, but still no ideas)
                // the default EmptyState is fine.

                if (showDefaultEmptyState) {
                  return RefreshIndicator(
                    onRefresh: () => _fetchIdeas(isRefresh: true),
                    // Pass specific message/icon if needed, or let EmptyState use defaults
                    child: Stack(children: [ListView(), EmptyState(message: emptyMessage, icon: emptyIcon)]),
                  );
                } else {
                   return Center( // For "no search results"
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(emptyIcon, size: 60, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            emptyMessage,
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }
              }

              return Column( // Wrap ListView in a Column to add the count above it
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isDisplayingSearchResults)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        '${ideasToDisplay.length} result(s) for "${searchController.query}"',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => _fetchIdeas(isRefresh: true),
                      child: ListView.builder(
                        itemCount: ideasToDisplay.length,
                        itemBuilder: (context, index) {
                          final idea = ideasToDisplay[index];
                          return IdeaCard(idea: idea);
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          floatingActionButton: searchController.isSearchActive
              ? null // Hide FAB when searching
              : FloatingActionButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.addIdea);
                  },
                  child: const Icon(Icons.add),
                ),
        );
      },
    );
  }
}
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addIdea);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
