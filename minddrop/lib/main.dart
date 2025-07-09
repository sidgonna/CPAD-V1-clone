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
import 'package:minddrop/utils/custom_page_route.dart'; // Import custom routes
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
              WidgetBuilder builder;
              switch (settings.name) {
                case AppRoutes.home:
                  builder = (_) => const HomeScreen();
                  break;
                case AppRoutes.addIdea:
                  builder = (_) => const AddIdeaScreen();
                  break;
                case AppRoutes.ideaDetail:
                  if (settings.arguments is String) {
                    // Arguments are handled internally by ModalRoute in IdeaDetailScreen
                    builder = (_) => const IdeaDetailScreen();
                  } else {
                    return _errorRoute(settings.name);
                  }
                  break;
                case AppRoutes.editIdea:
                  if (settings.arguments is String) {
                    final ideaId = settings.arguments as String;
                    builder = (_) => EditIdeaScreen(ideaId: ideaId);
                  } else {
                    return _errorRoute(settings.name);
                  }
                  break;
                case AppRoutes.settings:
                  builder = (_) => const SettingsScreen();
                  break;
                default:
                  return _errorRoute(settings.name);
              }
              // Use FadePageRoute for all standard routes
              return FadePageRoute(builder: builder, routeSettings: settings);
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

  static Route<dynamic> _errorRoute(String? routeName) {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Page "$routeName" not found or invalid arguments.')),
      );
    });
  }
}
