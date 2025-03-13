import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/widgets.dart';
import 'package:html/dom.dart' as html;
import 'package:xp_downloader/app/models/x_movie_model.dart' show XMovieModel;
import 'package:xp_downloader/app/notifiers/app_notifier.dart';
import 'package:xp_downloader/app/utils/index.dart';

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
      final dom = html.Document.html(await getCacheHtml(
        getBrowserProxyUrl(url),
        cacheName: cacheName,
        isOverride: isOverride,
      ));
      return dom.outerHtml;
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

  Future<List<XMovieModel>> getList({
    required String url,
    String? cacheName,
    bool isOverride = false,
  }) async {
    List<XMovieModel> list = [];
    try {
      final dom = html.Document.html(await getCacheHtml(
        getBrowserProxyUrl(url),
        cacheName: cacheName,
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

  Future<String> getCacheHtml(
    String url, {
    String? cacheName,
    bool isOverride = false,
  }) async {
    String result = '';
    try {
      final file = File('${PathUtil.instance.getCachePath()}/$cacheName');
      //override မလုပ်ဘူး ၊ file ရှိနေရင်
      if (!isOverride && await file.exists()) {
        return await file.readAsString();
      }
      //မရှိရင်
      final res = await getDio.get(url);
      result = res.data.toString();
      //write cache
      if (cacheName == null) return result;
      await file.writeAsString(result);
    } catch (e) {
      debugPrint(e.toString());
    }
    return result;
  }

  String getForwardProxyUrl(String targetUrl) {
    return '${appConfigNotifier.value.forwardProxyUrl}?url=$targetUrl';
  }

  String getBrowserProxyUrl(String targetUrl) {
    return '${appConfigNotifier.value.browserProxyUrl}?url=$targetUrl';
  }

  Dio get getDio {
    if (appConfigNotifier.value.isUseProxyServer) {
      final proxyAddress = appConfigNotifier.value.proxyAddress;
      final proxyPort = appConfigNotifier.value.proxyPort;
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.findProxy = (uri) {
            // return "PROXY 192.168.191.253:8081";
            return "PROXY $proxyAddress:$proxyPort";
          };
          return client;
        },
      );
    }
    return dio;
  }
}
