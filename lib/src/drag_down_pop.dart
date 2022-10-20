import 'dart:ui';
import 'package:flutter/material.dart';
import 'notification.dart';

class DragDownPop extends StatefulWidget {
  final Widget child;
  final GestureTapCallback? onTap;

  final double dismissThreshold;
  final Function()? onDismiss;

  const DragDownPop({Key? key, required this.child, this.onTap, this.dismissThreshold = 0.2, this.onDismiss})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _DragDownPopState();
}

class _DragDownPopState extends State<DragDownPop> with SingleTickerProviderStateMixin {
  late AnimationController _resetAnimationController;
  final ValueNotifier<double> _scaleNotifier = ValueNotifier<double>(1.0);
  final ValueNotifier<Offset> _offsetNotifier = ValueNotifier<Offset>(Offset.zero);
  final double centerPosY = MediaQueryData.fromWindow(window).size.height * 0.5;
  Offset _resetOffset = Offset.zero;
  late Animation _resetAnimation;
  Offset? _doubleTapLocalPosition;

  @override
  void initState() {
    super.initState();
    _resetAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..addListener(() {
        double dx = _resetAnimation.value * (1 - _resetOffset.dx) + _resetOffset.dx;
        double dy = _resetAnimation.value * (1 - _resetOffset.dy) + _resetOffset.dy;
        _offsetNotifier.value = Offset(dx, dy);
        _onAnimationUpdateByOffset(true);
      });
    _resetAnimation = CurvedAnimation(
      parent: _resetAnimationController,
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: _onTap,
        onVerticalDragStart: _onVerticalDragStart,
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragCancel: _onVerticalDragCancel,
        onVerticalDragEnd: _onVerticalDragEnd,
        child: ValueListenableBuilder(
          valueListenable: _offsetNotifier,
          builder: (BuildContext context, Offset offset, Widget? child) => Transform.translate(
            offset: offset,
            child: ValueListenableBuilder(
              valueListenable: _scaleNotifier,
              builder: (BuildContext context, double scale, Widget? child) => Transform.scale(
                scale: scale,
                child: RepaintBoundary(
                  child: widget.child,
                ),
              ),
            ),
          ),
        ));
  }

  void _onVerticalDragStart(DragStartDetails details) {
    DragStartNotification(dragType: DragType.vertical).dispatch(context);
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    _offsetNotifier.value += details.delta;
    _onAnimationUpdateByOffset(false);
  }

  void _onAnimationUpdateByOffset(bool reverse) {
    var percent = _offsetNotifier.value.dy.abs() / centerPosY;

    _scaleNotifier.value = 1 - 0.5 * percent;
    DragUpdateNotification(dragType: DragType.vertical, value: percent, reverse: reverse).dispatch(context);
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    var needPop = _offsetNotifier.value.dy.abs() > 100;
    if (needPop) {
      widget.onDismiss?.call();
    } else {
      _resetOffset = _offsetNotifier.value;
      _resetAnimationController.forward(from: 0);
    }
    DragEndNotification(dragType: DragType.vertical, pop: needPop).dispatch(context);
  }

  void _onVerticalDragCancel() {}

  @override
  void dispose() {
    _resetAnimationController.dispose();
    super.dispose();
  }

  void _onTap() {
    print('_onTap');
    TapGestureNotification().dispatch(context);
    widget.onTap?.call();
  }
}
