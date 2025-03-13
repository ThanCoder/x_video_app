import 'dart:io';

import 'package:flutter/material.dart';

import '../extensions/index.dart';
import '../components/index.dart';
import '../constants.dart';
import '../dialogs/core/index.dart';
import '../models/index.dart';
import '../notifiers/app_notifier.dart';
import '../services/core/index.dart';
import '../widgets/index.dart';

class AppSettingScreen extends StatefulWidget {
  const AppSettingScreen({super.key});

  @override
  State<AppSettingScreen> createState() => _AppSettingScreenState();
}

class _AppSettingScreenState extends State<AppSettingScreen> {
  @override
  void initState() {
    init();
    super.initState();
  }

  bool isChanged = false;
  bool isCustomPathTextControllerTextSelected = false;
  late AppConfigModel config;
  TextEditingController customPathTextController = TextEditingController();
  TextEditingController proxyAddressController = TextEditingController();
  TextEditingController proxyPortController = TextEditingController();

  void init() async {
    customPathTextController.text = '${getAppExternalRootPath()}/.$appName';
    config = appConfigNotifier.value;
    proxyAddressController.text = config.proxyAddress;
    proxyPortController.text = config.proxyPort;
  }

  void _saveConfig() async {
    try {
      if (Platform.isAndroid && config.isUseCustomPath) {
        if (!await checkStoragePermission()) {
          if (mounted) {
            showConfirmStoragePermissionDialog(context);
          }
          return;
        }
      }
      //set custom path
      config.customPath = customPathTextController.text;
      config.proxyAddress = proxyAddressController.text;
      config.proxyPort = proxyPortController.text;
      //save
      setConfigFile(config);
      appConfigNotifier.value = config;
      if (config.isUseCustomPath) {
        //change
        appRootPathNotifier.value = config.customPath;
      }
      //init config
      await initAppConfigService();
      //init

      if (!mounted) return;
      showMessage(context, 'Config ကိုသိမ်းဆည်းပြီးပါပြီ');
      setState(() {
        isChanged = false;
      });
      Navigator.pop(context);
    } catch (e) {
      debugPrint('saveConfig: ${e.toString()}');
    }
  }

  void _onBackpress() {
    if (!isChanged) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        contentText: 'setting ကိုသိမ်းဆည်းထားချင်ပါသလား?',
        cancelText: 'မသိမ်းဘူး',
        submitText: 'သိမ်းမယ်',
        onCancel: () {
          isChanged = false;
          Navigator.pop(context);
        },
        onSubmit: () {
          _saveConfig();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isChanged,
      onPopInvokedWithResult: (didPop, result) {
        _onBackpress();
      },
      child: MyScaffold(
        appBar: AppBar(
          title: const Text('Setting'),
        ),
        body: ListView(
          children: [
            //custom path
            ListTileWithDesc(
              title: "custom path",
              desc: "သင်ကြိုက်နှစ်သက်တဲ့ path ကို ထည့်ပေးပါ",
              trailing: Checkbox(
                value: config.isUseCustomPath,
                onChanged: (value) {
                  setState(() {
                    config.isUseCustomPath = value!;
                    isChanged = true;
                  });
                },
              ),
            ),
            config.isUseCustomPath
                ? ListTileWithDescWidget(
                    widget1: TextField(
                      controller: customPathTextController,
                      onTap: () {
                        if (!isCustomPathTextControllerTextSelected) {
                          customPathTextController.selectAll();
                          isCustomPathTextControllerTextSelected = true;
                        }
                      },
                      onTapOutside: (event) {
                        isCustomPathTextControllerTextSelected = false;
                      },
                    ),
                    widget2: IconButton(
                      onPressed: () {
                        _saveConfig();
                      },
                      icon: const Icon(
                        Icons.save,
                      ),
                    ),
                  )
                : SizedBox.shrink(),
            //proxy server
            //custom path
            ListTileWithDesc(
              title: "Proxy Server",
              desc: "192.168.191.253:8080",
              trailing: Checkbox(
                value: config.isUseProxyServer,
                onChanged: (value) {
                  setState(() {
                    config.isUseProxyServer = value!;
                    isChanged = true;
                  });
                },
              ),
            ),
            if (config.isUseProxyServer)
              Column(
                spacing: 5,
                children: [
                  Text('Proxy'),
                  Card(
                    child: Row(
                      spacing: 5,
                      children: [
                        Expanded(
                          child: TTextField(
                            controller: proxyAddressController,
                            hintText: '192.168.191.253',
                            onChanged: (value) {
                              setState(() {
                                isChanged = true;
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: TTextField(
                            controller: proxyPortController,
                            hintText: '8080',
                            onChanged: (value) {
                              setState(() {
                                isChanged = true;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else
              SizedBox.shrink(),
          ],
        ),
        floatingActionButton: isChanged
            ? FloatingActionButton(
                onPressed: () {
                  _saveConfig();
                },
                child: const Icon(Icons.save),
              )
            : null,
      ),
    );
  }
}
