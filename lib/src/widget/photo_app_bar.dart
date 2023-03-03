import 'package:flutter/material.dart';
import 'package:photo_view_x/src/widget/animated_state.dart';

class PhotoAppBar extends StatefulWidget implements PreferredSizeWidget {
  final AppBar child;
  final AnimationController parentAnimateController;

  PhotoAppBar(
      {super.key, required this.child, required this.parentAnimateController})
      : preferredSize = child.preferredSize;

  @override
  State<StatefulWidget> createState() => PhotoAppBarState();

  @override
  final Size preferredSize;
}

class PhotoAppBarState extends AnimatedState<PhotoAppBar> {
  late Animatable<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _offsetAnimation = Tween(
      begin: const Offset(0, 0),
      end: const Offset(0, -1),
    );
  }

  @override
  Widget buildContent(BuildContext context, Animation<double> animation) {
    return SlideTransition(
      position: _offsetAnimation.animate(animation),
      child: widget.child,
    );
  }

  @override
  AnimationController get parentAnimateController =>
      widget.parentAnimateController;
}
