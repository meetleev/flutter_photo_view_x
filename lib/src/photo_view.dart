import 'package:flutter/widgets.dart';
import 'package:photo_view_x/src/gesture/boundary_hit_detector.dart';

import 'drag_down_pop.dart';
import 'notification.dart';
import 'widget/interactive_viewer.dart';

enum _PanDirection {
  none,
  // horizontal,
  vertical,
}

class PhotoView extends StatefulWidget {
  final Widget child;
  final GestureTapCallback? onTap;
  final bool tapEnabled;
  final Function()? onDismiss;
  final double maxScale;

  final double minScale;
  const PhotoView(
      {super.key,
      required this.child,
      this.onTap,
      required this.tapEnabled,
      this.onDismiss,
      this.maxScale = 2.5,
      this.minScale = 1});

  @override
  State<StatefulWidget> createState() => PhotoViewState();
}

class PhotoViewState extends State<PhotoView>
    with SingleTickerProviderStateMixin {
  // Offset? _doubleTapLocalPosition;
  // late AnimationController _animateController;
  // Animation<Matrix4>? _animation;
  // final TransformationController _transformationController = TransformationController();
  final GlobalKey<DragDownPopState> _dragDownPopKey = GlobalKey();

  bool _isPanEvent(int pointerCount, [double scale = 1.0]) =>
      1 == pointerCount && 1.0 == scale;
  _PanDirection _panDirection = _PanDirection.none;
  double? _scale;
  late Size _screenSize;

  @override
  void initState() {
    super.initState();
    /*_animateController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..addListener(() {
        _transformationController.value = _animation?.value ?? Matrix4.identity();
      });*/
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screenSize = MediaQuery.of(context).size;
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewerX(
        onTap: widget.tapEnabled ? _onTap : null,
        onInteractionStart: _onInteractionStart,
        onInteractionUpdate: _onInteractionUpdate,
        onInteractionEnd: _onInteractionEnd,
        onScaleChange: _onScaleChange,
        scaleBoundaries:
            ScaleBoundaries(childSize: _screenSize, outerSize: _screenSize),
        child: DragDownPop(
          key: _dragDownPopKey,
          onDismiss: widget.onDismiss,
          child: widget.child,
        ));
  }

  /*void _onDoubleTap() {
    Matrix4 matrix = _transformationController.value.clone();
    // print('_onDoubleTap---${_transformationController.value.toString()}');
    double currentScale = matrix.row0.x;

    double targetScale = widget.minScale;

    if (currentScale <= widget.minScale) {
      targetScale = widget.maxScale * 0.7;
    }

    double offSetX = targetScale == 1.0 ? 0.0 : -_doubleTapLocalPosition!.dx * (targetScale - 1);
    double offSetY = targetScale == 1.0 ? 0.0 : -_doubleTapLocalPosition!.dy * (targetScale - 1);

    matrix = Matrix4.fromList([
      targetScale,
      matrix.row1.x,
      matrix.row2.x,
      matrix.row3.x,
      matrix.row0.y,
      targetScale,
      matrix.row2.y,
      matrix.row3.y,
      matrix.row0.z,
      matrix.row1.z,
      targetScale,
      matrix.row3.z,
      offSetX,
      offSetY,
      matrix.row2.w,
      matrix.row3.w
    ]);

    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: matrix,
    ).animate(
      CurveTween(curve: Curves.easeOut).animate(_animateController),
    );
    _animateController.forward(from: 0);
  }*/

  void _onInteractionStart(ScaleStartDetails details) {
    // print('_onInteractionStart---$details');
    if (_isPanEvent(details.pointerCount)) {
      _panStart(DragStartDetails(
          globalPosition: details.focalPoint,
          localPosition: details.localFocalPoint));
    }
  }

  void _onInteractionUpdate(ScaleUpdateDetails details) {
    // print('onInteractionUpdate---$details');
    if (_isPanEvent(details.pointerCount, details.scale)) {
      var updateDetails = DragUpdateDetails(
          globalPosition: details.focalPoint,
          delta: details.focalPointDelta,
          localPosition: details.localFocalPoint);
      _panUpdate(updateDetails);
    }
  }

  void _onInteractionEnd(ScaleEndDetails details) {
    // print('details.pointerCount---${details.pointerCount}');
    // _panEnd(DragEndDetails(velocity: details.velocity));
    if (_PanDirection.vertical == _panDirection) {
      _onVerticalDragEnd(DragEndDetails(velocity: details.velocity));
    }
    // print('_panDirection---$_panDirection');
    if (_PanDirection.none == _panDirection) {
      // _onBoundaryDetection();
    }
    _panDirection = _PanDirection.none;
  }

  void _onTap() {
    TapGestureNotification().dispatch(context);
    widget.onTap?.call();
  }

  void _panStart(DragStartDetails dragStartDetails) {}

  void _panUpdate(DragUpdateDetails details) {
    _panUpdateDirection(details);
    if (_PanDirection.vertical == _panDirection) {
      _dragDownPopKey.currentState?.onPanUpdate(details);
    }
  }

  // void _panEnd(DragEndDetails dragEndDetails) {}

  void _panUpdateDirection(DragUpdateDetails details) {
    var scale = _scale ?? 1;
    if (10 < (scale * 10).toInt()) return;
    var delta = details.delta;
    if (delta.dy.abs() > delta.dx.abs()) {
      if (_PanDirection.vertical != _panDirection &&
          (null == _scale || null != _scale && 10 == (scale * 10).toInt())) {
        _panDirection = _PanDirection.vertical;
        _onVerticalDragStart(DragStartDetails(
            globalPosition: details.globalPosition,
            localPosition: details.localPosition));
      }
      _onVerticalDragUpdate(DragUpdateDetails(
          delta: Offset(0, delta.dy),
          globalPosition: details.globalPosition,
          localPosition: details.localPosition,
          primaryDelta: delta.dy));
    }
  }

  void _onVerticalDragStart(DragStartDetails details) {
    _dragDownPopKey.currentState?.onVerticalDragStart(details);
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {}

  void _onVerticalDragEnd(DragEndDetails details) {
    _dragDownPopKey.currentState?.onVerticalDragEnd(details);
  }

  void _onScaleChange(double scale) {
    _scale = scale;
    // print('_onScaleChange---$scale');
  }

  /* void _onPanZoomLeftBoundary() {
    print('_onPanZoomLeftBoundary');
    PanZoomReachBoundaryNotification().dispatch(context);
  }

  void _onPanZoomRightBoundary() {
    print('_onPanZoomRightBoundary');
    PanZoomReachBoundaryNotification().dispatch(context);
  }

  void _onPanZoomUpdate() {
    print('_onPanZoomUpdate');
    PanZoomUpdateNotification().dispatch(context);
  }*/

/*void _onHorizontalDragUpdate(DragUpdateDetails dragUpdateDetails) {}

  void _onHorizontalDragEnd(DragEndDetails details) {}

  void _onHorizontalDragStart(DragStartDetails dragStartDetails) {}*/
}
