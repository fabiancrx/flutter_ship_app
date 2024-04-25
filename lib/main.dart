import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_ship_app/src/constants/app_colors.dart';
import 'package:flutter_ship_app/src/data/app_startup.dart';
import 'package:flutter_ship_app/src/data/shared_preferences.dart';
import 'package:flutter_ship_app/src/presentation/apps_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  // needed to read the theme mode before calling runApp
  await container.read(sharedPreferencesProvider.future);
  // run app
  runApp(UncontrolledProviderScope(
    container: container,
    child: AppStartupWidget(
      onLoaded: (context) => const MainApp(),
    ),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // https://docs.flexcolorscheme.com/
      theme: FlexThemeData.light(scheme: AppColors.flexScheme),
      darkTheme: FlexThemeData.dark(scheme: AppColors.flexScheme),
      themeMode: ThemeMode.light,
      home: const AppsListScreen(),
    );
  }
}