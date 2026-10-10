import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/shopping_list/state/shopping_planner_controller.dart';
import 'features/shopping_list/state/shopping_planner_scope.dart';
import 'features/stores/presentation/pages/store_list_page.dart';

class HandCartApp extends StatefulWidget {
  const HandCartApp({super.key});

  @override
  State<HandCartApp> createState() => _HandCartAppState();
}

class _HandCartAppState extends State<HandCartApp> {
  late final ShoppingPlannerController _plannerController;

  @override
  void initState() {
    super.initState();
    _plannerController = ShoppingPlannerController();
  }

  @override
  void dispose() {
    _plannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShoppingPlannerScope(
      controller: _plannerController,
      child: DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
          return MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(lightDynamic),
            darkTheme: AppTheme.darkTheme(darkDynamic),
            themeMode: ThemeMode.system,
            home: const StoreListPage(),
          );
        },
      ),
    );
  }
}
