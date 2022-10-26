import 'package:flutter/material.dart';
import 'package:photo_view_x/src/widget/animated_state.dart';

class PhotoBottomSheet extends StatefulWidget {
  final Widget child;
  final AnimationController parentAnimateController;

  const PhotoBottomSheet({super.key, required this.child, required this.parentAnimateController});

  @override
  State<StatefulWidget> createState() => PhotoBottomSheetState();
}

class PhotoBottomSheetState extends AnimatedState<PhotoBottomSheet> {
  // late Animatable<Offset> _offsetAnimation;

  @override
  Widget buildContent(BuildContext context, Animation<double> animation) {
    return widget.child;
    /*return FadeTransition(
      opacity: Tween(begin: 1.0, end: 0.0).animate(animation),
      child: SlideTransition(
        position: _offsetAnimation.animate(animation),
        child: widget.child,
      ),
    );*/
  }

  /*@override
  void initState() {
    super.initState();
    _offsetAnimation = Tween(
      begin: const Offset(0, 0),
      end: const Offset(0, 1),
    );
  }*/

  @override
  AnimationController get parentAnimateController => widget.parentAnimateController;
}
