import 'package:example/page/photo_view_page.dart';
import 'package:flutter/material.dart';
import 'package:grouped_scroll_view/grouped_scroll_view.dart';
import 'package:photo_view_x/photo_view_x.dart';

class GalleryPage extends StatefulWidget {
  final String title;

  const GalleryPage({super.key, required this.title});

  @override
  State<StatefulWidget> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final int _crossAxisCount = 3;
  final List<String> _images = <String>[
    'assets/images/1.jpeg',
    'assets/images/2.jpeg',
    'assets/images/3.jpeg',
    'assets/images/4.jpeg',
    'assets/images/5.jpeg',
    'assets/images/6.jpeg',
    'assets/images/7.jpeg',
    'assets/images/8.jpeg',
    'assets/images/9.jpeg',
    'assets/images/10.jpeg',
    'assets/images/11.jpeg',
    'assets/images/12.jpeg',
    'assets/images/13.jpeg',
    'assets/images/14.png',
    'assets/images/15.jpeg',
  ];

  @override
  Widget build(BuildContext context) {
    var sys = MediaQuery.of(context);
    var fixWidth = sys.size.width / _crossAxisCount;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GroupedScrollView.grid(
        data: _images,
        itemBuilder: (BuildContext c, String url) {
          return Center(
            child: GestureDetector(
              onTap: () => onTap(url),
              child: Hero(
                tag: url,
                transitionOnUserGestures: true,
                child: Image.asset(
                  url,
                  fit: BoxFit.cover,
                  width: fixWidth,
                  height: fixWidth,
                ),
              ),
            ),
          );
        },
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: 1, crossAxisSpacing: 1, crossAxisCount: _crossAxisCount, childAspectRatio: 1),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'person'),
        ],
      ),
    );
  }

  void onTap(String url) {
    Navigator.of(context).push(DragGesturePageRouteBuilder(
        pageBuilder:
            (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) =>
                PhotoViewPage(curAssetUrl: url, assets: _images),
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation, Widget child) {
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0)
                .animate(CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn)),
            child: child,
          );
        }));
  }
}
