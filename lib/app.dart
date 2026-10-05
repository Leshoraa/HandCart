import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/cart/state/cart_controller.dart';
import 'features/cart/state/cart_scope.dart';
import 'features/home/presentation/pages/home_page.dart';

class HandCartApp extends StatefulWidget {
  const HandCartApp({super.key});

  @override
  State<HandCartApp> createState() => _HandCartAppState();
}

class _HandCartAppState extends State<HandCartApp> {
  late final CartController _cartController;

  @override
  void initState() {
    super.initState();
    _cartController = CartController();
  }

  @override
  void dispose() {
    _cartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CartScope(
      controller: _cartController,
      child: DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
          return MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(lightDynamic),
            darkTheme: AppTheme.darkTheme(darkDynamic),
            themeMode: ThemeMode.system,
            home: const HomePage(),
          );
        },
      ),
    );
  }
}
