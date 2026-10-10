import 'package:flutter/material.dart';
import 'shopping_planner_controller.dart';

class ShoppingPlannerScope extends InheritedNotifier<ShoppingPlannerController> {
  const ShoppingPlannerScope({
    super.key,
    required ShoppingPlannerController controller,
    required super.child,
  }) : super(notifier: controller);

  static ShoppingPlannerController of(BuildContext context) {
    final ShoppingPlannerScope? scope =
        context.dependOnInheritedWidgetOfExactType<ShoppingPlannerScope>();
    assert(scope != null, 'No ShoppingPlannerScope found in context');
    return scope!.notifier!;
  }
}
