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
      {required RoutePageBuilder pageBuilder,
      RouteSettings? settings,
      RouteTransitionsBuilder transitionsBuilder = _defaultTransitionsBuilder,
      Duration transitionDuration = const Duration(milliseconds: 300),
      Duration reverseTransitionDuration = const Duration(milliseconds: 300),
      bool barrierDismissible = false,
      bool maintainState = true})
      : super(
            pageBuilder: pageBuilder,
            transitionDuration: transitionDuration,
            reverseTransitionDuration: reverseTransitionDuration,
            barrierDismissible: barrierDismissible,
            maintainState: maintainState,
            settings: settings,
            opaque: false,
            fullscreenDialog: true);
}
