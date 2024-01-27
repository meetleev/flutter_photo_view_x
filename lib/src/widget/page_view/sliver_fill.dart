import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A sliver that contains multiple box children that each fills the viewport.
///
/// [SpacingSliverFillViewport] places its children in a linear array along the main
/// axis. Each child is sized to fill the viewport, both in the main and cross
/// axis.
///
/// See also:
///
///  * [SliverFixedExtentList], which has a configurable
///    [SliverFixedExtentList.itemExtent].
///  * [SliverPrototypeExtentList], which is similar to [SliverFixedExtentList]
///    except that it uses a prototype list item instead of a pixel value to define
///    the main axis extent of each item.
///  * [SliverList], which does not require its children to have the same
///    extent in the main axis.
class SpacingSliverFillViewport extends StatelessWidget {
  /// Creates a sliver whose box children that each fill the viewport.
  const SpacingSliverFillViewport(
      {super.key,
      required this.delegate,
      this.viewportFraction = 1.0,
      this.padEnds = true,
      this.pageSpacing = 0})
      : assert(viewportFraction > 0.0);

  /// The fraction of the viewport that each child should fill in the main axis.
  ///
  /// If this fraction is less than 1.0, more than one child will be visible at
  /// once. If this fraction is greater than 1.0, each child will be larger than
  /// the viewport in the main axis.
  final double viewportFraction;

  /// Whether to add padding to both ends of the list.
  ///
  /// If this is set to true and [viewportFraction] < 1.0, padding will be added
  /// such that the first and last child slivers will be in the center of
  /// the viewport when scrolled all the way to the start or end, respectively.
  /// You may want to set this to false if this [PageSliverFillViewport] is not the only
  /// widget along this main axis, such as in a [CustomScrollView] with multiple
  /// children.
  ///
  /// This option cannot be null. If [viewportFraction] >= 1.0, this option has no
  /// effect. Defaults to true.
  final bool padEnds;

  /// {@macro flutter.widgets.SliverMultiBoxAdaptorWidget.delegate}
  final SliverChildDelegate delegate;

  /// The number of logical pixels between each child.
  final double pageSpacing;

  @override
  Widget build(BuildContext context) {
    return _SliverFractionalPadding(
      viewportFraction:
          padEnds ? clampDouble(1 - viewportFraction, 0, 1) / 2 : 0,
      sliver: _SliverFillViewportRenderObjectWidget(
          viewportFraction: viewportFraction,
          delegate: delegate,
          pageSpacing: pageSpacing),
    );
  }
}

class _SliverFillViewportRenderObjectWidget
    extends SliverMultiBoxAdaptorWidget {
  const _SliverFillViewportRenderObjectWidget(
      {required super.delegate,
      this.viewportFraction = 1.0,
      this.pageSpacing = 0})
      : assert(viewportFraction > 0.0);

  final double viewportFraction;

  /// The number of logical pixels between each child.
  final double pageSpacing;

  @override
  SpacingRenderSliverFillViewport createRenderObject(BuildContext context) {
    final SliverMultiBoxAdaptorElement element =
        context as SliverMultiBoxAdaptorElement;
    return SpacingRenderSliverFillViewport(
        childManager: element,
        viewportFraction: viewportFraction,
        pageSpacing: pageSpacing);
  }

  @override
  void updateRenderObject(
      BuildContext context, SpacingRenderSliverFillViewport renderObject) {
    renderObject.viewportFraction = viewportFraction;
    renderObject.pageSpacing = pageSpacing;
  }
}

class _SliverFractionalPadding extends SingleChildRenderObjectWidget {
  const _SliverFractionalPadding({
    this.viewportFraction = 0,
    Widget? sliver,
  })  : assert(viewportFraction >= 0),
        assert(viewportFraction <= 0.5),
        super(child: sliver);

  final double viewportFraction;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderSliverFractionalPadding(viewportFraction: viewportFraction);

  @override
  void updateRenderObject(
      BuildContext context, _RenderSliverFractionalPadding renderObject) {
    renderObject.viewportFraction = viewportFraction;
  }
}

class _RenderSliverFractionalPadding extends RenderSliverEdgeInsetsPadding {
  _RenderSliverFractionalPadding({
    double viewportFraction = 0,
  })  : assert(viewportFraction <= 0.5),
        assert(viewportFraction >= 0),
        _viewportFraction = viewportFraction;

  SliverConstraints? _lastResolvedConstraints;

  double get viewportFraction => _viewportFraction;
  double _viewportFraction;

  set viewportFraction(double newValue) {
    if (_viewportFraction == newValue) {
      return;
    }
    _viewportFraction = newValue;
    _markNeedsResolution();
  }

  @override
  EdgeInsets? get resolvedPadding => _resolvedPadding;
  EdgeInsets? _resolvedPadding;

