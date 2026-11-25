import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_config_notification_plugins/flutter_config_notification_plugins.dart';
import 'package:flutter_tba_info_new/flutter_tba_info_new.dart';

const String mapping = """{
  "code": "decal",
  "msg": "earpiece",
  "data": "concur",
  "data.notification": "concur.revisable",
  "data.notification.enabled": "concur.revisable.catalyst",
  "data.notification.first_send_delay_minutes": "concur.revisable.scam",
  "data.notification.notification_interval_minutes": "concur.revisable.risotto",
  "data.notification.notification_total_limit": "concur.revisable.serpent",
  "data.notification.refresh_enabled": "concur.revisable.hastiness",
  "data.notification.refresh_interval_seconds": "concur.revisable.palace",
  "data.notification.refresh_duration_seconds": "concur.revisable.womanhood",
  "data.notification.scheduled_enabled": "concur.revisable.statutory",
  "data.notification.scheduled_notification_arr": "concur.revisable.avid",
  "data.notification.scheduled_notification_arr.*.id": "concur.revisable.avid.*.starboard",
  "data.notification.scheduled_notification_arr.*.channel_name": "concur.revisable.avid.*.ferment",
  "data.notification.scheduled_notification_arr.*.first_delay": "concur.revisable.avid.*.colonize",
  "data.notification.scheduled_notification_arr.*.interval": "concur.revisable.avid.*.resale",
  "data.notification.scheduled_notification_arr.*.send_limit": "concur.revisable.avid.*.deniable",
  "data.notification.scheduled_notification_arr.*.background_trigger_delay_seconds": "concur.revisable.avid.*.resigned",
  "data.notification.scheduled_notification_arr.*.copy_pool": "concur.revisable.avid.*.jackknife",
  "data.notification.scheduled_notification_arr.*.copy_pool.*.id": "concur.revisable.avid.*.jackknife.*.robbing",
  "data.notification.scheduled_notification_arr.*.copy_pool.*.language": "concur.revisable.avid.*.jackknife.*.figment",
  "data.notification.scheduled_notification_arr.*.copy_pool.*.title": "concur.revisable.avid.*.jackknife.*.eternity",
  "data.notification.scheduled_notification_arr.*.copy_pool.*.body": "concur.revisable.avid.*.jackknife.*.cough",
  "data.notification.scheduled_notification_arr.*.copy_pool.*.image": "concur.revisable.avid.*.jackknife.*.announcer",
  "data.notification.scheduled_notification_arr.*.copy_pool.*.button_text": "concur.revisable.avid.*.jackknife.*.siren",
  "data.notification.scheduled_notification_arr.*.copy_pool.*.secondary_button_text": "concur.revisable.avid.*.jackknife.*.mama",
  "data.notification.broadcast_enabled": "concur.revisable.capital",
  "data.notification.broadcast_config": "concur.revisable.recycled",
  "data.notification.broadcast_config.send_interval_minutes": "concur.revisable.recycled.surfer",
  "data.notification.broadcast_config.send_limit": "concur.revisable.recycled.wiry",
  "data.notification.broadcast_config.unlock_enabled": "concur.revisable.recycled.undying",
  "data.notification.broadcast_config.unlock_daily_limit": "concur.revisable.recycled.rework",
  "data.notification.broadcast_config.unlock_delay_seconds": "concur.revisable.recycled.unlatch",
  "data.notification.broadcast_config.unlock_copy_pool": "concur.revisable.recycled.remedial",
  "data.notification.broadcast_config.unlock_copy_pool.*.id": "concur.revisable.recycled.remedial.*.bunt",
  "data.notification.broadcast_config.unlock_copy_pool.*.language": "concur.revisable.recycled.remedial.*.reanalyze",
  "data.notification.broadcast_config.unlock_copy_pool.*.title": "concur.revisable.recycled.remedial.*.pusher",
  "data.notification.broadcast_config.unlock_copy_pool.*.body": "concur.revisable.recycled.remedial.*.county",
  "data.notification.broadcast_config.unlock_copy_pool.*.image": "concur.revisable.recycled.remedial.*.pantyhose",
  "data.notification.broadcast_config.unlock_copy_pool.*.button_text": "concur.revisable.recycled.remedial.*.supremacy",
  "data.notification.broadcast_config.unlock_copy_pool.*.secondary_button_text": "concur.revisable.recycled.remedial.*.roamer",
  "data.notification.broadcast_config.exit_background_enabled": "concur.revisable.recycled.treadmill",
  "data.notification.broadcast_config.exit_background_daily_limit": "concur.revisable.recycled.elusive",
  "data.notification.broadcast_config.exit_background_delay_seconds": "concur.revisable.recycled.acuteness",
  "data.notification.broadcast_config.exit_background_copy_pool": "concur.revisable.recycled.clubbing",
  "data.notification.broadcast_config.exit_background_copy_pool.*.id": "concur.revisable.recycled.clubbing.*.giggling",
  "data.notification.broadcast_config.exit_background_copy_pool.*.language": "concur.revisable.recycled.clubbing.*.baton",
  "data.notification.broadcast_config.exit_background_copy_pool.*.title": "concur.revisable.recycled.clubbing.*.everglade",
  "data.notification.broadcast_config.exit_background_copy_pool.*.body": "concur.revisable.recycled.clubbing.*.aching",
  "data.notification.broadcast_config.exit_background_copy_pool.*.image": "concur.revisable.recycled.clubbing.*.supervise",
  "data.notification.broadcast_config.exit_background_copy_pool.*.button_text": "concur.revisable.recycled.clubbing.*.dwarf",
  "data.notification.broadcast_config.exit_background_copy_pool.*.secondary_button_text": "concur.revisable.recycled.clubbing.*.parsley",
  "data.notification.broadcast_config.file_listener_enabled": "concur.revisable.recycled.scurvy",
  "data.notification.broadcast_config.file_listener_daily_limit": "concur.revisable.recycled.alto",
  "data.notification.broadcast_config.file_listener_delay_seconds": "concur.revisable.recycled.sash",
  "data.notification.broadcast_config.file_listener_copy_pool": "concur.revisable.recycled.these",
  "data.notification.broadcast_config.file_listener_copy_pool.*.id": "concur.revisable.recycled.these.*.easily",
  "data.notification.broadcast_config.file_listener_copy_pool.*.language": "concur.revisable.recycled.these.*.lethargic",
  "data.notification.broadcast_config.file_listener_copy_pool.*.title": "concur.revisable.recycled.these.*.onlooker",
  "data.notification.broadcast_config.file_listener_copy_pool.*.body": "concur.revisable.recycled.these.*.uselessly",
  "data.notification.broadcast_config.file_listener_copy_pool.*.image": "concur.revisable.recycled.these.*.papyrus",
  "data.notification.broadcast_config.file_listener_copy_pool.*.button_text": "concur.revisable.recycled.these.*.ignore",
  "data.notification.broadcast_config.file_listener_copy_pool.*.secondary_button_text": "concur.revisable.recycled.these.*.grouped",
  "data.notification.broadcast_config.power_connection_enabled": "concur.revisable.recycled.humpback",
  "data.notification.broadcast_config.power_connection_daily_limit": "concur.revisable.recycled.fragrance",
  "data.notification.broadcast_config.power_connection_delay_seconds": "concur.revisable.recycled.onto",
  "data.notification.broadcast_config.power_connection_copy_pool": "concur.revisable.recycled.stoppable",
  "data.notification.broadcast_config.power_connection_copy_pool.*.id": "concur.revisable.recycled.stoppable.*.undermine",
  "data.notification.broadcast_config.power_connection_copy_pool.*.language": "concur.revisable.recycled.stoppable.*.wieldable",
  "data.notification.broadcast_config.power_connection_copy_pool.*.title": "concur.revisable.recycled.stoppable.*.mushily",
  "data.notification.broadcast_config.power_connection_copy_pool.*.body": "concur.revisable.recycled.stoppable.*.gaffe",
  "data.notification.broadcast_config.power_connection_copy_pool.*.image": "concur.revisable.recycled.stoppable.*.armband",
  "data.notification.broadcast_config.power_connection_copy_pool.*.button_text": "concur.revisable.recycled.stoppable.*.sasquatch",
  "data.notification.broadcast_config.power_connection_copy_pool.*.secondary_button_text": "concur.revisable.recycled.stoppable.*.schedule",
  "data.notification.broadcast_config.reboot_enabled": "concur.revisable.recycled.resurface",
  "data.notification.broadcast_config.reboot_daily_limit": "concur.revisable.recycled.coping",
  "data.notification.broadcast_config.reboot_delay_seconds": "concur.revisable.recycled.removal",
  "data.notification.broadcast_config.reboot_copy_pool": "concur.revisable.recycled.reggae",
  "data.notification.broadcast_config.reboot_copy_pool.*.id": "concur.revisable.recycled.reggae.*.ruined",
  "data.notification.broadcast_config.reboot_copy_pool.*.language": "concur.revisable.recycled.reggae.*.slit",
  "data.notification.broadcast_config.reboot_copy_pool.*.title": "concur.revisable.recycled.reggae.*.entomb",
  "data.notification.broadcast_config.reboot_copy_pool.*.body": "concur.revisable.recycled.reggae.*.handiness",
  "data.notification.broadcast_config.reboot_copy_pool.*.image": "concur.revisable.recycled.reggae.*.corral",
  "data.notification.broadcast_config.reboot_copy_pool.*.button_text": "concur.revisable.recycled.reggae.*.stinger",
  "data.notification.broadcast_config.reboot_copy_pool.*.secondary_button_text": "concur.revisable.recycled.reggae.*.reproach",
  "data.notification.broadcast_config.ad_click_enabled": "concur.revisable.recycled.revolver",
  "data.notification.broadcast_config.ad_click_daily_limit": "concur.revisable.recycled.legume",
  "data.notification.broadcast_config.ad_click_delay_seconds": "concur.revisable.recycled.lunar",
  "data.notification.broadcast_config.ad_click_copy_pool": "concur.revisable.recycled.exemption",
  "data.notification.broadcast_config.ad_click_copy_pool.*.id": "concur.revisable.recycled.exemption.*.herald",
  "data.notification.broadcast_config.ad_click_copy_pool.*.language": "concur.revisable.recycled.exemption.*.monastery",
  "data.notification.broadcast_config.ad_click_copy_pool.*.title": "concur.revisable.recycled.exemption.*.eggnog",
  "data.notification.broadcast_config.ad_click_copy_pool.*.body": "concur.revisable.recycled.exemption.*.umbrella",
  "data.notification.broadcast_config.ad_click_copy_pool.*.image": "concur.revisable.recycled.exemption.*.numerator",
  "data.notification.broadcast_config.ad_click_copy_pool.*.button_text": "concur.revisable.recycled.exemption.*.elongated",
  "data.notification.broadcast_config.ad_click_copy_pool.*.secondary_button_text": "concur.revisable.recycled.exemption.*.gesture",
  "data.notification.broadcast_config.home_key_enabled": "concur.revisable.recycled.upcoming",
  "data.notification.broadcast_config.home_key_daily_limit": "concur.revisable.recycled.construct",
  "data.notification.broadcast_config.home_key_delay_seconds": "concur.revisable.recycled.gander",
  "data.notification.broadcast_config.home_key_copy_pool": "concur.revisable.recycled.banknote",
  "data.notification.broadcast_config.home_key_copy_pool.*.id": "concur.revisable.recycled.banknote.*.scrunch",
  "data.notification.broadcast_config.home_key_copy_pool.*.language": "concur.revisable.recycled.banknote.*.scouting",
  "data.notification.broadcast_config.home_key_copy_pool.*.title": "concur.revisable.recycled.banknote.*.lifter",
  "data.notification.broadcast_config.home_key_copy_pool.*.body": "concur.revisable.recycled.banknote.*.brought",
  "data.notification.broadcast_config.home_key_copy_pool.*.image": "concur.revisable.recycled.banknote.*.uncouth",
  "data.notification.broadcast_config.home_key_copy_pool.*.button_text": "concur.revisable.recycled.banknote.*.sliceable",
  "data.notification.broadcast_config.home_key_copy_pool.*.secondary_button_text": "concur.revisable.recycled.banknote.*.spoils",
  "data.notification.broadcast_config.recent_apps_key_enabled": "concur.revisable.recycled.capably",
  "data.notification.broadcast_config.recent_apps_key_daily_limit": "concur.revisable.recycled.bulgur",
  "data.notification.broadcast_config.recent_apps_key_delay_seconds": "concur.revisable.recycled.armed",
  "data.notification.broadcast_config.recent_apps_key_copy_pool": "concur.revisable.recycled.flyer",
  "data.notification.broadcast_config.recent_apps_key_copy_pool.*.id": "concur.revisable.recycled.flyer.*.disaster",
  "data.notification.broadcast_config.recent_apps_key_copy_pool.*.language": "concur.revisable.recycled.flyer.*.skittle",
  "data.notification.broadcast_config.recent_apps_key_copy_pool.*.title": "concur.revisable.recycled.flyer.*.ecosystem",
  "data.notification.broadcast_config.recent_apps_key_copy_pool.*.body": "concur.revisable.recycled.flyer.*.aqueduct",
  "data.notification.broadcast_config.recent_apps_key_copy_pool.*.image": "concur.revisable.recycled.flyer.*.stiffly",
  "data.notification.broadcast_config.recent_apps_key_copy_pool.*.button_text": "concur.revisable.recycled.flyer.*.gradually",
  "data.notification.broadcast_config.recent_apps_key_copy_pool.*.secondary_button_text": "concur.revisable.recycled.flyer.*.player",
  "data.notification.broadcast_config.screen_wake_up_enabled": "concur.revisable.recycled.unengaged",
  "data.notification.broadcast_config.screen_wake_up_daily_limit": "concur.revisable.recycled.projector",
  "data.notification.broadcast_config.screen_wake_up_delay_seconds": "concur.revisable.recycled.trustless",
  "data.notification.broadcast_config.screen_wake_up_copy_pool": "concur.revisable.recycled.showroom",
  "data.notification.broadcast_config.screen_wake_up_copy_pool.*.id": "concur.revisable.recycled.showroom.*.antacid",
  "data.notification.broadcast_config.screen_wake_up_copy_pool.*.language": "concur.revisable.recycled.showroom.*.cold",
  "data.notification.broadcast_config.screen_wake_up_copy_pool.*.title": "concur.revisable.recycled.showroom.*.niece",
  "data.notification.broadcast_config.screen_wake_up_copy_pool.*.body": "concur.revisable.recycled.showroom.*.shifting",
  "data.notification.broadcast_config.screen_wake_up_copy_pool.*.image": "concur.revisable.recycled.showroom.*.cosmic",
  "data.notification.broadcast_config.screen_wake_up_copy_pool.*.button_text": "concur.revisable.recycled.showroom.*.barcode",
  "data.notification.broadcast_config.screen_wake_up_copy_pool.*.secondary_button_text": "concur.revisable.recycled.showroom.*.derail",
  "data.notification.media_enabled": "concur.revisable.repave",
  "data.notification.media_notification_arr": "concur.revisable.wrist",
  "data.notification.media_notification_arr.*.id": "concur.revisable.wrist.*.emptier",
  "data.notification.media_notification_arr.*.channel_name": "concur.revisable.wrist.*.cornflake",
  "data.notification.media_notification_arr.*.first_delay": "concur.revisable.wrist.*.deface",
  "data.notification.media_notification_arr.*.interval": "concur.revisable.wrist.*.legged",
  "data.notification.media_notification_arr.*.copy_pool": "concur.revisable.wrist.*.thimble",
  "data.notification.media_notification_arr.*.copy_pool.*.id": "concur.revisable.wrist.*.thimble.*.monogram",
  "data.notification.media_notification_arr.*.copy_pool.*.language": "concur.revisable.wrist.*.thimble.*.unheated",
  "data.notification.media_notification_arr.*.copy_pool.*.title": "concur.revisable.wrist.*.thimble.*.frisbee",
  "data.notification.media_notification_arr.*.copy_pool.*.body": "concur.revisable.wrist.*.thimble.*.envoy",
  "data.notification.media_notification_arr.*.copy_pool.*.image": "concur.revisable.wrist.*.thimble.*.operation",
  "data.notification.media_notification_arr.*.copy_pool.*.button_text": "concur.revisable.wrist.*.thimble.*.unmatched",
  "data.notification.media_notification_arr.*.copy_pool.*.secondary_button_text": "concur.revisable.wrist.*.thimble.*.decay",
  "data.notification.persistent_enabled": "concur.revisable.lunchtime",
  "data.notification.persistent_config": "concur.revisable.ahoy",
  "data.notification.persistent_config.update_interval_minutes": "concur.revisable.ahoy.glorious",
  "data.notification.persistent_config.action_url": "concur.revisable.ahoy.catfight",
  "data.notification.persistent_config.allow_dismiss": "concur.revisable.ahoy.doorstop",
  "data.notification.persistent_config.copy_pool": "concur.revisable.ahoy.actress",
  "data.notification.persistent_config.copy_pool.*.id": "concur.revisable.ahoy.actress.*.follow",
  "data.notification.persistent_config.copy_pool.*.language": "concur.revisable.ahoy.actress.*.document",
  "data.notification.persistent_config.copy_pool.*.title": "concur.revisable.ahoy.actress.*.blame",
  "data.notification.persistent_config.copy_pool.*.body": "concur.revisable.ahoy.actress.*.oblivious",
  "data.notification.persistent_config.copy_pool.*.image": "concur.revisable.ahoy.actress.*.runt",
  "data.notification.persistent_config.copy_pool.*.button_text": "concur.revisable.ahoy.actress.*.sitter",
  "data.notification.persistent_config.copy_pool.*.secondary_button_text": "concur.revisable.ahoy.actress.*.landless",
  "data.notification.floating_window_enabled": "concur.revisable.curry",
  "data.notification.floating_window_config": "concur.revisable.expansive",
  "data.notification.floating_window_config.only_send_floating_window": "concur.revisable.expansive.reburial",
  "data.notification.floating_window_config.trigger_with_scheduled": "concur.revisable.expansive.conform",
  "data.notification.floating_window_config.trigger_with_broadcast": "concur.revisable.expansive.professed",
  "data.notification.floating_window_config.standalone_enabled": "concur.revisable.expansive.superglue",
  "data.notification.floating_window_config.standalone_interval_minutes": "concur.revisable.expansive.promotion",
  "data.notification.floating_window_config.standalone_daily_limit": "concur.revisable.expansive.kilogram",
  "data.notification.floating_window_config.misclick_enabled": "concur.revisable.expansive.thinning",
  "data.notification.floating_window_config.misclick_percent": "concur.revisable.expansive.tapering",
  "data.notification.floating_window_config.copy_pool": "concur.revisable.expansive.landlord",
  "data.notification.floating_window_config.copy_pool.*.id": "concur.revisable.expansive.landlord.*.boondocks",
  "data.notification.floating_window_config.copy_pool.*.language": "concur.revisable.expansive.landlord.*.vendor",
  "data.notification.floating_window_config.copy_pool.*.title": "concur.revisable.expansive.landlord.*.overdraft",
  "data.notification.floating_window_config.copy_pool.*.body": "concur.revisable.expansive.landlord.*.commence",
  "data.notification.floating_window_config.copy_pool.*.image": "concur.revisable.expansive.landlord.*.vitality",
  "data.notification.floating_window_config.copy_pool.*.button_text": "concur.revisable.expansive.landlord.*.strongman",
  "data.notification.floating_window_config.copy_pool.*.secondary_button_text": "concur.revisable.expansive.landlord.*.regress"
}""";

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
  final _flutterConfigNotificationPluginsPlugin =
      FlutterConfigNotificationPlugins();

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
          await _flutterConfigNotificationPluginsPlugin.getPlatformVersion() ??
          'Unknown platform version';
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
                onPressed: () {
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

  _init() async {
    var result = await FlutterConfigNotificationPlugins.instance.initNotification(
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
    print("kk====${result}");
    if (result) {
      FlutterConfigNotificationPlugins.instance
          .periodicallyShowLocalWithDuration();
      FlutterConfigNotificationPlugins.instance
          .registerBroadcastNotifications();
      FlutterConfigNotificationPlugins.instance.periodicallyShowMediaWithDuration(
        image: "large_notification_image",
        reflectionConfig: MediaReflectionConfig(
          secret: "SecretKey24",
          mediaSessionClass:
              "v1:kimK2JRQ9Zu5d9Ys:ywqPQx2rQ30RnIK2FSvxyLupjAkYNPvLEO1NAPL41C8WbvqtR3c3HQmMfHnwKJYLckahepi6ZLOcnBLPYiJ/zaDzRw==",
          mediaSessionTokenClass:
              "v1:xtRK9N9FJW2uK9ZA:0/WbDN0iQqwXYvSrh4hGv7CBox7a9h65wmb+hHALsJW4RJOJE9vd8V82amwJa0N7HnI4106wKc9fxY7JSYOfHs58ai3xdO3NAA==",
          mediaSessionTag:
              "v1:3qKCANxbV4z7gT4e:mMYf32xvnmOmKsVUGP8zK9QTsF/eapJd9M5wjAruOw==",
          playbackStateClass:
              "v1:qNcBl54FsP6UJSay:FMBeKNk33i+V3WB7IsdwOeP6icncoFrXXfOiXPzxbUtIHiM8W68ZJky/W/dqymo5g+5dbs4Vvw9WPkkStrCU3hoyIhc=",
          playbackStateBuilderClass:
              "v1:jZM5JX1cWfhcWCor:miduXsdltGTWG6EKOi6Rmd9kPfYEjBJ80vw4goeO4TbBHpp9DdoIfeDsCQGlHxfWE7V8QcnfI59ezjaGCV3wkxsKykpGVUJ4BIbcOg==",
          mediaStyleClass:
              "v1:CatTUHyjEyrob1G6:NsytCf/A5R/1p4IyEa3qg9EL2YS7tNPeFMQBm4ZTbMBsctrPJVMHzIzyBotmOAG3eMdpJPpugrXYgJB7xjDgKQ==",
          setFlagsMethod:
              "v1:zj6HAPvHLCC0BANj:gUrH9oJlvdqk/6Ua1shYYk2/kA50cuRd",
          setActiveMethod:
              "v1:XBHug4XPgwamFziy:jwN0UoWFP8t7fHKTUqci0fThzDVyteHRwQ==",
          setPlaybackStateMethod:
              "v1:OrnHtH8x/IUcOrqt:ewHLXPne2FrRGBglNE1hclcG606PUkfb5gUfX4KtOYo=",
          getSessionTokenMethod:
              "v1:7yBBivuhWoDhEbq7:t/HdAeNqNWXhJ1Ibzmx2dZa1a7iXYwrVfkmcL8Ee7A==",
          setStateMethod:
              "v1:zrJwVW6tDQluRCix:hjCFcs36cnJCVKhFRBmhkGzcLX76IcsL",
          buildMethod: "v1:npn3FLXm+kPSQCN8:NQBkIuMmW2Q75wOnYuifOyj9PGPB",
          setMediaSessionMethod:
              "v1:cfNQH5VlqfaNXotF:gg1Jk9x7IJM7LC2eLaxEsUzUlG/mRL31pZNB+34cZg==",
        ),
      );
    }
  }

  Future<Map<String, dynamic>> _getHeaderMap() async => {
    "x-yearling": kDebugMode
        ? "com.docnova.pdftool.reader.scanner"
        : await FlutterTbaInfoNew.instance.getBundleId(),
    "x-humid": await FlutterTbaInfoNew.instance.getAppVersion(),
  };

  Future<Map<String, dynamic>> _getBodyMap() async {
    var referrerMap = await FlutterTbaInfoNew.instance.getReferrerMap();
    return {
      "comment": Platform.isAndroid ? "android" : "ios",
      "tractor": await FlutterTbaInfoNew.instance.getDistinctId(),
      "encore": "86690fd94f984a09e472c2cd5ba3aa7a",
      "fraction": await FlutterTbaInfoNew.instance.getManufacturer(),
      "recess": await FlutterTbaInfoNew.instance.getBrand(),
      "oasis": await FlutterTbaInfoNew.instance.getDeviceModel(),
      "expand": await FlutterTbaInfoNew.instance.getOsVersion(),
      "prison": "en_US",
      "narrow": await FlutterTbaInfoNew.instance.getOsCountry(),
      "badge": referrerMap["referrer_url"],
      "myspace": DateTime.now().millisecondsSinceEpoch,
      "headed": await FlutterTbaInfoNew.instance.getAndroidId(),
      "saddled": await FlutterTbaInfoNew.instance.getGaid(),
      "whisking": await FlutterTbaInfoNew.instance.getIdfa(),
      "thicket": await FlutterTbaInfoNew.instance.isEmulator(),
      "daily": await FlutterTbaInfoNew.instance.isDeveloper(),
      "unexposed": await FlutterTbaInfoNew.instance.isAdb(),
      "density": await FlutterTbaInfoNew.instance.hasSim(),
      "senate": await FlutterTbaInfoNew.instance.isFirebaseTestLab(),
    };
  }
}
