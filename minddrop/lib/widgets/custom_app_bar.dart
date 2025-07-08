import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minddrop/controllers/search_controller.dart' as md_search;
import 'package:minddrop/controllers/ideas_controller.dart';


class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? baseActions; // Renamed to avoid conflict

  const CustomAppBar({super.key, required this.title, this.baseActions});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  final TextEditingController _textEditingController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Listen to SearchController's query to update TextField if cleared externally
    // Or, more simply, SearchController can manage its own query state fully.
    // For now, _textEditingController is the source of truth for the input field.
  }

  void _startSearch(BuildContext context) {
    final searchController = Provider.of<md_search.SearchController>(context, listen: false);
    searchController.activateSearch();
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch(BuildContext context) {
    final searchController = Provider.of<md_search.SearchController>(context, listen: false);
    _textEditingController.clear();
    searchController.deactivateSearch(); // This will also clear results and query in controller
    setState(() {
      _isSearching = false;
    });
  }

  void _onSearchChanged(String query, BuildContext context) {
    final searchController = Provider.of<md_search.SearchController>(context, listen: false);
    final ideasController = Provider.of<IdeasController>(context, listen: false);
    // Pass all ideas to the search controller for filtering
    searchController.onSearchQueryChanged(query, ideasController.ideas);
  }

  @override
  void dispose(){
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchController = Provider.of<md_search.SearchController>(context, listen: true); // Listen for isSearchActive changes

    // Update _isSearching if externally controlled (e.g. back button while search is active)
    // This can create build-time state changes if not handled carefully.
    // A better way is to make SearchController the single source of truth for _isSearching.
    // For now, we use a local _isSearching flag primarily for UI construction.
    // If searchController.isSearchActive is false and local _isSearching is true, it means search was deactivated.
    if (!searchController.isSearchActive && _isSearching) {
        // Post frame callback to avoid calling setState during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
            if(mounted){ // ensure widget is still in tree
                 _stopSearch(context);
            }
        });
    }


    return AppBar(
      leading: _isSearching
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _stopSearch(context),
            )
          : null, // Default back button or drawer icon if applicable
      title: _isSearching
          ? TextField(
              controller: _textEditingController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search ideas...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7)),
              ),
              style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 18),
              onChanged: (query) => _onSearchChanged(query, context),
            )
          : Text(widget.title),
      actions: _isSearching
          ? [
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  if (_textEditingController.text.isNotEmpty) {
                    _textEditingController.clear();
                    // _onSearchChanged('', context); // Let clearSearch in controller handle it
                     final searchCtrl = Provider.of<md_search.SearchController>(context, listen: false);
                     searchCtrl.onSearchQueryChanged('', Provider.of<IdeasController>(context, listen: false).ideas);

                  } else {
                    _stopSearch(context);
                  }
                },
              ),
            ]
          : [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _startSearch(context),
              ),
              Consumer<IdeasController>( // Use Consumer to get filter state for icon
                builder: (context, ideasCtrl, _) {
                  return IconButton(
                    icon: Icon(
                      ideasCtrl.isFilterActive ? Icons.filter_list_off_rounded : Icons.filter_list_rounded,
                      color: ideasCtrl.isFilterActive ? Theme.of(context).colorScheme.primary : null,
                    ),
                    tooltip: ideasCtrl.isFilterActive ? 'Clear Filters' : 'Filter by Favorites',
                    onPressed: () {
                      ideasCtrl.toggleFilterFavorites();
                    },
                  );
                },
              ),
              ...?widget.baseActions, // Original actions
            ],
      elevation: _isSearching ? 2.0 : 0, // Add elevation when searching
      backgroundColor: _isSearching ? theme.colorScheme.surface : Colors.transparent,
      foregroundColor: theme.colorScheme.onSurface,
    );
  }
}
