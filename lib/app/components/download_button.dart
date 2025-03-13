import 'dart:io';

import 'package:flutter/material.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:xp_downloader/app/components/size_text_from_url.dart';
import 'package:xp_downloader/app/dialogs/index.dart';
import 'package:xp_downloader/app/notifiers/app_notifier.dart';
import 'package:xp_downloader/app/screens/video_player_screen.dart';

class DownloadButton extends StatefulWidget {
  String title;
  String url;
  String savePath;
  void Function() onDoned;
  DownloadButton({
    super.key,
    required this.title,
    required this.savePath,
    required this.url,
    required this.onDoned,
  });

  @override
  State<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  bool isExists = false;

  void init() async {
    try {
      final file = File(widget.savePath);
      isExists = await file.exists();
      setState(() {});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _download() async {
    //check permission
    if (Platform.isAndroid) {
      if (!await ThanPkg.android.permission.isStoragePermissionGranted()) {
        await ThanPkg.android.permission.requestStoragePermission();
        return;
      }
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DownloadDialog(
        title: 'Downlaoding...',
        url: '${appConfigNotifier.value.forwardProxyUrl}?url=${widget.url}',
        saveFullPath: widget.savePath,
        message: widget.title,
        onError: (msg) {},
        onSuccess: (savedPath) {
          init();
          widget.onDoned();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: _download,
              icon:
                  Icon(isExists ? Icons.download_done_rounded : Icons.download),
            ),
            SizeTextFromUrl(
                url:
                    '${appConfigNotifier.value.forwardProxyUrl}?url=${widget.url}'),
          ],
        ),
        //watch
        TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPlayerScreen(
                    title: '',
                    url:
                        '${appConfigNotifier.value.forwardProxyUrl}?url=${widget.url}',
                  ),
                ),
              );
            },
            child: Text('Watch')),
      ],
    );
  }
}
