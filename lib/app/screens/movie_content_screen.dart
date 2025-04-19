import 'dart:io';

import 'package:flutter/material.dart';
import 'package:xp_downloader/app/components/bookmark_button.dart';
import 'package:xp_downloader/app/components/cache_image.dart';
import 'package:xp_downloader/app/components/download_button.dart';
import 'package:xp_downloader/app/components/movie_grid_item.dart';
import 'package:xp_downloader/app/components/translate_text_widget.dart';
import 'package:xp_downloader/app/models/x_movie_model.dart';
import 'package:xp_downloader/app/notifiers/app_notifier.dart';
import 'package:xp_downloader/app/services/core/app_services.dart';
import 'package:xp_downloader/app/services/index.dart';
import 'package:xp_downloader/app/utils/index.dart';
import 'package:xp_downloader/app/widgets/index.dart';

class MovieContentScreen extends StatefulWidget {
  XMovieModel movie;
  MovieContentScreen({super.key, required this.movie});

  @override
  State<MovieContentScreen> createState() => _MovieContentScreenState();
}

class _MovieContentScreenState extends State<MovieContentScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  bool isLoading = false;
  bool isOverride = false;
  List<XMovieModel> list = [];
  String downloadUrl = '';

  void init() async {
    try {
      list.clear();
      setState(() {
        isLoading = true;
      });
      String url = '${widget.movie.url}#show-related';
      String htmlStr = await DioServices.instance.getCacheHtml(
        url: DioServices.instance.getBrowserProxyUrl(url),
        cacheName: '${widget.movie.title}.html',
        isOverride: isOverride,
      );

      final videoTitle = XServices.instance.getVideoTitle(htmlStr);
      if (videoTitle.isNotEmpty) {
        widget.movie.title = videoTitle;
      }
      // File('content.html').writeAsStringSync(htmlStr);

      downloadUrl = XServices.instance.getVideoUrl(htmlStr);

      list = await XServices.instance.getContentListFromHtml(htmlStr);

      if (!mounted) return;
      setState(() {
        isLoading = false;
        isOverride = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      debugPrint(e.toString());
    }
  }

  Widget _getDownloadButton() {
    if (downloadUrl.isEmpty) {
      return SizedBox.shrink();
    }
    return DownloadButton(
      title: widget.movie.title,
      savePath: '${PathUtil.instance.getOutPath()}/${widget.movie.title}.mp4',
      url: downloadUrl,
      onDoned: () {},
    );
  }

  Widget _getCoverWidget() {
    if (widget.movie.coverUrl.isEmpty) {
      return FutureBuilder(
        future: XServices.instance.getContentCover(widget.movie.url),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return TLoader();
          }
          if (snapshot.hasData) {
            if (snapshot.data == null) {
              return SizedBox.shrink();
            }
            return SizedBox(
              width: 200,
              height: 150,
              child: CacheImage(
                url:
                    '${appConfigNotifier.value.forwardProxyUrl}?url=${snapshot.data ?? ''}',
                fit: BoxFit.fill,
              ),
            );
          }
          return SizedBox.shrink();
        },
      );
    }
    return SizedBox(
      width: 200,
      height: 150,
      child: CacheImage(
        url:
            '${appConfigNotifier.value.forwardProxyUrl}?url=${widget.movie.coverUrl}',
        fit: BoxFit.fill,
      ),
    );
  }

  Widget _getHeader() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          //header
          Card(
            child: Wrap(
              spacing: 5,
              runSpacing: 5,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.center,
              children: [
                _getCoverWidget(),
                //titl
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 5,
                  children: [
                    TranslateTextWidget(text: widget.movie.title),
                    Text(widget.movie.time),
                    _getDownloadButton(),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      contentPadding: 2,
      appBar: AppBar(
        title: Text('Content'),
        actions: [
          BookmarkButton(movie: widget.movie),
          Platform.isLinux
              ? IconButton(
                  onPressed: () {
                    isOverride = true;
                    init();
                  },
                  icon: Icon(Icons.refresh),
                )
              : SizedBox.shrink(),
          IconButton(
            onPressed: () {
              copyText(widget.movie.url);
            },
            icon: Icon(Icons.copy),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          isOverride = true;
          init();
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _getHeader()),
            SliverToBoxAdapter(child: Divider()),
            SliverToBoxAdapter(
              child: isLoading ? TLoader() : SizedBox.shrink(),
            ),
            SliverGrid.builder(
              itemCount: list.length,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 290,
                mainAxisExtent: 200,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
              ),
              itemBuilder: (context, index) => MovieGridItem(
                movie: list[index],
                onClicked: (movie) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MovieContentScreen(movie: movie),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
