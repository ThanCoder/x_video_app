import 'package:flutter/material.dart';
import 'package:xp_downloader/app/models/x_movie_model.dart';
import 'package:xp_downloader/app/notifiers/app_notifier.dart';
import 'package:xp_downloader/app/services/x_services.dart';

class XMovieProvider with ChangeNotifier {
  final List<XMovieModel> _list = [];
  bool isLoading = false;
  int page = 1;
  bool isOverrideList = true;

  List<XMovieModel> get getList => _list;
  void setListOverride(bool isOverride) {
    isOverrideList = isOverride;
  }

  Future<void> initList() async {
    try {
      page = 1;
      isLoading = true;
      notifyListeners();
      if (isOverrideList) {
        _list.clear();
      }
      final res = await XServices.instance.getList(
        url: appConfigNotifier.value.hostUrl,
        isOverride: isOverrideList,
        cacheName: 'home.html',
      );
      _list.addAll(res);
      isLoading = false;
      isOverrideList = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      debugPrint(e.toString());
    }
  }

  void loadList() async {
    try {
      isLoading = true;
      notifyListeners();
      final res = await XServices.instance.getList(
        url: '${appConfigNotifier.value.hostUrl}/new/$page',
      );
      page++;
      _list.addAll(res);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      debugPrint(e.toString());
    }
  }
}
