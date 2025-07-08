import 'package:flutter/material.dart';
import 'package:minddrop/controllers/ideas_controller.dart';
import 'package:minddrop/controllers/search_controller.dart' as md;
import 'package:minddrop/controllers/theme_controller.dart';
import 'package:minddrop/screens/add_idea_screen.dart';
import 'package:minddrop/screens/edit_idea_screen.dart'; // Import EditIdeaScreen
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
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case AppRoutes.home:
                  return MaterialPageRoute(builder: (_) => const HomeScreen());
                case AppRoutes.addIdea:
                  return MaterialPageRoute(builder: (_) => const AddIdeaScreen());
                case AppRoutes.ideaDetail:
                  // IdeaDetailScreen expects an ideaId as argument
                  if (settings.arguments is String) {
                    return MaterialPageRoute(builder: (_) => const IdeaDetailScreen()); // Arguments are handled internally by ModalRoute
                  }
                  return _errorRoute(); // Invalid or missing arguments
                case AppRoutes.editIdea:
                  if (settings.arguments is String) {
                    final ideaId = settings.arguments as String;
                    return MaterialPageRoute(builder: (_) => EditIdeaScreen(ideaId: ideaId));
                  }
                  return _errorRoute(); // Invalid or missing arguments
                case AppRoutes.settings:
                  return MaterialPageRoute(builder: (_) => const SettingsScreen());
                default:
                  return _errorRoute();
              }
            },
            // routes: { // Replaced by onGenerateRoute for argument handling
            //   AppRoutes.home: (context) => const HomeScreen(),
            //   AppRoutes.addIdea: (context) => const AddIdeaScreen(),
            //   AppRoutes.ideaDetail: (context) => const IdeaDetailScreen(),
            //   AppRoutes.settings: (context) => const SettingsScreen(),
            // },
          );
        },
      ),
    );
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Page not found or invalid arguments.')),
      );
    });
  }
}
