import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:xp_downloader/app/utils/app_util.dart';
import 'package:xp_downloader/app/widgets/core/index.dart';

class SizeTextFromUrl extends StatelessWidget {
  String url;
  SizeTextFromUrl({super.key, required this.url});

  final dio = Dio();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: dio.head(url),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: 25,
            height: 25,
            child: TLoader(size: 25),
          );
        }
        if (snapshot.hasData) {
          final res = snapshot.data!;
          if (res.headers['content-length'] != null) {
            final contentLength =
                int.tryParse(res.headers['content-length']!.first);
            if (contentLength != null) {
              return Text(
                  AppUtil.instance.getParseFileSize(contentLength.toDouble()));
            }
          }
        }
        return SizedBox.shrink();
      },
    );
  }
}
