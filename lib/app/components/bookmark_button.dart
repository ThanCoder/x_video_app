import 'package:flutter/material.dart';
import 'package:xp_downloader/app/models/x_movie_model.dart';
import 'package:xp_downloader/app/services/bookmark_services.dart';
import 'package:xp_downloader/app/widgets/index.dart';

class BookmarkButton extends StatefulWidget {
  XMovieModel movie;
  BookmarkButton({super.key, required this.movie});

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton> {
  void _toggle() async {
    await BookmarkServices.instance.toggle(movie: widget.movie);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: BookmarkServices.instance.isExists(movie: widget.movie),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(width: 25, height: 25, child: TLoader(size: 25));
        }
        if (snapshot.hasData) {
          final isExists = snapshot.data ?? false;

          return IconButton(
            onPressed: _toggle,
            color: isExists ? Colors.red : Colors.blue,
            icon: Icon(isExists ? Icons.bookmark_remove : Icons.bookmark_add),
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}
