import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:html/dom.dart' as html;
import 'package:xp_downloader/app/extensions/string_extension.dart';
import 'package:xp_downloader/app/models/x_movie_model.dart' show XMovieModel;
import 'package:xp_downloader/app/services/html_query_selector_services.dart';
import 'package:xp_downloader/app/services/index.dart';

class XServices {
  static final XServices instance = XServices._();
  XServices._();
  factory XServices() => instance;

  XServices get service => XServices();

  final dio = Dio();

  Future<String> getMovieContent(
    String url, {
    required String cacheName,
    bool isOverride = false,
  }) async {
    try {
      // List<XMovieModel> list = [];
      final dom = html.Document.html(await DioServices.instance.getCacheHtml(
        url: DioServices.instance.getBrowserProxyUrl(url),
        cacheName: cacheName,
        isOverride: isOverride,
      ));
      return dom.outerHtml;
    } catch (e) {
      debugPrint(e.toString());
    }
    return '';
  }

  Future<String> getContentCover(String contentUrl) async {
    try {
      // List<XMovieModel> list = [];
      final dom = html.Document.html(await DioServices.instance.getCacheHtml(
        url: DioServices.instance.getBrowserProxyUrl(contentUrl),
        cacheName: '${contentUrl.getName()}.html',
        isOverride: false,
      ));
      final img = dom.querySelector('.video-pic img');
      if (img == null) return '';
      return img.attributes['src'] ?? '';
    } catch (e) {
      debugPrint(e.toString());
    }
    return '';
  }

  String getVideoUrl(String htmlStr) {
    try {
      // RegExp ဖြင့် JSON ဖမ်းယူမည်
      final jsonRegex = RegExp(
          r'<script[^>]*application/ld\+json[^>]*>(.*?)</script>',
          dotAll: true);

      final match = jsonRegex.firstMatch(htmlStr);
      if (match != null) {
        final jsonData = match.group(1);
        if (jsonData == null) return '';
        final json = jsonDecode(jsonData);
        String url = json['contentUrl'] ?? '';
        return url;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return '';
  }

  String getVideoTitle(String htmlStr) {
    final dom = html.Document.html(htmlStr);
    return getQuerySelectorTextDom(dom, '#title-auto-tr');
  }

  Future<List<XMovieModel>> getList({
    required String url,
    String? cacheName,
    bool isOverride = false,
  }) async {
    List<XMovieModel> list = [];
    try {
      final dom = html.Document.html(await DioServices.instance.getCacheHtml(
        url: DioServices.instance.getBrowserProxyUrl(url),
        cacheName: cacheName ?? 'index.html',
        isOverride: isOverride,
      ));
      final eles = dom.querySelectorAll('#content .thumb-block');

      for (var ele in eles) {
        final imgTag = ele.querySelector('.thumb a img');
        if (imgTag == null) continue;
        final movie = XMovieModel.fromHtmlElement(ele);
        list.add(movie);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return list;
  }

  Future<List<XMovieModel>> getContentList({
    required String url,
    String? cacheName,
    bool isOverride = false,
  }) async {
    List<XMovieModel> list = [];
    try {
      final dom = html.Document.html(await DioServices.instance.getCacheHtml(
        url: DioServices.instance.getBrowserProxyUrl(url),
        cacheName: cacheName ?? 'index.html',
        isOverride: isOverride,
      ));
      final eles = dom.querySelectorAll('#related-videos .mozaique > div');

      for (var ele in eles) {
        final imgTag = ele.querySelector('.thumb-related-exo');
        if (imgTag == null) continue;
        final movie = XMovieModel.fromHtmlElement(ele);
        list.add(movie);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return list;
  }

  Future<List<XMovieModel>> getContentListFromHtml(String htmlStr) async {
    List<XMovieModel> list = [];
    try {
      final dom = html.Document.html(htmlStr);
      final eles = dom.querySelectorAll('#related-videos .mozaique > div');

      for (var ele in eles) {
        final imgTag = ele.querySelector('.thumb-related-exo');
        if (imgTag == null) continue;
        final movie = XMovieModel.fromHtmlElement(ele);
        list.add(movie);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return list;
  }
}
