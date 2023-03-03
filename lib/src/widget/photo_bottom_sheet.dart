import 'package:flutter/material.dart';
import 'package:photo_view_x/src/widget/animated_state.dart';

class PhotoBottomSheet extends StatefulWidget {
  final Widget child;
  final AnimationController parentAnimateController;

  const PhotoBottomSheet(
      {super.key, required this.child, required this.parentAnimateController});

  @override
  State<StatefulWidget> createState() => PhotoBottomSheetState();
}

class PhotoBottomSheetState extends AnimatedState<PhotoBottomSheet> {
  @override
  Widget buildContent(BuildContext context, Animation<double> animation) {
    return widget.child;
  }

  @override
  AnimationController get parentAnimateController =>
      widget.parentAnimateController;
}