  void _markNeedsResolution() {
    _resolvedPadding = null;
    markNeedsLayout();
  }

  void _resolve() {
    if (_resolvedPadding != null && _lastResolvedConstraints == constraints) {
      return;
    }

    final double paddingValue =
        constraints.viewportMainAxisExtent * viewportFraction;
    _lastResolvedConstraints = constraints;
    switch (constraints.axis) {
      case Axis.horizontal:
        _resolvedPadding = EdgeInsets.symmetric(horizontal: paddingValue);
        break;
      case Axis.vertical:
        _resolvedPadding = EdgeInsets.symmetric(vertical: paddingValue);
        break;
    }

    return;
  }

  @override
  void performLayout() {
    _resolve();
    super.performLayout();
  }
}

/// A sliver that contains multiple box children that each fill the viewport.
///
/// [RenderSliverFillRemaining] places its children in a linear array along the
/// main axis. Each child is sized to fill the viewport, both in the main and
/// cross axis. A [viewportFraction] factor can be provided to size the children
/// to a multiple of the viewport's main axis dimension (typically a fraction
/// less than 1.0).
///
/// See also:
///
///  * [RenderSliverFillRemaining], which sizes the children based on the
///    remaining space rather than the viewport itself.
///  * [RenderSliverFixedExtentList], which has a configurable [itemExtent].
///  * [RenderSliverList], which does not require its children to have the same
///    extent in the main axis.
class SpacingRenderSliverFillViewport
    extends RenderSliverFixedExtentBoxAdaptor {
  /// Creates a sliver that contains multiple box children that each fill the
  /// viewport.
  ///
  /// The [childManager] argument must not be null.
  SpacingRenderSliverFillViewport({
    required super.childManager,
    double viewportFraction = 1.0,
    double pageSpacing = 0.0,
  })  : assert(viewportFraction > 0.0),
        assert(pageSpacing >= 0.0),
        _viewportFraction = viewportFraction,
        _pageSpacing = pageSpacing;

  @override
  double get itemExtent =>
      constraints.viewportMainAxisExtent * viewportFraction;

  /// The fraction of the viewport that each child should fill in the main axis.
  ///
  /// If this fraction is less than 1.0, more than one child will be visible at
  /// once. If this fraction is greater than 1.0, each child will be larger than
  /// the viewport in the main axis.
  double get viewportFraction => _viewportFraction;
  double _viewportFraction;

  set viewportFraction(double value) {
    if (_viewportFraction == value) return;
    _viewportFraction = value;
    markNeedsLayout();
  }

  /// The number of logical pixels between each page.
  double get pageSpacing => _pageSpacing;
  double _pageSpacing;

  set pageSpacing(double value) {
    if (_pageSpacing == value) return;
    _pageSpacing = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    final SliverConstraints constraints = this.constraints;
    childManager.didStartLayout();
    childManager.setDidUnderflow(false);

    final double itemExtent = this.itemExtent + pageSpacing;
    final double scrollOffset =
        constraints.scrollOffset + constraints.cacheOrigin;
    assert(scrollOffset >= 0.0);
    final double remainingExtent = constraints.remainingCacheExtent;
    assert(remainingExtent >= 0.0);
    final double targetEndScrollOffset = scrollOffset + remainingExtent;

    final BoxConstraints childConstraints = constraints.asBoxConstraints(
      minExtent: this.itemExtent,
      maxExtent: this.itemExtent,
    );

    final int firstIndex =
        getMinChildIndexForScrollOffset(scrollOffset, itemExtent);
    final int? targetLastIndex = targetEndScrollOffset.isFinite
        ? getMaxChildIndexForScrollOffset(targetEndScrollOffset, itemExtent)
        : null;

    if (firstChild != null) {
      final int leadingGarbage = _calculateLeadingGarbage(firstIndex);
      final int trailingGarbage = targetLastIndex != null
          ? _calculateTrailingGarbage(targetLastIndex)
          : 0;
      collectGarbage(leadingGarbage, trailingGarbage);
    } else {
      collectGarbage(0, 0);
    }

    if (firstChild == null) {
      if (!addInitialChild(
          index: firstIndex,
          layoutOffset: indexToLayoutOffset(itemExtent, firstIndex))) {
        // There are either no children, or we are past the end of all our children.
        final double max;
        if (firstIndex <= 0) {
          max = 0.0;
        } else {
          max = computeMaxScrollOffset(constraints, itemExtent);
        }
        geometry = SliverGeometry(
          scrollExtent: max,
          maxPaintExtent: max,
        );
        childManager.didFinishLayout();
        return;
      }
    }

    RenderBox? trailingChildWithLayout;

    for (int index = indexOf(firstChild!) - 1; index >= firstIndex; --index) {
      final RenderBox? child = insertAndLayoutLeadingChild(childConstraints);
      if (child == null) {
        // Items before the previously first child are no longer present.
        // Reset the scroll offset to offset all items prior and up to the
        // missing item. Let parent re-layout everything.
        geometry = SliverGeometry(scrollOffsetCorrection: index * itemExtent);
        return;
      }
      final SliverMultiBoxAdaptorParentData childParentData =
          child.parentData! as SliverMultiBoxAdaptorParentData;
      childParentData.layoutOffset = indexToLayoutOffset(itemExtent, index);
      assert(childParentData.index == index);
      trailingChildWithLayout ??= child;
    }

    if (trailingChildWithLayout == null) {
      firstChild!.layout(childConstraints);
      final SliverMultiBoxAdaptorParentData childParentData =
          firstChild!.parentData! as SliverMultiBoxAdaptorParentData;
      childParentData.layoutOffset =
          indexToLayoutOffset(itemExtent, firstIndex);
      trailingChildWithLayout = firstChild;
    }

    double estimatedMaxScrollOffset = double.infinity;
    for (int index = indexOf(trailingChildWithLayout!) + 1;
        targetLastIndex == null || index <= targetLastIndex;
        ++index) {
      RenderBox? child = childAfter(trailingChildWithLayout!);
      if (child == null || indexOf(child) != index) {
        child = insertAndLayoutChild(childConstraints,
            after: trailingChildWithLayout);
        if (child == null) {
          // We have run out of children.
          estimatedMaxScrollOffset = index * itemExtent;
          break;
        }
      } else {
        child.layout(childConstraints);
      }
      trailingChildWithLayout = child;
      final SliverMultiBoxAdaptorParentData childParentData =
          child.parentData! as SliverMultiBoxAdaptorParentData;
      assert(childParentData.index == index);
      childParentData.layoutOffset =
          indexToLayoutOffset(itemExtent, childParentData.index!);
    }

    final int lastIndex = indexOf(lastChild!);
    final double leadingScrollOffset =
        indexToLayoutOffset(itemExtent, firstIndex);
    double trailingScrollOffset =
        indexToLayoutOffset(itemExtent, lastIndex + 1);

    assert(firstIndex == 0 ||
        childScrollOffset(firstChild!)! - scrollOffset <=
            precisionErrorTolerance);
    assert(debugAssertChildListIsNonEmptyAndContiguous());
    assert(indexOf(firstChild!) == firstIndex);
    assert(targetLastIndex == null || lastIndex <= targetLastIndex);

    if (lastIndex > 0) {
      // lastChild don't need pageSpacing
      trailingScrollOffset -= pageSpacing;
    }

    estimatedMaxScrollOffset = math.min(
      estimatedMaxScrollOffset,
      estimateMaxScrollOffset(
        constraints,
        firstIndex: firstIndex,
        lastIndex: lastIndex,
        leadingScrollOffset: leadingScrollOffset,
        trailingScrollOffset: trailingScrollOffset,
      ),
    );

    final double paintExtent = calculatePaintOffset(
      constraints,
      from: leadingScrollOffset,
      to: trailingScrollOffset,
    );

    final double cacheExtent = calculateCacheOffset(
      constraints,
      from: leadingScrollOffset,
      to: trailingScrollOffset,
    );

    final double targetEndScrollOffsetForPaint =
        constraints.scrollOffset + constraints.remainingPaintExtent;
    final int? targetLastIndexForPaint = targetEndScrollOffsetForPaint.isFinite
        ? getMaxChildIndexForScrollOffset(
            targetEndScrollOffsetForPaint, itemExtent)
        : null;
    geometry = SliverGeometry(
      scrollExtent: estimatedMaxScrollOffset,
      paintExtent: paintExtent,
      cacheExtent: cacheExtent,
      maxPaintExtent: estimatedMaxScrollOffset,
      // Conservative to avoid flickering away the clip during scroll.
      hasVisualOverflow: (targetLastIndexForPaint != null &&
              lastIndex >= targetLastIndexForPaint) ||
          constraints.scrollOffset > 0.0,
    );

    // We may have started the layout while scrolled to the end, which would not
    // expose a new child.
    if (estimatedMaxScrollOffset == trailingScrollOffset) {
      childManager.setDidUnderflow(true);
    }
    childManager.didFinishLayout();
  }

  int _calculateLeadingGarbage(int firstIndex) {
    RenderBox? walker = firstChild;
    int leadingGarbage = 0;
    while (walker != null && indexOf(walker) < firstIndex) {
      leadingGarbage += 1;
      walker = childAfter(walker);
    }
    return leadingGarbage;
  }

  int _calculateTrailingGarbage(int targetLastIndex) {
    RenderBox? walker = lastChild;
    int trailingGarbage = 0;
    while (walker != null && indexOf(walker) > targetLastIndex) {
      trailingGarbage += 1;
      walker = childBefore(walker);
    }
    return trailingGarbage;
  }
}
