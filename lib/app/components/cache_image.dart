import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:xp_downloader/app/constants.dart';
import 'package:xp_downloader/app/extensions/index.dart';
import 'package:xp_downloader/app/utils/path_util.dart';
import 'package:xp_downloader/app/widgets/core/index.dart';

class CacheImage extends StatefulWidget {
  String url;
  String? cacheName;
  double? width;
  double? height;
  BoxFit fit;
  double borderRadius;
  CacheImage({
    super.key,
    required this.url,
    this.cacheName,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 5,
  });

  @override
  State<CacheImage> createState() => _CacheImageState();
}

class _CacheImageState extends State<CacheImage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  bool isLoading = true;
  final dio = Dio();

  void init() async {
    try {
      setState(() {
        isLoading = true;
      });

      final cacheFile = File(_getCachePath());
      //မရှိရင် download
      if (!await cacheFile.exists()) {
        await dio.download(widget.url, cacheFile.path);
      }

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      debugPrint(e.toString());
    }
  }

  String _getCachePath() {
    var cacheName = widget.url.getName();
    if (widget.cacheName != null && widget.cacheName!.isNotEmpty) {
      cacheName = widget.cacheName!;
    }
    return '${PathUtil.instance.getCachePath()}/$cacheName';
  }

  Widget _getImageWidget() {
    final file = File(_getCachePath());
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        errorBuilder: (context, error, stackTrace) {
          file.deleteSync();
          return _getAssetsImage();
        },
      );
    } else {
      return _getAssetsImage();
    }
  }

  Widget _getAssetsImage() => Image.asset(
        defaultIconAssetsPath,
        fit: widget.fit,
      );

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return TLoader();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: _getImageWidget(),
    );
  }
}
