import 'package:flutter/material.dart';
import 'package:xp_downloader/app/components/movie_grid_item.dart';
import 'package:xp_downloader/app/screens/movie_content_screen.dart';
import 'package:xp_downloader/app/services/bookmark_services.dart';
import 'package:xp_downloader/app/widgets/core/index.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBar: AppBar(
        title: Text('BookMark'),
      ),
      body: FutureBuilder(
        future: BookmarkServices.instance.getList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return TLoader();
          }
          if (snapshot.hasData) {
            final list = snapshot.data ?? [];
            if (list.isEmpty) {
              return Center(child: Text('BookMark is empty'));
            }
            //ရှိနေရင်
            return GridView.builder(
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
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
}
