import 'package:flutter/material.dart';
import 'package:xp_downloader/app/components/movie_grid_item.dart';
import 'package:xp_downloader/app/models/x_movie_model.dart';
import 'package:xp_downloader/app/notifiers/app_notifier.dart';
import 'package:xp_downloader/app/screens/movie_content_screen.dart';
import 'package:xp_downloader/app/services/x_services.dart';
import 'package:xp_downloader/app/widgets/index.dart';

class XSearch extends SearchDelegate {
  List<XMovieModel> list = [];
  bool isOverride = false;
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear_all_rounded),
      ),
      IconButton(
        onPressed: () {
          isOverride = true;
        },
        icon: Icon(Icons.delete_forever_rounded),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return Center(child: Text('တစ်ခုခုရေးပါ'));
    }
    return FutureBuilder(
      future: XServices.instance.getList(
        url: '${appConfigNotifier.value.hostUrl}?k=$query',
        cacheName: '$query.html',
        isOverride: isOverride,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return TLoader();
        }
        if (snapshot.hasData) {
          list = snapshot.data ?? [];
          isOverride = false;
          return getList();
        }
        return SizedBox.shrink();
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (list.isNotEmpty) {
      return getList();
    }
    return Center(child: Text('တစ်ခုခုရေးပါ'));
  }

  Widget getList() {
    return GridView.builder(
      itemCount: list.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 250,
        mainAxisExtent: 220,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
      ),
      itemBuilder: (context, index) {
        final movie = list[index];
        return MovieGridItem(
          movie: movie,
          onClicked: (movie) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieContentScreen(movie: movie),
              ),
            );
          },
        );
      },
    );
  }
}
