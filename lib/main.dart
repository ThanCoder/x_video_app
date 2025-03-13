import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:xp_downloader/app/providers/x_movie_provider.dart';

import 'app/my_app.dart';
import 'app/services/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThanPkg.windowManagerensureInitialized();

  //init config
  await initAppConfigService();

  MediaKit.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => XMovieProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
