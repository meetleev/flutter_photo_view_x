import 'dart:async';

import 'package:flutter/material.dart';

abstract class AnimatedState<T extends StatefulWidget> extends State<T>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @protected
  AnimationController get parentAnimateController;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Durations.medium2);
  }

  @protected
  Widget buildContent(BuildContext context, Animation<double> animation);

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 1.0, end: 0.0).animate(parentAnimateController),
      child: buildContent(context, _animationController),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future runAction(bool isFullScreen) {
    return isFullScreen
        ? _animationController.forward(from: 0)
        : _animationController.reverse(from: 1);
  }
}
