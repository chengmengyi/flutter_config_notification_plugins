import 'package:flutter/foundation.dart';

import 'flutter_config_notification_plugins_platform_interface.dart';
import 'flutter_config_notification_plugins_method_channel.dart';
import 'src/android_notification_details.dart';
import 'src/local_notification_models.dart';
import 'src/notification_remote_models.dart';

export 'src/android_notification_details.dart';
export 'src/local_notification_models.dart';
export 'src/notification_remote_models.dart';

class FlutterConfigNotificationPlugins {
  static const Duration _defaultWorkManagerInterval = Duration(minutes: 60);

  static final FlutterConfigNotificationPlugins instance =
      FlutterConfigNotificationPlugins();

  /// 注册通知展示、通知点击和悬浮层点击回调。
  void setListeners({
    void Function(LocalNotificationEvent event)? onNotificationDisplayed,
    void Function(LocalNotificationEvent event)? onNotificationClicked,
    void Function()? onProcessingOverlayClicked,
    void Function(TimerOverlayClickEvent event)? onTimerOverlayClicked,
  }) {
    final platform = FlutterConfigNotificationPluginsPlatform.instance;
    if (platform is MethodChannelFlutterConfigNotificationPlugins) {
      if (onNotificationDisplayed != null) {
        platform.onNotificationDisplayed = onNotificationDisplayed;
      }
      if (onNotificationClicked != null) {
        platform.onNotificationClicked = onNotificationClicked;
      }
      if (onProcessingOverlayClicked != null) {
        platform.onProcessingOverlayClicked = onProcessingOverlayClicked;
        platform.setProcessingOverlayClickListenerReady();
      }
      if (onTimerOverlayClicked != null) {
        platform.onTimerOverlayClicked = onTimerOverlayClicked;
      }
    }
  }

  /// 获取当前平台版本信息。
  Future<String?> getPlatformVersion() {
    return FlutterConfigNotificationPluginsPlatform.instance
        .getPlatformVersion();
  }

  /// 加密反射字符串。
  ///
  /// 传入 [secret] 和待加密的 [value]，返回可直接填入各类 ReflectionConfig
  /// 对应字段的密文。Android 原生层使用反射时会用同一个 [secret] 解密。
  Future<String> encryptReflectionString({
    required String secret,
    required String value,
  }) {
    return FlutterConfigNotificationPluginsPlatform.instance
        .encryptReflectionString(secret: secret, value: value);
  }

  /// 解密反射字符串。
  ///
  /// 传入加密时使用的 [secret] 和 [encryptReflectionString] 返回的 [value]，
  /// 返回原始明文。非加密格式的 [value] 会原样返回。
  Future<String> decryptReflectionString({
    required String secret,
    required String value,
  }) {
    return FlutterConfigNotificationPluginsPlatform.instance
        .decryptReflectionString(secret: secret, value: value);
  }

  /// 按 payload 取出并清空已展示通知数量。
  Future<int> consumeDisplayedNotificationCount({
    required LocalNotificationPayload payload,
  }) {
    return FlutterConfigNotificationPluginsPlatform.instance
        .consumeDisplayedNotificationCount(payload: payload.value);
  }

  /// 配置通知展示后的 Android 原生埋点上报。
  Future<void> configureNativePushReporting({
    required bool enabled,
    required String url,
    required Map<String, String> headers,
    required Map<String, Object?> payloadTemplate,
    required String distinctIdKey,
    required String logIdKey,
    required String clientTsKey,
    required String notificationSourceKey,
    required String packageKey,
  }) {
    return FlutterConfigNotificationPluginsPlatform.instance
        .configureNativePushReporting(
          enabled: enabled,
          url: url,
          headers: headers,
          payloadTemplate: payloadTemplate,
          distinctIdKey: distinctIdKey,
          logIdKey: logIdKey,
          clientTsKey: clientTsKey,
          notificationSourceKey: notificationSourceKey,
          packageKey: packageKey,
        );
  }

  /// 启动 Android 原生后台 Session 上报。
  ///
  /// 进入后台、后台持续满一小时以及保活拉起时均由原生层直接上报，
  /// 不回传 Flutter。设置 [enabled] 为 false 可关闭并清除后台 Session。
  Future<void> startSessionBackground({
    required bool enabled,
    required String url,
    required Map<String, String> headers,
    required Map<String, Object?> payloadTemplate,
    required String distinctIdKey,
    required String logIdKey,
    required String clientTsKey,
    required String packageKey,
  }) {
    return FlutterConfigNotificationPluginsPlatform.instance
        .startSessionBackground(
          enabled: enabled,
          url: url,
          headers: headers,
          payloadTemplate: payloadTemplate,
          distinctIdKey: distinctIdKey,
          logIdKey: logIdKey,
          clientTsKey: clientTsKey,
          packageKey: packageKey,
        );
  }

