import 'package:flutter/material.dart';
import 'package:photo_view_x/src/notification.dart';
import 'package:photo_view_x/src/widget/photo_app_bar.dart';
import 'package:photo_view_x/src/widget/photo_bottom_sheet.dart';

class PhotoScaffold extends StatefulWidget {
  final Widget? body;
  final AppBar? appBar;
  final Widget? bottomSheet;
  final bool extendBodyBehindAppBar;

  const PhotoScaffold(
      {super.key,
      this.body,
      this.appBar,
      this.bottomSheet,
      this.extendBodyBehindAppBar = true});

  @override
  State<StatefulWidget> createState() => PhotoScaffoldState();
}

class PhotoScaffoldState extends State<PhotoScaffold>
    with SingleTickerProviderStateMixin {
  bool _isFullScreen = false;

  set isFullScreen(bool value) {
    _isFullScreen = value;
    _updateBars();
    _updateBackgroundColor(true);
    _animateController.value = 0;
  }

  late AnimationController _animateController;
  Animation<Color?>? _opacityAnimation;
  final GlobalKey<PhotoAppBarState> _appBarKey = GlobalKey();
  final GlobalKey<PhotoBottomSheetState> _bottomSheetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animateController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300))
      ..addListener(() {
        setState(() {});
      });
    _updateBackgroundColor(false);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      child: Scaffold(
        extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
        backgroundColor: _opacityAnimation?.value,
        appBar: null != widget.appBar
            ? PhotoAppBar(
                key: _appBarKey,
                parentAnimateController: _animateController,
                child: widget.appBar!,
              )
            : null,
        body: widget.body,
        bottomSheet: !_isFullScreen && null != widget.bottomSheet
            ? PhotoBottomSheet(
                key: _bottomSheetKey,
                parentAnimateController: _animateController,
                child: widget.bottomSheet!)
            : null,
      ),
      onNotification: (Notification notification) {
        if (notification is TapGestureNotification) {
          isFullScreen = !_isFullScreen;
          return true;
        } else if (notification is DragStartNotification) {
          _updateBackgroundColor(false);
          return true;
        } else if (notification is DragUpdateNotification) {
          _animateController.value = notification.value;
          return true;
        } else if (notification is DragEndNotification) {
          if (notification.pop) {
            Navigator.pop(context);
          } else {
            _animateController.value = 0;
          }
          return true;
        }
        return false;
      },
    );
  }

  @override
  void dispose() {
    _animateController.dispose();
    super.dispose();
  }

  Future _updateBars() async {
    await _appBarKey.currentState?.runAction(_isFullScreen);
    // await _bottomSheetKey.currentState?.runAction(_isFullScreen);
  }

  void _updateBackgroundColor(bool isFullScreenEvent) {
    // var end =  isFullScreenEvent ? (_isFullScreen ? Colors.white : Colors.black):Colors.transparent;
    _opacityAnimation = ColorTween(
      begin: !_isFullScreen ? Colors.white : Colors.black,
      end: Colors.transparent,
    ).animate(_animateController);
  }
}
