// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:xp_downloader/app/constants.dart';

class AppConfigModel {
  bool isUseCustomPath;
  String customPath;
  bool isDarkTheme;
  //proxy
  String hostUrl;
  String forwardProxyUrl;
  String browserProxyUrl;

  AppConfigModel({
    this.isUseCustomPath = false,
    this.customPath = '',
    this.isDarkTheme = false,
    this.hostUrl = appHostUrl,
    this.forwardProxyUrl = appForwardProxyHostUrl,
    this.browserProxyUrl = appBrowserProxyHostUrl,
  });

  factory AppConfigModel.fromJson(Map<String, dynamic> map) {
    return AppConfigModel(
      isUseCustomPath: map['is_use_custom_path'] ?? '',
      customPath: map['custom_path'] ?? '',
      isDarkTheme: map['is_dark_theme'] ?? false,
      //proxy
      hostUrl: map['host_url'] ?? appHostUrl,
      forwardProxyUrl: map['forward_proxy_url'] ?? appForwardProxyHostUrl,
      browserProxyUrl: map['browser_proxy_url'] ?? appBrowserProxyHostUrl,
    );
  }
  Map<String, dynamic> toJson() => {
        'is_use_custom_path': isUseCustomPath,
        'custom_path': customPath,
        'is_dark_theme': isDarkTheme,
        'host_url': hostUrl,
        'forward_proxy_url': forwardProxyUrl,
        'browser_proxy_url': browserProxyUrl,
      };
}
