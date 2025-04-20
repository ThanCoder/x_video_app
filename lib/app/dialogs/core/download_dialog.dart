import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../utils/index.dart';

class DownloadDialog extends StatefulWidget {
  String title;
  String url;
  String message;
  String saveFullPath;
  void Function(String savedPath) onSuccess;
  void Function(String msg) onError;
  DownloadDialog({
    super.key,
    required this.title,
    required this.url,
    required this.saveFullPath,
    required this.message,
    required this.onError,
    required this.onSuccess,
  });

  @override
  State<DownloadDialog> createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<DownloadDialog> {
  @override
  void initState() {
    super.initState();
    init();
  }

  final dio = Dio();
  final CancelToken cancelToken = CancelToken();
  double fileSize = 0;
  double downloadedSize = 0;

  void init() async {
    try {
      //download file
      await dio.download(
        widget.url,
        widget.saveFullPath,
        cancelToken: cancelToken,
        onReceiveProgress: (count, total) {
          if (!mounted) return;
          setState(() {
            fileSize = total.toDouble();
            downloadedSize = count.toDouble();
          });
        },
      );
      widget.onSuccess(widget.saveFullPath);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      widget.onError(e.toString());
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  void _downloadCancel() {
    try {
      cancelToken.cancel();
      // final file = File(widget.saveFullPath);
      // if (file.existsSync()) {
      //   file.deleteSync();
      // }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Text(widget.message),
            LinearProgressIndicator(
              value: fileSize == 0 ? null : downloadedSize / fileSize,
            ),
            //label
            fileSize == 0
                ? const SizedBox.shrink()
                : Text(
                    '${AppUtil.instance.getParseFileSize(downloadedSize)} / ${AppUtil.instance.getParseFileSize(fileSize)}'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _downloadCancel();
          },
          child: const Text('Cancel'),
        ),
        // TextButton(
        //   onPressed:() {
        //           Navigator.pop(context);
        //         },
        //   child: const Text('Upgrade'),
        // ),
      ],
    );
  }
}
