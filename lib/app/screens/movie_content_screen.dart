import 'dart:io';

import 'package:flutter/material.dart';
import 'package:xp_downloader/app/components/bookmark_button.dart';
import 'package:xp_downloader/app/components/cache_image.dart';
import 'package:xp_downloader/app/components/download_button.dart';
import 'package:xp_downloader/app/components/movie_grid_item.dart';
import 'package:xp_downloader/app/models/x_movie_model.dart';
import 'package:xp_downloader/app/notifiers/app_notifier.dart';
import 'package:xp_downloader/app/services/core/app_services.dart';
import 'package:xp_downloader/app/services/x_services.dart';
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

  void init() async {
    try {
      list.clear();
      setState(() {
        isLoading = true;
      });
      String url = '${widget.movie.url}#show-related';
      list = await XServices.instance.getContentList(
        url: url,
        isOverride: isOverride,
        cacheName: '${widget.movie.title}.html',
      );

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
    return FutureBuilder(
      future: XServices.instance.getMovieContent(
        '${widget.movie.url}#show-related',
        cacheName: '${widget.movie.title}.html',
        isOverride: true,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: 25,
            height: 25,
            child: TLoader(size: 25),
          );
        }
        if (snapshot.hasData) {
          String url = XServices.instance.getVideoUrl(snapshot.data!);
          if (url.isEmpty) {
            return SizedBox.shrink();
          }
          return DownloadButton(
            title: widget.movie.title,
            savePath:
                '${PathUtil.instance.getOutPath()}/${widget.movie.title}.mp4',
            url: url,
            onDoned: () {},
          );
        }
        return SizedBox.shrink();
      },
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
              width: 130,
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
      width: 130,
      height: 150,
      child: CacheImage(
        url:
            '${appConfigNotifier.value.forwardProxyUrl}?url=${widget.movie.coverUrl}',
        fit: BoxFit.fill,
      ),
    );
  }

  Widget _getHeader() {
    return Column(
      children: [
        //header
        Card(
          child: Row(
            spacing: 5,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _getCoverWidget(),
              //titl
              Expanded(
                child: Wrap(
                  spacing: 5,
                  children: [
                    Text(
                      widget.movie.title,
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    Text(widget.movie.time),
                    _getDownloadButton(),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      contentPadding: 0,
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
            // SliverAppBar(
            //   automaticallyImplyLeading: false,
            //   flexibleSpace: _getHeader(),
            //   expandedHeight: 180,
            //   collapsedHeight: 180,
            //   pinned: true,
            //   floating: true,
            // ),
            SliverToBoxAdapter(child: _getHeader()),
            SliverToBoxAdapter(
              child: isLoading ? TLoader() : SizedBox.shrink(),
            ),
            SliverGrid.builder(
              itemCount: list.length,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 180,
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
