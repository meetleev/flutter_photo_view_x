import 'package:flutter/material.dart';

Widget _defaultTransitionsBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
    child: child,
  );
}

class DragGesturePageRouteBuilder<T> extends PageRouteBuilder<T> {
  DragGesturePageRouteBuilder(
      {required super.pageBuilder,
      super.settings,
      RouteTransitionsBuilder transitionsBuilder = _defaultTransitionsBuilder,
      super.transitionDuration,
      super.reverseTransitionDuration,
      super.barrierDismissible,
      super.fullscreenDialog,
      super.maintainState})
      : super(opaque: false);
}
