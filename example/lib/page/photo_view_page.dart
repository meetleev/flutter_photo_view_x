import 'package:flutter/material.dart';
import 'package:photo_view_x/photo_view_x.dart';

class PhotoViewPage extends StatefulWidget {
  final String curAssetUrl;
  final List<String> assets;

  const PhotoViewPage(
      {super.key, required this.curAssetUrl, required this.assets});

  @override
  State<PhotoViewPage> createState() => PhotoViewPageState();
}

class PhotoViewPageState extends State<PhotoViewPage> {
  final ValueNotifier<int> _initialPage = ValueNotifier(0);

  @override
  void initState() {
    super.initState();

    int initialPage = widget.assets.indexOf(widget.curAssetUrl);
    if (_initialPage.value != initialPage) {
      _initialPage.value = initialPage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PhotoScaffold(
      appBar: AppBar(
        title: ValueListenableBuilder(
          valueListenable: _initialPage,
          builder: (BuildContext context, int value, Widget? child) {
            return Column(
              children: [
                if (widget.assets.isNotEmpty)
                  Text(
                    '${value + 1}/${widget.assets.length}',
                    style: const TextStyle(fontSize: 16),
                  )
              ],
            );
          },
        ),
      ),
      body: _buildBody(),
      // bottomSheet: _buildBottomSheet(),
    );
  }

  Widget _buildBody() {
    return PhotoPageView(
      controller: SpacingPageController(
          initialPage: _initialPage.value, pageSpacing: 30),
      itemBuilder: (context, idx) => _itemBuilder(context, idx),
      itemCount: widget.assets.length,
      onPageChanged: (int page) => {_initialPage.value = page},
    );
  }

  /*Widget? _buildBottomSheet() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
            onPressed: () {},
            child: const Text(
              'delete',
              style: TextStyle(fontSize: 14),
            )),
        TextButton(
            onPressed: () {},
            child: const Text(
              'recover',
              style: TextStyle(fontSize: 14),
            ))
      ],
    );
  }*/

  Widget _itemBuilder(BuildContext context, int idx) {
    var sys = MediaQuery.of(context);
    var thumbnailView = sys.size.width * sys.devicePixelRatio;
    var asset = widget.assets[idx];
    return PhotoView(
      tapEnabled: true,
      child: Hero(
        tag: asset,
        transitionOnUserGestures: true,
        child: Center(
          child:
              Image.asset(asset, fit: BoxFit.fitHeight, width: thumbnailView),
        ),
      ),
    );
  }
}