  /// 检查悬浮层权限是否已开启。
  Future<bool> checkOverlayPermission() {
    return FlutterConfigNotificationPluginsPlatform.instance
        .checkOverlayPermission();
  }

  /// 请求系统悬浮层权限。
  Future<bool> requestOverlayPermission({
    required String title,
    required String desc,
    required String overlayPermissionGuideLayout,
  }) {
    return FlutterConfigNotificationPluginsPlatform.instance
        .requestOverlayPermission(
          title: title,
          desc: desc,
          overlayPermissionGuideLayout: overlayPermissionGuideLayout,
        );
  }

  /// 显示处理中的悬浮进度层。
  ///
  /// [reflectionConfig] 中除 [ProcessingOverlayReflectionConfig.secret] 外，
  /// 其他字段都建议先通过 [encryptReflectionString] 加密后再传入。
  ///
  /// 参数和值的对应关系如下：
  ///
  /// - secret: 加密和 Android 原生层解密使用的密钥，原文传入，不需要加密。
  /// - settingsClass: android.provider.Settings
  /// - canDrawOverlaysMethod: canDrawOverlays
  /// - contextGetSystemServiceMethod: getSystemService
  /// - windowServiceName: window
  /// - windowManagerLayoutParamsClass: android.view.WindowManager$LayoutParams
  /// - viewGroupLayoutParamsClass: android.view.ViewGroup$LayoutParams
  /// - windowManagerClass: android.view.WindowManager
  /// - addViewMethod: addView
  /// - removeViewMethod: removeView
  /// - updateViewLayoutMethod: updateViewLayout
  /// - gravityField: gravity
  /// - xField: x
  /// - yField: y
  Future<void> showProcessingOverlay({
    required String taskId,
    required String title,
    required double progress,
    required ProcessingOverlayReflectionConfig reflectionConfig,
  }) {
    return FlutterConfigNotificationPluginsPlatform.instance
        .showProcessingOverlay(
          taskId: taskId,
          title: title,
          progress: progress,
          reflectionConfig: reflectionConfig,
        );
  }

  /// 更新处理中的悬浮进度层。
  Future<void> updateProcessingOverlay({
    required String taskId,
    required String title,
    required double progress,
  }) {
    return FlutterConfigNotificationPluginsPlatform.instance
        .updateProcessingOverlay(
          taskId: taskId,
          title: title,
          progress: progress,
        );
  }

  /// 关闭处理中的悬浮进度层。
  Future<void> closeProcessingOverlay() {
    return FlutterConfigNotificationPluginsPlatform.instance
        .closeProcessingOverlay();
  }

  /// 关闭当前显示的定时悬浮窗；保留配置和下一次定时任务。
  Future<void> closeTimerOverlay() {
    return FlutterConfigNotificationPluginsPlatform.instance
        .closeTimerOverlay();
  }

  /// 测试专用：暂停保活恢复任务并主动停止保活前台服务。
  ///
  /// Android 日志出现 `READY_TO_SEND_FCM` 后立即发送高优先级 DATA FCM；
  /// 服务确实由 FCM 提升为前台后会输出 `FCM_FOREGROUND_SERVICE_STARTED`。
  Future<void> stopKeepAliveForegroundServiceForFcmTest() {
    if (!kDebugMode) {
      return Future<void>.value();
    }
    return FlutterConfigNotificationPluginsPlatform.instance
        .stopKeepAliveForegroundServiceForFcmTest();
  }

  /// 设置悬浮窗布局与反射信息；展示间隔、文案和误触比例读取远端配置。
  ///
  /// [reflectionConfig] 里的字符串建议都通过 [encryptReflectionString] 生成密文后传入，
  /// 并且 [TimerOverlayReflectionConfig.secret] 要和加密时使用的 secret 一致。
  ///
  /// 需要加密的明文和参数对应关系：
  /// - settingsClass: android.provider.Settings
  /// - canDrawOverlaysMethod: canDrawOverlays
  /// - contextGetSystemServiceMethod: getSystemService
  /// - windowServiceName: window
  /// - windowManagerLayoutParamsClass: android.view.WindowManager$LayoutParams
  /// - viewGroupLayoutParamsClass: android.view.ViewGroup$LayoutParams
  /// - windowManagerClass: android.view.WindowManager
  /// - addViewMethod: addView
  /// - removeViewMethod: removeView
  /// - gravityField: gravity
  /// - xField: x
  /// - yField: y
  Future<void> setTimerOverlayInfo({
    required String layoutName,
    String? layoutName2,
    List<TimerOverlayContent>? contentList3,
    required String continueReadingStr,
    required TimerOverlayReflectionConfig reflectionConfig,
  }) {
    return FlutterConfigNotificationPluginsPlatform.instance
        .setTimerOverlayInfo(
          layoutName: layoutName,
          layoutName2: layoutName2,
          contentList3: contentList3?.map((value) => value.toMap()).toList(),
          continueReadingStr: continueReadingStr,
          reflectionConfig: reflectionConfig.toMap(),
        );
  }

