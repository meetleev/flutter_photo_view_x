import 'dart:core';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:photo_view_x/src/gesture/gesture_detector.dart';
import 'page_view/page_view.dart';

class PhotoPageView extends StatelessWidget {
  final Axis scrollDirection;
  final bool reverse;
  final SpacingPageController? controller;
  final ScrollPhysics? physics;
  final bool pageSnapping;

  final ValueChanged<int>? onPageChanged;
  final IndexedWidgetBuilder itemBuilder;
  final ChildIndexGetter? findChildIndexCallback;
  final int? itemCount;
  final DragStartBehavior dragStartBehavior;
  final bool allowImplicitScrolling;

  final String? restorationId;
  final Clip clipBehavior;

  final ScrollBehavior? scrollBehavior;
  final bool padEnds;

  const PhotoPageView({
    super.key,
    required this.itemBuilder,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    this.pageSnapping = true,
    this.dragStartBehavior = DragStartBehavior.start,
    this.allowImplicitScrolling = false,
    this.padEnds = true,
    this.clipBehavior = Clip.hardEdge,
    this.controller,
    this.physics,
    this.onPageChanged,
    this.findChildIndexCallback,
    this.itemCount,
    this.restorationId,
    this.scrollBehavior,
  });

  @override
  Widget build(BuildContext context) {
    return ScrollGestureDetectorProvider(
      scrollDirection: scrollDirection,
      child: SpacingPageView.builder(
        itemBuilder: itemBuilder,
        scrollDirection: scrollDirection,
        reverse: reverse,
        controller: controller,
        physics: physics,
        pageSnapping: pageSnapping,
        onPageChanged: onPageChanged,
        findChildIndexCallback: findChildIndexCallback,
        itemCount: itemCount,
        dragStartBehavior: dragStartBehavior,
        restorationId: restorationId,
        clipBehavior: clipBehavior,
        scrollBehavior: scrollBehavior,
        padEnds: padEnds,
        allowImplicitScrolling: allowImplicitScrolling,
      ),
    );
  }
}
