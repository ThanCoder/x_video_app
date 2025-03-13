import 'dart:io';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:xp_downloader/app/widgets/index.dart';

class VideoPlayerScreen extends StatefulWidget {
  String title;
  String url;
  VideoPlayerScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  // Create a [Player] to control playback.
  late final player = Player();
  // Create a [VideoController] to handle video output from [Player].
  late final controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    if (Platform.isAndroid) {
      ThanPkg.android.app.hideFullScreen();
    }
    player.dispose();
    super.dispose();
  }

  Future<void> init() async {
    await player.open(Media(widget.url), play: true);
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      contentPadding: 0,
      appBar: AppBar(),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width * 9.0 / 16.0,
          // Use [Video] widget to display video output.
          child: Video(
            controller: controller,
            onEnterFullscreen: () async {
              //check screen height
              try {
                final height = player.state.height ?? 0;
                final width = player.state.width ?? 0;
                if (height > width) {
                  //
                  if (Platform.isAndroid) {
                    // await ThanPkg.android.app.requestOrientation(
                    //     type: ScreenOrientationTypes.Portrait);
                    await ThanPkg.android.app.showFullScreen();
                    return;
                  }
                  if (Platform.isLinux) return;
                }
              } catch (e) {
                debugPrint(e.toString());
              }
              await defaultEnterNativeFullscreen();
            },
            onExitFullscreen: () async {
              try {
                if (Platform.isAndroid) {
                  await ThanPkg.android.app.hideFullScreen();
                }
              } catch (e) {
                debugPrint(e.toString());
              }
              await defaultExitNativeFullscreen();
            },
          ),
        ),
      ),
    );
  }
}
