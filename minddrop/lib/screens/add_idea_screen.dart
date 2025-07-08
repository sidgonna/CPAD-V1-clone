import 'package:flutter/material.dart';

class AddIdeaScreen extends StatelessWidget {
  const AddIdeaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Idea')),
      body: const Center(child: Text('Add Idea Screen')),
    );
  }
}
