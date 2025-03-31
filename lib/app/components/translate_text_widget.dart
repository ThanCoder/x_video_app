import 'package:flutter/material.dart';
import 'package:xp_downloader/app/services/translator_services.dart';

class TranslateTextWidget extends StatelessWidget {
  String text;
  TranslateTextWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: TranslatorServices.instance.translate(text),
      builder: (context, snapshot) {
        String title = text;
        if (snapshot.hasData) {
          title = snapshot.data ?? text;
        }
        return Text(
          title,
          maxLines: 4,
          style: TextStyle(
            fontSize: 12,
          ),
        );
      },
    );
  }
}
