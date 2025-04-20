import 'package:flutter/material.dart';
import 'package:xp_downloader/app/components/index.dart';
import 'package:xp_downloader/app/components/movie_grid_item.dart';
import 'package:xp_downloader/app/models/x_movie_model.dart';
import 'package:xp_downloader/app/notifiers/app_notifier.dart';
import 'package:xp_downloader/app/screens/movie_content_screen.dart';
import 'package:xp_downloader/app/services/x_services.dart';

import '../widgets/index.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController queryController = TextEditingController();
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

  List<XMovieModel> list = [];
  double lastScroll = 0;
  bool isLoadData = false;
  bool isLoading = false;
  bool isOverride = false;
  int page = 1;

  Future<void> init() async {}

  Future<void> loadList() async {
    page++;
    try {
      setState(() {
        isLoading = true;
      });
      final res = await XServices.instance.getList(
        url: _getUrl,
        //cacheName: '${queryController.text}.html',
        isOverride: true,
      );
      list.addAll(res);
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      showDialogMessage(context, e.toString());
    }
  }

  void _onScroll() {
    double pos = scrollController.position.pixels;
    double max = scrollController.position.maxScrollExtent;
    if (pos == max && lastScroll != max) {
      lastScroll = max;
      if (isLoadData == false) {
        _loadData();
      }
    }
  }

  void _loadData() async {
    setState(() {
      isLoadData = true;
    });
    await loadList();
    setState(() {
      isLoadData = false;
    });
  }

  void _search() async {
    try {
      setState(() {
        isLoading = true;
      });
      final res = await XServices.instance.getList(
        url: _getUrl,
        cacheName: '${queryController.text}.html',
        isOverride: isOverride,
      );
      list = res;
      lastScroll = 0;
      isOverride = false;
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      showDialogMessage(context, e.toString());
    }
  }

  String get _getUrl =>
      '${appConfigNotifier.value.hostUrl}?k=${queryController.text}/new/$page';

  SliverAppBar _getAppBar() {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      snap: true,
      floating: true,
      flexibleSpace: Row(
        spacing: 5,
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
            ),
          ),
          Expanded(
            child: TextField(
              controller: queryController,
              decoration: InputDecoration(hintText: 'Search'),
              onSubmitted: (value) {
                _search();
              },
              onTapOutside: (event) {
                print('outside');
              },
            ),
          ),
          IconButton(
            onPressed: () {
              queryController.text = '';
            },
            icon: Icon(
              Icons.clear_all,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      contentPadding: 0,
      body: !isLoadData && isLoading
          ? TLoader()
          : RefreshIndicator(
              onRefresh: () async {
                isOverride = true;
                _search();
              },
              child: SafeArea(
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    _getAppBar(),
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
            ),
    );
  }
}
