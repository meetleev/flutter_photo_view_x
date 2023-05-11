import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'notification.dart';

class DragDownPop extends StatefulWidget {
  final Widget child;
  final Function()? onDismiss;

  const DragDownPop({
    Key? key,
    required this.child,
    this.onDismiss,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => DragDownPopState();
}

class DragDownPopState extends State<DragDownPop> with SingleTickerProviderStateMixin {
  late AnimationController _resetAnimationController;
  final ValueNotifier<double> _scaleNotifier = ValueNotifier<double>(1.0);
  final ValueNotifier<Offset> _offsetNotifier = ValueNotifier<Offset>(Offset.zero);
  double _centerPosY = 0;
  Offset _resetOffset = Offset.zero;
  late Animation _resetAnimation;
  double _beginScale = 1;
  final GlobalKey _childKey = GlobalKey();
  RenderBox? _renderBox;

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
        _onAnimationUpdateReverseByOffset();
      });
    _resetAnimation = CurvedAnimation(
      parent: _resetAnimationController,
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _offsetNotifier,
      builder: (BuildContext context, Offset offset, Widget? child) => Transform.translate(
        offset: offset,
        child: ValueListenableBuilder(
          valueListenable: _scaleNotifier,
          builder: (BuildContext context, double scale, Widget? child) => Transform.scale(
            scale: scale,
            child: RepaintBoundary(
              key: _childKey,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }

  void onVerticalDragStart(DragStartDetails details) {
    _beginScale = _scaleNotifier.value;
    DragStartNotification(dragType: DragType.vertical).dispatch(context);
  }

  void onPanUpdate(DragUpdateDetails details) {
    _offsetNotifier.value += details.delta;
    _renderBox ??= _childKey.currentContext?.findRenderObject() as RenderBox?;
    var pos = _renderBox?.localToGlobal(Offset.zero);
    // var _renderBoxCenterPosY =pos.dy;
    // print('renderObj---$pos--');
    0 < pos!.dy ? _onAnimationUpdateByOffset() : _onAnimationUpdateReverseByOffset();
  }

  void _onAnimationUpdateReverseByOffset() {
    var percent = _offsetNotifier.value.dy.abs() / _centerPosY;
    // print('percent---$percent');
    var lastScale = _scaleNotifier.value;
    if (lastScale != _beginScale) {
      // print('need reverse---$lastScale');
      var scaleOffset = lastScale + 0.5 * percent;
      _scaleNotifier.value = math.min(_beginScale, scaleOffset);
      double fixPercent = _beginScale < scaleOffset ? 0 : percent;
      DragUpdateNotification(dragType: DragType.vertical, value: fixPercent, reverse: true).dispatch(context);
    }
  }

  void _onAnimationUpdateByOffset() {
    var percent = _offsetNotifier.value.dy.abs() / _centerPosY;
    _scaleNotifier.value = 1 - 0.5 * percent;
    DragUpdateNotification(dragType: DragType.vertical, value: percent, reverse: false).dispatch(context);
  }

  void onVerticalDragEnd(DragEndDetails details) {
    // print('_offsetNotifier.value.dy--||| ${_offsetNotifier.value.dy}');
    var needPop = _offsetNotifier.value.dy > 100;
    // print('needPop---$needPop');
    if (needPop) {
      widget.onDismiss?.call();
    } else {
      _resetOffset = _offsetNotifier.value;
      _resetAnimationController.forward(from: 0);
    }
    DragEndNotification(dragType: DragType.vertical, pop: needPop).dispatch(context);
  }

  @override
  void dispose() {
    _resetAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _centerPosY = MediaQueryData.fromView(View.of(context)).size.height * 0.5;
  }
}
