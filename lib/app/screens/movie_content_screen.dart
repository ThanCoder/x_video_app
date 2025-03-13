import 'package:flutter/material.dart';
import 'package:xp_downloader/app/components/bookmark_button.dart';
import 'package:xp_downloader/app/components/cache_image.dart';
import 'package:xp_downloader/app/components/download_button.dart';
import 'package:xp_downloader/app/models/x_movie_model.dart';
import 'package:xp_downloader/app/notifiers/app_notifier.dart';
import 'package:xp_downloader/app/services/x_services.dart';
import 'package:xp_downloader/app/utils/index.dart';
import 'package:xp_downloader/app/widgets/index.dart';

class MovieContentScreen extends StatelessWidget {
  XMovieModel movie;
  MovieContentScreen({super.key, required this.movie});

  Widget _getDownloadButton() {
    return FutureBuilder(
      future: XServices.instance.getMovieContent(
        '${movie.url}#show-related',
        cacheName: '${movie.title}.html',
        isOverride: false,
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

          return DownloadButton(
            title: movie.title,
            savePath: '${PathUtil.instance.getOutPath()}/${movie.title}.mp4',
            url: url,
            onDoned: () {},
          );
        }
        return SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      contentPadding: 2,
      appBar: AppBar(
        title: Text('Content'),
        actions: [
          BookmarkButton(movie: movie),
        ],
      ),
      body: Column(
        children: [
          //header
          Card(
            child: Row(
              spacing: 5,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 130,
                  height: 150,
                  child: CacheImage(
                    url:
                        '${appConfigNotifier.value.forwardProxyUrl}?url=${movie.coverUrl}',
                    fit: BoxFit.fill,
                  ),
                ),
                //titl
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 5,
                    children: [
                      Text(
                        movie.title,
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      Text(movie.time),
                      _getDownloadButton(),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
