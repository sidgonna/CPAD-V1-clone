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
  @override
  void initState() {
    super.initState();
    // Load ideas when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<IdeasController>(context, listen: false).loadIdeas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'MindDrop'),
      body: Consumer<IdeasController>(
        builder: (context, ideasController, child) {
          if (ideasController.ideas.isEmpty) {
            return const EmptyState();
          }

          return ListView.builder(
            itemCount: ideasController.ideas.length,
            itemBuilder: (context, index) {
              final idea = ideasController.ideas[index];
              return IdeaCard(idea: idea);
            },
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