  /// 更新是否在通知触发前显示媒体通知。
  Future<void> updateShowMediaTag({required bool showMedia}) {
    return FlutterConfigNotificationPluginsPlatform.instance.updateShowMediaTag(
      showMedia: showMedia,
    );
  }

  /// 暂停定时悬浮窗；保留配置但取消下一次定时展示。
  Future<void> pauseTimerOverlay() {
    return FlutterConfigNotificationPluginsPlatform.instance
        .pauseTimerOverlay();
  }

  /// 恢复已配置的定时悬浮窗。
  Future<void> resumeTimerOverlay() {
    return FlutterConfigNotificationPluginsPlatform.instance
        .resumeTimerOverlay();
  }

  /// 记录定时悬浮窗可使用的最近 PDF 阅读位置。
  Future<void> setTimerOverlayLastPdfInfo({
    required String title,
    required int pageNumber,
  }) {
    return FlutterConfigNotificationPluginsPlatform.instance
        .setTimerOverlayLastPdfInfo(title: title, pageNumber: pageNumber);
  }

  /// 配置系统相册新增图片/截图时展示的本地通知文案。
  Future<void> setGalleryImageNotificationInfo({required String title}) {
    return FlutterConfigNotificationPluginsPlatform.instance
        .setGalleryImageNotificationInfo(title: title);
  }

  /// 取出并清空定时悬浮窗点击事件，用于冷启动/后台恢复后的打点兜底。
  Future<TimerOverlayClickEvent?> consumeTimerOverlayClickEvent() async {
    final result = await FlutterConfigNotificationPluginsPlatform.instance
        .consumeTimerOverlayClickEvent();
    if (result == null || result.isEmpty) {
      return null;
    }
    return TimerOverlayClickEvent.fromMap(result);
  }

  /// 判断悬浮进度层是否仍在显示。
  Future<bool> isProcessingOverlayActive() {
    return FlutterConfigNotificationPluginsPlatform.instance
        .isProcessingOverlayActive();
  }

  /// 取出并清空通过悬浮层拉起应用时的任务 ID。
  Future<String?> consumeProcessingOverlayLaunchTaskId() {
    return FlutterConfigNotificationPluginsPlatform.instance
        .consumeProcessingOverlayLaunchTaskId();
  }

  /// 将应用切到后台。
  Future<bool> moveAppToBack() {
    return FlutterConfigNotificationPluginsPlatform.instance.moveAppToBack();
  }

  /// 判断当前手机是否为三星。
  Future<bool> isSamsungDevice() {
    return FlutterConfigNotificationPluginsPlatform.instance.isSamsungDevice();
  }

  /// 判断当前手机语言或地区是否为韩国。
  Future<bool> isKoreanLocale() {
    return FlutterConfigNotificationPluginsPlatform.instance.isKoreanLocale();
  }

  /// 配置 Android 的 WorkManager 循环间隔。
  Future<void> configureAndroidWorkManager({
    Duration interval = _defaultWorkManagerInterval,
  }) {
    return FlutterConfigNotificationPluginsPlatform.instance
        .configureAndroidWorkManager(interval: interval);
  }

  /// 获取通知点击拉起应用的启动信息。
  Future<LocalNotificationAppLaunchDetails>
  getNotificationAppLaunchDetails() async {
    final result = await FlutterConfigNotificationPluginsPlatform.instance
        .getNotificationAppLaunchDetails();
    return LocalNotificationAppLaunchDetails.fromMap(result);
  }

  /// 订阅 FCM 主题并保存通知样式配置。
  Future<bool> subscribeToTopic({
    required String topic,
    required String beautyImage,
    String channelId = 'focus_channel_fcm',
    String channelName = 'focus_channel_name_fcm',
    String? channelDescription,
    Priority priority = Priority.high,
    Importance importance = Importance.high,
    String? style,
    String? beautyTitle,
    String? beautyBody,
    String? beautyButton,
    String? beautyAppIcon,
  }) {
    return FlutterConfigNotificationPluginsPlatform.instance.subscribeToTopic(
      topic: topic,
      channelId: channelId,
      channelName: channelName,
      channelDescription: channelDescription,
      priority: priority.index,
      importance: importance.index,
      style: style,
      beautyTitle: beautyTitle,
      beautyBody: beautyBody,
      beautyImage: beautyImage,
      beautyButton: beautyButton,
      beautyAppIcon: beautyAppIcon,
    );
  }

