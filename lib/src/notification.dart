import 'package:flutter/material.dart';

enum DragType { vertical }

class TapGestureNotification extends Notification {
  TapGestureNotification();
}

class DragStartNotification extends Notification {
  final DragType dragType;

  DragStartNotification({required this.dragType});
}

class DragUpdateNotification extends Notification {
  final DragType dragType;
  final double value;
  final bool reverse;

  DragUpdateNotification(
      {required this.value, required this.reverse, required this.dragType});
}

class DragEndNotification extends Notification {
  final DragType dragType;
  final bool pop;

  DragEndNotification({required this.dragType, required this.pop});
}

class DragCancelNotification extends Notification {
  final DragType dragType;

  DragCancelNotification({required this.dragType});
}

class PanZoomUpdateNotification extends Notification {
  PanZoomUpdateNotification();
}

class PanZoomReachBoundaryNotification extends Notification {
  PanZoomReachBoundaryNotification();
}
