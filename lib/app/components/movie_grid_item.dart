import 'package:flutter/material.dart';
import 'package:xp_downloader/app/components/cache_image.dart';
import 'package:xp_downloader/app/models/x_movie_model.dart';
import 'package:xp_downloader/app/services/index.dart';

class MovieGridItem extends StatelessWidget {
  XMovieModel movie;
  void Function(XMovieModel movie) onClicked;
  MovieGridItem({
    super.key,
    required this.movie,
    required this.onClicked,
  });

  @override
  Widget build(BuildContext context) {
    final coverUrl = DioServices.instance.getForwardProxyUrl(movie.coverUrl);

    return GestureDetector(
      onTap: () => onClicked(movie),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: CacheImage(
                    url: coverUrl,
                    width: double.infinity,
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                    color: const Color.fromARGB(153, 22, 22, 22),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(5),
                      bottomRight: Radius.circular(5),
                    )),
                child: Text(
                  movie.title,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(209, 8, 8, 8),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                movie.time,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
