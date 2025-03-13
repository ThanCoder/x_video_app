// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/widgets.dart';
import 'package:html/dom.dart' as html;
import 'package:xp_downloader/app/notifiers/app_notifier.dart';

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
    var title = '';
    var url = '';
    var coverUrl = '';
    var time = '';

    try {
      final imgTag = ele.querySelector('.thumb a img');
      coverUrl = imgTag!.attributes['src'] ?? '';
    } catch (e) {
      debugPrint(e.toString());
    }
    try {
      //a tag
      final aTag = ele.querySelector('.title a')!;
      title = aTag.attributes['title'] ?? '';
      url = aTag.attributes['href'] ?? '';

      //time
      time = ele.querySelector('.duration')!.text;
    } catch (e) {
      debugPrint(e.toString());
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
