import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:xp_downloader/app/constants.dart';
import 'package:xp_downloader/app/models/x_movie_model.dart';
import 'package:xp_downloader/app/utils/path_util.dart';

class BookmarkServices {
  static final BookmarkServices instance = BookmarkServices._();
  BookmarkServices._();
  factory BookmarkServices() => instance;

  Future<void> toggle({required XMovieModel movie}) async {
    try {
      if (await isExists(movie: movie)) {
        await remove(movie: movie);
      } else {
        await add(movie: movie);
      }
    } catch (e) {
      debugPrint('toggle: ${e.toString()}');
    }
  }

  Future<void> add({required XMovieModel movie}) async {
    try {
      final dbFile = File(getDBPath());
      final list = await getList();
      list.insert(0, movie);
      //save
      final data = list.map((mv) => mv.toMap()).toList();
      await dbFile.writeAsString(jsonEncode(data));
    } catch (e) {
      debugPrint('add: ${e.toString()}');
    }
  }

  Future<void> remove({required XMovieModel movie}) async {
    try {
      final dbFile = File(getDBPath());
      var list = await getList();
      list = list.where((mv) => mv.title != movie.title).toList();
      //save
      await dbFile.writeAsString(jsonEncode(list));
    } catch (e) {
      debugPrint('remove: ${e.toString()}');
    }
  }

  Future<bool> isExists({required XMovieModel movie}) async {
    bool res = false;
    try {
      final list = await getList();
      res = list.any((mv) => mv.title == movie.title);
    } catch (e) {
      debugPrint('isExists: ${e.toString()}');
    }
    return res;
  }

  Future<List<XMovieModel>> getList() async {
    List<XMovieModel> list = [];
    try {
      final dbFile = File(getDBPath());
      if (!await dbFile.exists()) return list;
      List<dynamic> res = jsonDecode(await dbFile.readAsString());
      list = res.map((map) => XMovieModel.fromMap(map)).toList();
    } catch (e) {
      debugPrint('getList: ${e.toString()}');
    }
    return list;
  }

  String getDBPath() {
    return '${PathUtil.instance.getDatabasePath()}/$appBookmarkDatabaseName';
  }
}
