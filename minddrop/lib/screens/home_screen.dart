import 'package:flutter/material.dart';
import 'package:minddrop/controllers/ideas_controller.dart';
import 'package:minddrop/utils/app_routes.dart';
import 'package:minddrop/widgets/custom_app_bar.dart';
import 'package:minddrop/widgets/empty_state.dart';
import 'package:minddrop/widgets/idea_card.dart';
import 'package:provider/provider.dart';

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
      // Accessing controller without listen: false here as it's a one-time call
      // or part of a refresh action, not for reactive UI building within this method.
      await Provider.of<IdeasController>(context, listen: false).loadIdeas();
    } catch (e) {
      // Handle error, maybe show a snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching ideas: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted && !isRefresh) { // Only set isLoading to false if it's the initial load
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'MindDrop'),
      body: Consumer<IdeasController>(
        builder: (context, ideasController, child) {
          // Handle initial loading state explicitly
          if (_isLoading && ideasController.ideas.isEmpty) { // Check _isLoading primarily for initial load
            return const Center(child: CircularProgressIndicator());
          }

          if (ideasController.ideas.isEmpty) {
            // Already loaded and still empty
            return RefreshIndicator(
              onRefresh: () => _fetchIdeas(isRefresh: true),
              child: Stack( // Stack allows EmptyState to be scrollable for RefreshIndicator
                children: [ListView(), const EmptyState()], // ListView makes it scrollable
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _fetchIdeas(isRefresh: true),
            child: ListView.builder(
              itemCount: ideasController.ideas.length,
              itemBuilder: (context, index) {
                final idea = ideasController.ideas[index];
                // Make sure IdeaCard is implemented (P2-DISPLAY-002)
                return IdeaCard(idea: idea);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addIdea);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
