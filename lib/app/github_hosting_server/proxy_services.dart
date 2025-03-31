import 'dart:convert';

import 'package:xp_downloader/app/github_hosting_server/hosting_constants.dart';
import 'package:xp_downloader/app/services/core/dio_services.dart';

class ProxyServices {
  static Future<List<String>> getForwardProxyList() async {
    final res =
        await DioServices.instance.getDio.get(hostingForwardProxyListUrl);
    final data = res.data;
    if (data.isEmpty) return [];
    return List<String>.from(jsonDecode(data));
  }

  static Future<List<String>> getBrowserProxyList() async {
    final res =
        await DioServices.instance.getDio.get(hostingBrowserProxyListUrl);
    final data = res.data;
    if (data.isEmpty) return [];
    return List<String>.from(jsonDecode(data));
  }
}