  /// 从远端拉取并保存通知配置，成功后才初始化通知功能。
  ///
  /// Android 仅在请求、解码、校验、持久化全部成功、远端 enabled 为 true，
  /// 且通知初始化成功时返回 true。
  /// 请求或解析失败返回 false，调用方不应继续初始化周期通知等后续功能。
  /// iOS 暂不支持远端配置，返回 false。
  Future<bool> initNotification({
    required NotificationRemoteRequest remoteRequest,
    String channelId = 'default_notification_channel',
    String channelName = 'Notifications',
    String? channelDescription,
    String? icon,
    bool showMedia = true,
    AndroidCustomNotificationLayout? customLayout,
  }) {
    return FlutterConfigNotificationPluginsPlatform.instance.initNotification(
      channelId: channelId,
      channelName: channelName,
      channelDescription: channelDescription,
      icon: icon,
      showMedia: showMedia,
      remoteRequest: remoteRequest.toMap(),
      customLayout: customLayout?.toMap(),
    );
  }

  /// 显示常驻快捷入口通知。
  Future<void> showPersistentShortcutNotification({
    required String homeText,
    required String mergeText,
    required String importText,
    required String convertText,
    String homeIcon = 'home',
    String mergeIcon = 'merge',
    String importIcon = 'shortcut_import',
    String convertIcon = 'convert',
    AndroidPersistentShortcutLayout? customLayout,
  }) {
    return FlutterConfigNotificationPluginsPlatform.instance
        .showPersistentShortcutNotification(
          homeText: homeText,
          mergeText: mergeText,
          importText: importText,
          convertText: convertText,
          homeIcon: homeIcon,
          mergeIcon: mergeIcon,
          importIcon: importIcon,
          convertIcon: convertIcon,
          customLayout: customLayout?.toMap(),
        );
  }

  /// 立即显示一条本地通知。
  ///
  /// Android 上仅当 [showOverlay] 为 true 时，才会尝试显示定时悬浮窗。
  /// [showWhenAppForeground] 为 true 时允许在 App 前台展示，默认 false。
  Future<void> show({
    required int id,
    String? title,
    String? body,
    LocalNotificationPayload? payload,
    String? clickPayload,
    String? mediaBackgroundImageName,
    AndroidNotificationDetails? notificationDetails,
    bool showOverlay = false,
    bool showWhenAppForeground = false,
  }) {
    return FlutterConfigNotificationPluginsPlatform.instance.show(
      id: id,
      title: title,
      body: body,
      payload: payload?.value,
      clickPayload: clickPayload,
      mediaBackgroundImageName: mediaBackgroundImageName,
      notificationDetails: notificationDetails?.toMap(),
      showOverlay: showOverlay,
      showWhenAppForeground: showWhenAppForeground,
    );
  }

  /// 按固定时间间隔循环展示本地通知。
  Future<void> periodicallyShowLocalWithDuration() {
    return FlutterConfigNotificationPluginsPlatform.instance
        .periodicallyShowLocalWithDuration();
  }

  /// 按固定时间间隔循环展示媒体通知。
  ///
  /// [reflectionConfig] 里的字符串建议都通过 [encryptReflectionString] 生成密文后传入，
  /// 并且 [MediaReflectionConfig.secret] 要和加密时使用的 secret 一致。
  ///
  /// 需要加密的明文和参数对应关系：
  /// - mediaSessionClass: android.support.v4.media.session.MediaSessionCompat
  /// - mediaSessionTokenClass: android.support.v4.media.session.MediaSessionCompat$Token
  /// - mediaSessionTag: FLNMediaSession
  /// - playbackStateClass: android.support.v4.media.session.PlaybackStateCompat
  /// - playbackStateBuilderClass: android.support.v4.media.session.PlaybackStateCompat$Builder
  /// - mediaStyleClass: androidx.media.app.NotificationCompat$MediaStyle
  /// - setFlagsMethod: setFlags
  /// - setActiveMethod: setActive
  /// - setPlaybackStateMethod: setPlaybackState
  /// - getSessionTokenMethod: getSessionToken
  /// - setStateMethod: setState
  /// - buildMethod: build
  /// - setMediaSessionMethod: setMediaSession
  Future<void> periodicallyShowMediaWithDuration({
    required String image,
    required MediaReflectionConfig reflectionConfig,
  }) {
    return FlutterConfigNotificationPluginsPlatform.instance
        .periodicallyShowMediaWithDuration(
          image: image,
          reflectionConfig: reflectionConfig.toMap(),
        );
  }

  /// 注册广播触发的通知提醒。
  Future<void> registerBroadcastNotifications() {
    return FlutterConfigNotificationPluginsPlatform.instance
        .registerBroadcastNotifications();
  }

  /// 广告点击后尝试按远端广播配置展示通知。
  Future<bool> clickAdShowNotification() {
    return FlutterConfigNotificationPluginsPlatform.instance
        .clickAdShowNotification();
  }
}
