import 'package:flutter/material.dart';
import 'cart_controller.dart';

class CartScope extends InheritedNotifier<CartController> {
  const CartScope({
    super.key,
    required CartController controller,
    required super.child,
  }) : super(notifier: controller);

  static CartController of(BuildContext context) {
    final CartScope? scope =
        context.dependOnInheritedWidgetOfExactType<CartScope>();
    assert(scope != null, 'No CartScope found in context');
    return scope!.notifier!;
  }
}
