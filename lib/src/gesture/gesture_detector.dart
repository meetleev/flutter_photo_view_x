import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'boundary_hit_detector.dart';

class PhotoGestureDetector extends StatelessWidget {
  final GestureScaleStartCallback? onScaleStart;
  final GestureScaleUpdateCallback? onScaleUpdate;
  final GestureScaleEndCallback? onScaleEnd;

  // doubleTap
  final GestureTapDownCallback? onDoubleTapDown;
  final GestureDoubleTapCallback? onDoubleTap;

  final GestureTapDownCallback? onTapDown;
  final GestureTapUpCallback? onTapUp;
  final GestureTapCallback? onTap;

  final Widget? child;
  final HitTestBehavior? behavior;
  final bool excludeFromSemantics;
  final BoundaryHitDetector hitDetector;

  const PhotoGestureDetector(
      {super.key,
      this.onScaleStart,
      this.onScaleUpdate,
      this.onScaleEnd,
      this.child,
      this.behavior,
      this.excludeFromSemantics = false,
      required this.hitDetector,
      this.onDoubleTapDown,
      this.onDoubleTap,
      this.onTapDown,
      this.onTapUp,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    final scrollGestureDetectorProvider =
        ScrollGestureDetectorProvider.of(context);
    final Map<Type, GestureRecognizerFactory> gestures = {};
    if (null != onDoubleTapDown || null != onDoubleTap) {
      gestures[DoubleTapGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<DoubleTapGestureRecognizer>(
              () => DoubleTapGestureRecognizer(),
              (DoubleTapGestureRecognizer instance) {
        instance
          ..onDoubleTapDown = onDoubleTapDown
          ..onDoubleTap = onDoubleTap;
      });
    }
    if (null != onTapDown || null != onTapUp || null != onTap) {
      gestures[TapGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
              () => TapGestureRecognizer(), (TapGestureRecognizer instance) {
        instance
          ..onTapDown = onTapDown
          ..onTapUp = onTapUp
          ..onTap = onTap;
      });
    }
    gestures[PhotoViewGestureRecognizer] =
        GestureRecognizerFactoryWithHandlers<PhotoViewGestureRecognizer>(
            () => PhotoViewGestureRecognizer(
                debugOwner: this,
                scrollDirection: scrollGestureDetectorProvider?.scrollDirection,
                hitDetector: hitDetector),
            (PhotoViewGestureRecognizer instance) {
      instance
        ..onStart = onScaleStart
        ..onUpdate = onScaleUpdate
        ..onEnd = onScaleEnd;
    });
    return RawGestureDetector(
      behavior: behavior,
      gestures: gestures,
      excludeFromSemantics: excludeFromSemantics,
      child: child,
    );
  }
}

class PhotoViewGestureRecognizer extends ScaleGestureRecognizer {
  final Axis? scrollDirection;
  final BoundaryHitDetector hitDetector;

  PhotoViewGestureRecognizer(
      {super.debugOwner, required this.hitDetector, this.scrollDirection});
  final Map<int, Offset> _pointerLocations = <int, Offset>{};
  Offset? _lastFocalPoint;
  Offset? _currentFocalPoint;
  bool _needReset = true;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (_needReset) {
      _needReset = false;
      _pointerLocations.clear();
    }
    super.addAllowedPointer(event);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    _needReset = true;
    super.didStopTrackingLastPointer(pointer);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (null != scrollDirection) {
      _isAcceptEvent(event);
    }
    super.handleEvent(event);
  }

  void _isAcceptEvent(PointerEvent event) {
    if (event is PointerDownEvent) {
      _pointerLocations[event.pointer] = event.position;
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      _pointerLocations.remove(event.pointer);
    } else if (event is PointerMoveEvent) {
      if (!event.synthesized) {
        _pointerLocations[event.pointer] = event.position;
      }
    }
    _lastFocalPoint = _currentFocalPoint;

    //
    var offset = Offset.zero;
    for (var v in _pointerLocations.values) {
      offset += v;
    }
    var count = math.min(1, _pointerLocations.length);
    _currentFocalPoint = offset / count.toDouble();

    if (event is PointerMoveEvent) {
      final move = _lastFocalPoint! - _currentFocalPoint!;
      bool shouldMove = hitDetector.shouldMove(move, scrollDirection!);
      if (shouldMove || 1 < _pointerLocations.length) {
        acceptGesture(event.pointer);
      }
    }
  }
}

class ScrollGestureDetectorProvider extends InheritedWidget {
  final Axis scrollDirection;

  const ScrollGestureDetectorProvider(
      {super.key, required super.child, required this.scrollDirection});

  static ScrollGestureDetectorProvider? of(BuildContext context) {
    final ScrollGestureDetectorProvider? scope = context
        .dependOnInheritedWidgetOfExactType<ScrollGestureDetectorProvider>();
    return scope;
  }

  @override
  bool updateShouldNotify(covariant ScrollGestureDetectorProvider oldWidget) =>
      oldWidget.scrollDirection != scrollDirection;
}
