import 'package:flutter/material.dart';
import 'package:minddrop/controllers/ideas_controller.dart';
import 'package:minddrop/controllers/search_controller.dart' as md;
import 'package:minddrop/controllers/theme_controller.dart';
import 'package:minddrop/screens/add_idea_screen.dart';
import 'package:minddrop/screens/home_screen.dart';
import 'package:minddrop/screens/idea_detail_screen.dart';
import 'package:minddrop/screens/settings_screen.dart';
import 'package:minddrop/services/hive_service.dart';
import 'package:minddrop/utils/app_routes.dart';
import 'package:minddrop/utils/app_themes.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => IdeasController()),
        ChangeNotifierProvider(create: (_) => md.SearchController()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, child) {
          return MaterialApp(
            title: 'MindDrop',
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: themeController.themeMode,
            initialRoute: AppRoutes.home,
            routes: {
              AppRoutes.home: (context) => const HomeScreen(),
              AppRoutes.addIdea: (context) => const AddIdeaScreen(),
              AppRoutes.ideaDetail: (context) => const IdeaDetailScreen(),
              AppRoutes.settings: (context) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}
