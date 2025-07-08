import 'package:flutter/material.dart';

class IdeaDetailScreen extends StatelessWidget {
  const IdeaDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Idea Details')),
      body: const Center(child: Text('Idea Detail Screen')),
    );
  }
}
