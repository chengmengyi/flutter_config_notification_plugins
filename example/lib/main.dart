import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_config_notification_plugins/flutter_config_notification_plugins.dart';
import 'package:flutter_tba_info_new/flutter_tba_info_new.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _flutterConfigNotificationPluginsPlugin = FlutterConfigNotificationPlugins();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _flutterConfigNotificationPluginsPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: (){
                  _init();
                },
                child: Text("初始化"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _init()async{
    FlutterConfigNotificationPlugins.instance.initNotification(
      icon: 'small_logo',
      channelId: 'editer_pdf_channel',
      channelName: 'editer_pdf_channel_name',
      channelDescription: 'Editer PDF notifications',
      customLayout: AndroidCustomNotificationLayout(
        smallLayoutName: 'small_notification_layout',
        bigLayoutName: 'large_notification_layout',
        actionText: 'Check',
      ),
      showMedia: true,
      remoteRequest: NotificationRemoteRequest(
        url: "https://client.docnovapdftoolreaderscanner.com/api/yearlycurler",
        headers: await _getHeaderMap(),
        body: await _getBodyMap(),
        mapping: mapping,
      ),
    );
  }

  Future<Map<String,dynamic>> _getHeaderMap()async => {
    "x-yearling":kDebugMode?"com.docnova.pdftool.reader.scanner":await FlutterTbaInfoNew.instance.getBundleId(),
    "x-humid":await FlutterTbaInfoNew.instance.getAppVersion(),
  };

  Future<Map<String,dynamic>> _getBodyMap()async {
    var referrerMap = await FlutterTbaInfoNew.instance.getReferrerMap();
    return {
      "comment":Platform.isAndroid?"android":"ios",
      "tractor":await FlutterTbaInfoNew.instance.getDistinctId(),
      "encore":"86690fd94f984a09e472c2cd5ba3aa7a",
      "fraction":await FlutterTbaInfoNew.instance.getManufacturer(),
      "recess":await FlutterTbaInfoNew.instance.getBrand(),
      "oasis":await FlutterTbaInfoNew.instance.getDeviceModel(),
      "expand":await FlutterTbaInfoNew.instance.getOsVersion(),
      "prison":await FlutterTbaInfoNew.instance.getSystemLanguage(),
      "narrow":await FlutterTbaInfoNew.instance.getOsCountry(),
      "badge":referrerMap["referrer_url"],
      "myspace":DateTime.now().millisecondsSinceEpoch,
      "headed":await FlutterTbaInfoNew.instance.getAndroidId(),
      "saddled":await FlutterTbaInfoNew.instance.getGaid(),
      "whisking":await FlutterTbaInfoNew.instance.getIdfa(),
      "thicket":await FlutterTbaInfoNew.instance.isEmulator(),
      "daily":await FlutterTbaInfoNew.instance.isDeveloper(),
      "unexposed":await FlutterTbaInfoNew.instance.isAdb(),
      "density":await FlutterTbaInfoNew.instance.hasSim(),
      "senate":await FlutterTbaInfoNew.instance.isFirebaseTestLab(),
    };
  }
}
