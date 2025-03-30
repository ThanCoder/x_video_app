import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xp_downloader/app/components/movie_grid_item.dart';
import 'package:xp_downloader/app/providers/x_movie_provider.dart';
import 'package:xp_downloader/app/screens/movie_content_screen.dart';

import '../constants.dart';
import '../widgets/index.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController scrollController = ScrollController();
  @override
  void initState() {
    scrollController.addListener(_onScroll);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    super.dispose();
  }

  double lastScroll = 0;
  bool isLoadData = false;

  Future<void> init() async {
    await context.read<XMovieProvider>().initList();
  }

  void _onScroll() {
    if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent &&
        lastScroll != scrollController.position.maxScrollExtent) {
      lastScroll = scrollController.position.maxScrollExtent;
      setState(() {
        isLoadData = true;
      });
      context.read<XMovieProvider>().loadList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<XMovieProvider>();
    final isLoading = provider.isLoading;
    final list = provider.getList;
    return MyScaffold(
      appBar: AppBar(
        title: Text(appTitle),
        actions: [
          Platform.isLinux
              ? IconButton(
                  onPressed: () {
                    context.read<XMovieProvider>().setListOverride(true);
                    init();
                  },
                  icon: Icon(Icons.refresh),
                )
              : SizedBox.shrink(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<XMovieProvider>().setListOverride(true);
          init();
        },
        child: !isLoadData && isLoading
            ? TLoader()
            : CustomScrollView(
                controller: scrollController,
                slivers: [
                  //list
                  SliverGrid.builder(
                    itemCount: list.length,
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
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
                              builder: (context) =>
                                  MovieContentScreen(movie: movie),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  //loader
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: isLoadData && isLoading
                          ? TLoader(
                              size: 30,
                            )
                          : SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
