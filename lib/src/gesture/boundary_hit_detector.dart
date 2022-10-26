import 'package:flutter/widgets.dart';

import '../widget/interactive_viewer.dart';

mixin BoundaryHitDetector on State<InteractiveViewerX> {
  double get scale => widget.transformationController.value.getMaxScaleOnAxis();

  Offset get position {
    var v3 = widget.transformationController.value.getTranslation();
    return Offset(v3.x, v3.y);
  }

  ScaleBoundaries get scaleBoundaries => widget.scaleBoundaries;

  HitBoundary _hitBoundaryX() {
    final double childWidth = scaleBoundaries.childSize.width * scale;
    final double screenWidth = scaleBoundaries.outerSize.width;
    if (screenWidth >= childWidth) {
      return const HitBoundary(true, true);
    }
    final x = position.dx.toInt();
    var maxOffset = (screenWidth - childWidth).toInt();
    // print('position: $x maxOffset: $maxOffset');
    return HitBoundary(x >= 0, x <= maxOffset);
  }

  HitBoundary _hitBoundaryY() {
    final double childHeight = scaleBoundaries.childSize.height * scale;
    final double screenHeight = scaleBoundaries.outerSize.height;
    if (screenHeight >= childHeight) {
      return const HitBoundary(true, true);
    }
    final y = position.dy.toInt();
    var maxOffset = (screenHeight - childHeight).toInt();
    // print('position: $y maxOffset: $maxOffset');
    return HitBoundary(y >= 0, y <= maxOffset);
  }

  bool _shouldMoveAxis(HitBoundary hitCorners, double mainAxisMove, double crossAxisMove) {
    // print('mainAxisMove---:$mainAxisMove--:$crossAxisMove');
    if (mainAxisMove == 0) {
      return false;
    }
    if (!hitCorners.hasHitAny) {
      return true;
    }
    final axisBlocked = hitCorners.hasHitBoth || (hitCorners.hasHitMax ? mainAxisMove > 0 : mainAxisMove < 0);
    if (axisBlocked) {
      return false;
    }
    return true;
  }

  bool _shouldMoveHorizontal(Offset move) {
    final hitBoundaryX = _hitBoundaryX();
    // print('hitBoundaryX---$hitBoundaryX');
    final mainAxisMove = move.dx;
    final crossAxisMove = move.dy;
    return _shouldMoveAxis(hitBoundaryX, mainAxisMove, crossAxisMove);
  }

  bool _shouldMoveVertical(Offset move) {
    final hitBoundaryY = _hitBoundaryY();
    // print('hitBoundaryY---$hitBoundaryY');
    final mainAxisMove = move.dy;
    final crossAxisMove = move.dx;

    return _shouldMoveAxis(hitBoundaryY, mainAxisMove, crossAxisMove);
  }

  bool shouldMove(Offset move, Axis mainAxis) =>
      mainAxis == Axis.vertical ? _shouldMoveVertical(move) : _shouldMoveHorizontal(move);
}

class HitBoundary {
  const HitBoundary(this.hasHitMin, this.hasHitMax);

  final bool hasHitMin;
  final bool hasHitMax;

  bool get hasHitAny => hasHitMin || hasHitMax;

  bool get hasHitBoth => hasHitMin && hasHitMax;

  @override
  toString() => '{ hasHitMin:$hasHitMin, hasHitMax:$hasHitMax }';
}

class ScaleBoundaries {
  final Size childSize;
  final Size outerSize;

  ScaleBoundaries({required this.childSize, required this.outerSize});
}
