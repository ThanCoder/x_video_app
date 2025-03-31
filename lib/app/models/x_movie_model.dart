// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/widgets.dart';
import 'package:html/dom.dart' as html;
import 'package:xp_downloader/app/notifiers/app_notifier.dart';
import 'package:xp_downloader/app/services/html_query_selector_services.dart';

class XMovieModel {
  String title;
  String url;
  String coverUrl;
  String time;
  String videoUrl;
  XMovieModel({
    required this.title,
    required this.url,
    required this.coverUrl,
    this.videoUrl = '',
    required this.time,
  });

  factory XMovieModel.fromHtmlElement(html.Element ele) {
    var title = getQuerySelectorAttr(ele, '.title a', 'title');
    var url = getQuerySelectorAttr(ele, '.title a', 'href');
    var coverUrl = getQuerySelectorAttr(ele, '.thumb img', 'src');
    var time = getQuerySelectorText(ele, '.duration');

    if (coverUrl.isEmpty) {
      coverUrl = getQuerySelectorAttr(ele, '.thumb a', 'data-src');
    }

    try {
      if (ele.querySelector('.videopv a') != null) {
        final videoTag = ele.querySelector('.videopv a')!;
        url = videoTag.attributes['href'] ?? '';
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    //url `/` နဲ့ လား စစ်မယ်
    if (url.isNotEmpty && url.substring(0, 2).startsWith('/')) {
      url = '${appConfigNotifier.value.hostUrl}$url';
    }

    return XMovieModel(
      title: title,
      url: url,
      coverUrl: coverUrl,
      time: time,
    );
  }

  factory XMovieModel.fromMap(Map<String, dynamic> map) {
    return XMovieModel(
      title: map['title'],
      url: map['url'],
      coverUrl: map['cover_url'],
      videoUrl: map['video_url'],
      time: map['time'],
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'url': url,
        'cover_url': coverUrl,
        'video_url': videoUrl,
        'time': time,
      };

  @override
  String toString() {
    return title;
  }
}
