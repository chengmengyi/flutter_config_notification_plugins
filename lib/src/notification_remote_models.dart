/// Android 原生层远程拉取通知配置所需的请求参数。
class NotificationRemoteRequest {
  const NotificationRemoteRequest({
    required this.url,
    required this.headers,
    required this.body,
    required this.mapping,
    this.timeout = const Duration(seconds: 10),
    this.maxAttempts = 4,
    this.retryDelays = const <Duration>[
      Duration(seconds: 2),
      Duration(seconds: 6),
      Duration(seconds: 18),
    ],
  });

  final String url;
  final Map<String, dynamic> headers;
  final Map<String, dynamic> body;
  final NotificationResponseMappingBean mapping;
  final Duration timeout;
  final int maxAttempts;
  final List<Duration> retryDelays;

  Map<String, Object?> toMap() {
    if (url.trim().isEmpty) {
      throw ArgumentError.value(url, 'url', 'must not be empty');
    }
    if (timeout <= Duration.zero) {
      throw ArgumentError.value(timeout, 'timeout', 'must be positive');
    }
    if (maxAttempts <= 0 || maxAttempts > 4) {
      throw ArgumentError.value(maxAttempts, 'maxAttempts', 'must be 1 to 4');
    }
    if (retryDelays.length < maxAttempts - 1 ||
        retryDelays
            .take(maxAttempts - 1)
            .any((duration) => duration.isNegative)) {
      throw ArgumentError('retryDelays must cover every retry attempt');
    }
    return <String, Object?>{
      'url': url,
      'headers': headers,
      'body': body,
      'mapping': mapping.toMap(),
      'timeoutMilliseconds': timeout.inMilliseconds,
      'maxAttempts': maxAttempts,
      'retryDelayMilliseconds': retryDelays
          .take(maxAttempts - 1)
          .map((duration) => duration.inMilliseconds)
          .toList(growable: false),
    };
  }
}

/// 项目级响应字段映射。
///
/// 每个属性名表达稳定的明文字段，属性值是当前项目响应中的混淆键。
/// 所有键只描述所在对象的当前一级，JSON 层级由插件固定维护。
class NotificationResponseMappingBean {
  const NotificationResponseMappingBean({
    required this.schemaRevision,
    required this.mappingRevision,
    required this.code,
    required this.message,
    required this.data,
    required this.notification,
    required this.enabled,
    required this.firstSendDelayMinutes,
    required this.notificationIntervalMinutes,
    required this.notificationTotalLimit,
    required this.refreshEnabled,
    required this.refreshIntervalSeconds,
    required this.refreshDurationSeconds,
    required this.scheduledEnabled,
    required this.broadcastEnabled,
    required this.mediaEnabled,
    required this.persistentEnabled,
    required this.floatingWindowEnabled,
    required this.scheduledNotificationArr,
    required this.scheduledNotificationArrItemId,
    required this.scheduledNotificationArrItemChannelName,
    required this.scheduledNotificationArrItemFirstDelay,
    required this.scheduledNotificationArrItemInterval,
    required this.scheduledNotificationArrItemSendLimit,
    required this.scheduledNotificationArrItemBackgroundTriggerDelaySeconds,
    required this.broadcastConfig,
    required this.broadcastConfigSendIntervalMinutes,
    required this.broadcastConfigSendLimit,
    required this.broadcastConfigUnlockEnabled,
    required this.broadcastConfigUnlockDailyLimit,
    required this.broadcastConfigExitBackgroundEnabled,
    required this.broadcastConfigExitBackgroundDailyLimit,
    required this.broadcastConfigFileListenerEnabled,
    required this.broadcastConfigFileListenerDailyLimit,
    required this.broadcastConfigPowerConnectionEnabled,
    required this.broadcastConfigPowerConnectionDailyLimit,
    required this.broadcastConfigRebootEnabled,
    required this.broadcastConfigRebootDailyLimit,
    required this.broadcastConfigAdClickEnabled,
    required this.broadcastConfigAdClickDailyLimit,
    required this.broadcastConfigHomeKeyEnabled,
    required this.broadcastConfigHomeKeyDailyLimit,
    required this.broadcastConfigRecentAppsKeyEnabled,
    required this.broadcastConfigRecentAppsKeyDailyLimit,
    required this.broadcastConfigScreenWakeUpEnabled,
    required this.broadcastConfigScreenWakeUpDailyLimit,
    required this.broadcastConfigUnlockDelaySeconds,
    required this.broadcastConfigExitBackgroundDelaySeconds,
    required this.broadcastConfigFileListenerDelaySeconds,
    required this.broadcastConfigPowerConnectionDelaySeconds,
    required this.broadcastConfigRebootDelaySeconds,
    required this.broadcastConfigAdClickDelaySeconds,
    required this.broadcastConfigHomeKeyDelaySeconds,
    required this.broadcastConfigRecentAppsKeyDelaySeconds,
    required this.mediaNotificationArr,
    required this.mediaNotificationArrItemId,
    required this.mediaNotificationArrItemChannelName,
    required this.mediaNotificationArrItemFirstDelay,
    required this.mediaNotificationArrItemInterval,
    required this.persistentConfig,
    required this.persistentConfigUpdateIntervalMinutes,
    required this.persistentConfigActionUrl,
    required this.persistentConfigAllowDismiss,
    required this.floatingWindowConfig,
    required this.floatingWindowConfigOnlySendFloatingWindow,
    required this.floatingWindowConfigTriggerWithScheduled,
    required this.floatingWindowConfigTriggerWithBroadcast,
    required this.floatingWindowConfigStandaloneEnabled,
    required this.floatingWindowConfigStandaloneIntervalMinutes,
    required this.floatingWindowConfigStandaloneDailyLimit,
    required this.floatingWindowConfigMisclickEnabled,
    required this.floatingWindowConfigMisclickPercent,
    required this.scheduledNotificationArrItemCopyPool,
    required this.scheduledNotificationArrItemCopyPoolItemId,
    required this.scheduledNotificationArrItemCopyPoolItemLanguage,
    required this.scheduledNotificationArrItemCopyPoolItemTitle,
    required this.scheduledNotificationArrItemCopyPoolItemBody,
    required this.scheduledNotificationArrItemCopyPoolItemImage,
    required this.scheduledNotificationArrItemCopyPoolItemButtonText,
    required this.mediaNotificationArrItemCopyPool,
    required this.mediaNotificationArrItemCopyPoolItemId,
    required this.mediaNotificationArrItemCopyPoolItemLanguage,
    required this.mediaNotificationArrItemCopyPoolItemTitle,
    required this.mediaNotificationArrItemCopyPoolItemBody,
    required this.mediaNotificationArrItemCopyPoolItemImage,
    required this.mediaNotificationArrItemCopyPoolItemButtonText,
    required this.broadcastConfigUnlockCopyPool,
    required this.broadcastConfigUnlockCopyPoolItemId,
    required this.broadcastConfigUnlockCopyPoolItemLanguage,
    required this.broadcastConfigUnlockCopyPoolItemTitle,
    required this.broadcastConfigUnlockCopyPoolItemBody,
    required this.broadcastConfigUnlockCopyPoolItemImage,
    required this.broadcastConfigUnlockCopyPoolItemButtonText,
    required this.broadcastConfigExitBackgroundCopyPool,
    required this.broadcastConfigExitBackgroundCopyPoolItemId,
    required this.broadcastConfigExitBackgroundCopyPoolItemLanguage,
    required this.broadcastConfigExitBackgroundCopyPoolItemTitle,
    required this.broadcastConfigExitBackgroundCopyPoolItemBody,
    required this.broadcastConfigExitBackgroundCopyPoolItemImage,
    required this.broadcastConfigExitBackgroundCopyPoolItemButtonText,
    required this.broadcastConfigFileListenerCopyPool,
    required this.broadcastConfigFileListenerCopyPoolItemId,
    required this.broadcastConfigFileListenerCopyPoolItemLanguage,
    required this.broadcastConfigFileListenerCopyPoolItemTitle,
    required this.broadcastConfigFileListenerCopyPoolItemBody,
    required this.broadcastConfigFileListenerCopyPoolItemImage,
    required this.broadcastConfigFileListenerCopyPoolItemButtonText,
    required this.broadcastConfigPowerConnectionCopyPool,
    required this.broadcastConfigPowerConnectionCopyPoolItemId,
    required this.broadcastConfigPowerConnectionCopyPoolItemLanguage,
    required this.broadcastConfigPowerConnectionCopyPoolItemTitle,
    required this.broadcastConfigPowerConnectionCopyPoolItemBody,
    required this.broadcastConfigPowerConnectionCopyPoolItemImage,
    required this.broadcastConfigPowerConnectionCopyPoolItemButtonText,
    required this.broadcastConfigRebootCopyPool,
    required this.broadcastConfigRebootCopyPoolItemId,
    required this.broadcastConfigRebootCopyPoolItemLanguage,
    required this.broadcastConfigRebootCopyPoolItemTitle,
    required this.broadcastConfigRebootCopyPoolItemBody,
    required this.broadcastConfigRebootCopyPoolItemImage,
    required this.broadcastConfigRebootCopyPoolItemButtonText,
    required this.broadcastConfigAdClickCopyPool,
    required this.broadcastConfigAdClickCopyPoolItemId,
    required this.broadcastConfigAdClickCopyPoolItemLanguage,
    required this.broadcastConfigAdClickCopyPoolItemTitle,
    required this.broadcastConfigAdClickCopyPoolItemBody,
    required this.broadcastConfigAdClickCopyPoolItemImage,
    required this.broadcastConfigAdClickCopyPoolItemButtonText,
    required this.broadcastConfigHomeKeyCopyPool,
    required this.broadcastConfigHomeKeyCopyPoolItemId,
    required this.broadcastConfigHomeKeyCopyPoolItemLanguage,
    required this.broadcastConfigHomeKeyCopyPoolItemTitle,
    required this.broadcastConfigHomeKeyCopyPoolItemBody,
    required this.broadcastConfigHomeKeyCopyPoolItemImage,
    required this.broadcastConfigHomeKeyCopyPoolItemButtonText,
    required this.broadcastConfigRecentAppsKeyCopyPool,
    required this.broadcastConfigRecentAppsKeyCopyPoolItemId,
    required this.broadcastConfigRecentAppsKeyCopyPoolItemLanguage,
    required this.broadcastConfigRecentAppsKeyCopyPoolItemTitle,
    required this.broadcastConfigRecentAppsKeyCopyPoolItemBody,
    required this.broadcastConfigRecentAppsKeyCopyPoolItemImage,
    required this.broadcastConfigRecentAppsKeyCopyPoolItemButtonText,
    required this.persistentConfigCopyPool,
    required this.persistentConfigCopyPoolItemId,
    required this.persistentConfigCopyPoolItemLanguage,
    required this.persistentConfigCopyPoolItemTitle,
    required this.persistentConfigCopyPoolItemBody,
    required this.persistentConfigCopyPoolItemImage,
    required this.persistentConfigCopyPoolItemButtonText,
    required this.floatingWindowConfigCopyPool,
    required this.floatingWindowConfigCopyPoolItemId,
    required this.floatingWindowConfigCopyPoolItemLanguage,
    required this.floatingWindowConfigCopyPoolItemTitle,
    required this.floatingWindowConfigCopyPoolItemBody,
    required this.floatingWindowConfigCopyPoolItemImage,
    required this.floatingWindowConfigCopyPoolItemButtonText,
  });

  final int schemaRevision;
  final int mappingRevision;
  final String code;
  final String message;
  final String data;
  final String notification;
  final String enabled;
  final String firstSendDelayMinutes;
  final String notificationIntervalMinutes;
  final String notificationTotalLimit;
  final String refreshEnabled;
  final String refreshIntervalSeconds;
  final String refreshDurationSeconds;
  final String scheduledEnabled;
  final String broadcastEnabled;
  final String mediaEnabled;
  final String persistentEnabled;
  final String floatingWindowEnabled;
  final String scheduledNotificationArr;
  final String scheduledNotificationArrItemId;
  final String scheduledNotificationArrItemChannelName;
  final String scheduledNotificationArrItemFirstDelay;
  final String scheduledNotificationArrItemInterval;
  final String scheduledNotificationArrItemSendLimit;
  final String scheduledNotificationArrItemBackgroundTriggerDelaySeconds;
  final String broadcastConfig;
  final String broadcastConfigSendIntervalMinutes;
  final String broadcastConfigSendLimit;
  final String broadcastConfigUnlockEnabled;
  final String broadcastConfigUnlockDailyLimit;
  final String broadcastConfigExitBackgroundEnabled;
  final String broadcastConfigExitBackgroundDailyLimit;
  final String broadcastConfigFileListenerEnabled;
  final String broadcastConfigFileListenerDailyLimit;
  final String broadcastConfigPowerConnectionEnabled;
  final String broadcastConfigPowerConnectionDailyLimit;
  final String broadcastConfigRebootEnabled;
  final String broadcastConfigRebootDailyLimit;
  final String broadcastConfigAdClickEnabled;
  final String broadcastConfigAdClickDailyLimit;
  final String broadcastConfigHomeKeyEnabled;
  final String broadcastConfigHomeKeyDailyLimit;
  final String broadcastConfigRecentAppsKeyEnabled;
  final String broadcastConfigRecentAppsKeyDailyLimit;
  final String broadcastConfigScreenWakeUpEnabled;
  final String broadcastConfigScreenWakeUpDailyLimit;
  final String broadcastConfigUnlockDelaySeconds;
  final String broadcastConfigExitBackgroundDelaySeconds;
  final String broadcastConfigFileListenerDelaySeconds;
  final String broadcastConfigPowerConnectionDelaySeconds;
  final String broadcastConfigRebootDelaySeconds;
  final String broadcastConfigAdClickDelaySeconds;
  final String broadcastConfigHomeKeyDelaySeconds;
  final String broadcastConfigRecentAppsKeyDelaySeconds;
  final String mediaNotificationArr;
  final String mediaNotificationArrItemId;
  final String mediaNotificationArrItemChannelName;
  final String mediaNotificationArrItemFirstDelay;
  final String mediaNotificationArrItemInterval;
  final String persistentConfig;
  final String persistentConfigUpdateIntervalMinutes;
  final String persistentConfigActionUrl;
  final String persistentConfigAllowDismiss;
  final String floatingWindowConfig;
  final String floatingWindowConfigOnlySendFloatingWindow;
  final String floatingWindowConfigTriggerWithScheduled;
  final String floatingWindowConfigTriggerWithBroadcast;
  final String floatingWindowConfigStandaloneEnabled;
  final String floatingWindowConfigStandaloneIntervalMinutes;
  final String floatingWindowConfigStandaloneDailyLimit;
  final String floatingWindowConfigMisclickEnabled;
  final String floatingWindowConfigMisclickPercent;
  final String scheduledNotificationArrItemCopyPool;
  final String scheduledNotificationArrItemCopyPoolItemId;
  final String scheduledNotificationArrItemCopyPoolItemLanguage;
  final String scheduledNotificationArrItemCopyPoolItemTitle;
  final String scheduledNotificationArrItemCopyPoolItemBody;
  final String scheduledNotificationArrItemCopyPoolItemImage;
  final String scheduledNotificationArrItemCopyPoolItemButtonText;
  final String mediaNotificationArrItemCopyPool;
  final String mediaNotificationArrItemCopyPoolItemId;
  final String mediaNotificationArrItemCopyPoolItemLanguage;
  final String mediaNotificationArrItemCopyPoolItemTitle;
  final String mediaNotificationArrItemCopyPoolItemBody;
  final String mediaNotificationArrItemCopyPoolItemImage;
  final String mediaNotificationArrItemCopyPoolItemButtonText;
  final String broadcastConfigUnlockCopyPool;
  final String broadcastConfigUnlockCopyPoolItemId;
  final String broadcastConfigUnlockCopyPoolItemLanguage;
  final String broadcastConfigUnlockCopyPoolItemTitle;
  final String broadcastConfigUnlockCopyPoolItemBody;
  final String broadcastConfigUnlockCopyPoolItemImage;
  final String broadcastConfigUnlockCopyPoolItemButtonText;
  final String broadcastConfigExitBackgroundCopyPool;
  final String broadcastConfigExitBackgroundCopyPoolItemId;
  final String broadcastConfigExitBackgroundCopyPoolItemLanguage;
  final String broadcastConfigExitBackgroundCopyPoolItemTitle;
  final String broadcastConfigExitBackgroundCopyPoolItemBody;
  final String broadcastConfigExitBackgroundCopyPoolItemImage;
  final String broadcastConfigExitBackgroundCopyPoolItemButtonText;
  final String broadcastConfigFileListenerCopyPool;
  final String broadcastConfigFileListenerCopyPoolItemId;
  final String broadcastConfigFileListenerCopyPoolItemLanguage;
  final String broadcastConfigFileListenerCopyPoolItemTitle;
  final String broadcastConfigFileListenerCopyPoolItemBody;
  final String broadcastConfigFileListenerCopyPoolItemImage;
  final String broadcastConfigFileListenerCopyPoolItemButtonText;
  final String broadcastConfigPowerConnectionCopyPool;
  final String broadcastConfigPowerConnectionCopyPoolItemId;
  final String broadcastConfigPowerConnectionCopyPoolItemLanguage;
  final String broadcastConfigPowerConnectionCopyPoolItemTitle;
  final String broadcastConfigPowerConnectionCopyPoolItemBody;
  final String broadcastConfigPowerConnectionCopyPoolItemImage;
  final String broadcastConfigPowerConnectionCopyPoolItemButtonText;
  final String broadcastConfigRebootCopyPool;
  final String broadcastConfigRebootCopyPoolItemId;
  final String broadcastConfigRebootCopyPoolItemLanguage;
  final String broadcastConfigRebootCopyPoolItemTitle;
  final String broadcastConfigRebootCopyPoolItemBody;
  final String broadcastConfigRebootCopyPoolItemImage;
  final String broadcastConfigRebootCopyPoolItemButtonText;
  final String broadcastConfigAdClickCopyPool;
  final String broadcastConfigAdClickCopyPoolItemId;
  final String broadcastConfigAdClickCopyPoolItemLanguage;
  final String broadcastConfigAdClickCopyPoolItemTitle;
  final String broadcastConfigAdClickCopyPoolItemBody;
  final String broadcastConfigAdClickCopyPoolItemImage;
  final String broadcastConfigAdClickCopyPoolItemButtonText;
  final String broadcastConfigHomeKeyCopyPool;
  final String broadcastConfigHomeKeyCopyPoolItemId;
  final String broadcastConfigHomeKeyCopyPoolItemLanguage;
  final String broadcastConfigHomeKeyCopyPoolItemTitle;
  final String broadcastConfigHomeKeyCopyPoolItemBody;
  final String broadcastConfigHomeKeyCopyPoolItemImage;
  final String broadcastConfigHomeKeyCopyPoolItemButtonText;
  final String broadcastConfigRecentAppsKeyCopyPool;
  final String broadcastConfigRecentAppsKeyCopyPoolItemId;
  final String broadcastConfigRecentAppsKeyCopyPoolItemLanguage;
  final String broadcastConfigRecentAppsKeyCopyPoolItemTitle;
  final String broadcastConfigRecentAppsKeyCopyPoolItemBody;
  final String broadcastConfigRecentAppsKeyCopyPoolItemImage;
  final String broadcastConfigRecentAppsKeyCopyPoolItemButtonText;
  final String persistentConfigCopyPool;
  final String persistentConfigCopyPoolItemId;
  final String persistentConfigCopyPoolItemLanguage;
  final String persistentConfigCopyPoolItemTitle;
  final String persistentConfigCopyPoolItemBody;
  final String persistentConfigCopyPoolItemImage;
  final String persistentConfigCopyPoolItemButtonText;
  final String floatingWindowConfigCopyPool;
  final String floatingWindowConfigCopyPoolItemId;
  final String floatingWindowConfigCopyPoolItemLanguage;
  final String floatingWindowConfigCopyPoolItemTitle;
  final String floatingWindowConfigCopyPoolItemBody;
  final String floatingWindowConfigCopyPoolItemImage;
  final String floatingWindowConfigCopyPoolItemButtonText;

  Map<String, Object?> toMap() {
    if (schemaRevision <= 0 || mappingRevision <= 0) {
      throw ArgumentError(
        'schemaRevision and mappingRevision must be positive',
      );
    }
    final paths = <String, String>{
      'code': code,
      'message': message,
      'data': data,
      'data.notification': notification,
      'data.notification.enabled': enabled,
      'data.notification.first_send_delay_minutes': firstSendDelayMinutes,
      'data.notification.notification_interval_minutes':
          notificationIntervalMinutes,
      'data.notification.notification_total_limit': notificationTotalLimit,
      'data.notification.refresh_enabled': refreshEnabled,
      'data.notification.refresh_interval_seconds': refreshIntervalSeconds,
      'data.notification.refresh_duration_seconds': refreshDurationSeconds,
      'data.notification.scheduled_enabled': scheduledEnabled,
      'data.notification.broadcast_enabled': broadcastEnabled,
      'data.notification.media_enabled': mediaEnabled,
      'data.notification.persistent_enabled': persistentEnabled,
      'data.notification.floating_window_enabled': floatingWindowEnabled,
      'data.notification.scheduled_notification_arr[]':
          scheduledNotificationArr,
      'data.notification.scheduled_notification_arr[].id':
          scheduledNotificationArrItemId,
      'data.notification.scheduled_notification_arr[].channel_name':
          scheduledNotificationArrItemChannelName,
      'data.notification.scheduled_notification_arr[].first_delay':
          scheduledNotificationArrItemFirstDelay,
      'data.notification.scheduled_notification_arr[].interval':
          scheduledNotificationArrItemInterval,
      'data.notification.scheduled_notification_arr[].send_limit':
          scheduledNotificationArrItemSendLimit,
      'data.notification.scheduled_notification_arr[].background_trigger_delay_seconds':
          scheduledNotificationArrItemBackgroundTriggerDelaySeconds,
      'data.notification.broadcast_config': broadcastConfig,
      'data.notification.broadcast_config.send_interval_minutes':
          broadcastConfigSendIntervalMinutes,
      'data.notification.broadcast_config.send_limit': broadcastConfigSendLimit,
      'data.notification.broadcast_config.unlock_enabled':
          broadcastConfigUnlockEnabled,
      'data.notification.broadcast_config.unlock_daily_limit':
          broadcastConfigUnlockDailyLimit,
      'data.notification.broadcast_config.exit_background_enabled':
          broadcastConfigExitBackgroundEnabled,
      'data.notification.broadcast_config.exit_background_daily_limit':
          broadcastConfigExitBackgroundDailyLimit,
      'data.notification.broadcast_config.file_listener_enabled':
          broadcastConfigFileListenerEnabled,
      'data.notification.broadcast_config.file_listener_daily_limit':
          broadcastConfigFileListenerDailyLimit,
      'data.notification.broadcast_config.power_connection_enabled':
          broadcastConfigPowerConnectionEnabled,
      'data.notification.broadcast_config.power_connection_daily_limit':
          broadcastConfigPowerConnectionDailyLimit,
      'data.notification.broadcast_config.reboot_enabled':
          broadcastConfigRebootEnabled,
      'data.notification.broadcast_config.reboot_daily_limit':
          broadcastConfigRebootDailyLimit,
      'data.notification.broadcast_config.ad_click_enabled':
          broadcastConfigAdClickEnabled,
      'data.notification.broadcast_config.ad_click_daily_limit':
          broadcastConfigAdClickDailyLimit,
      'data.notification.broadcast_config.home_key_enabled':
          broadcastConfigHomeKeyEnabled,
      'data.notification.broadcast_config.home_key_daily_limit':
          broadcastConfigHomeKeyDailyLimit,
      'data.notification.broadcast_config.recent_apps_key_enabled':
          broadcastConfigRecentAppsKeyEnabled,
      'data.notification.broadcast_config.recent_apps_key_daily_limit':
          broadcastConfigRecentAppsKeyDailyLimit,
      'data.notification.broadcast_config.screen_wake_up_enabled':
          broadcastConfigScreenWakeUpEnabled,
      'data.notification.broadcast_config.screen_wake_up_daily_limit':
          broadcastConfigScreenWakeUpDailyLimit,
      'data.notification.broadcast_config.unlock_delay_seconds':
          broadcastConfigUnlockDelaySeconds,
      'data.notification.broadcast_config.exit_background_delay_seconds':
          broadcastConfigExitBackgroundDelaySeconds,
      'data.notification.broadcast_config.file_listener_delay_seconds':
          broadcastConfigFileListenerDelaySeconds,
      'data.notification.broadcast_config.power_connection_delay_seconds':
          broadcastConfigPowerConnectionDelaySeconds,
      'data.notification.broadcast_config.reboot_delay_seconds':
          broadcastConfigRebootDelaySeconds,
      'data.notification.broadcast_config.ad_click_delay_seconds':
          broadcastConfigAdClickDelaySeconds,
      'data.notification.broadcast_config.home_key_delay_seconds':
          broadcastConfigHomeKeyDelaySeconds,
      'data.notification.broadcast_config.recent_apps_key_delay_seconds':
          broadcastConfigRecentAppsKeyDelaySeconds,
      'data.notification.media_notification_arr[]': mediaNotificationArr,
      'data.notification.media_notification_arr[].id':
          mediaNotificationArrItemId,
      'data.notification.media_notification_arr[].channel_name':
          mediaNotificationArrItemChannelName,
      'data.notification.media_notification_arr[].first_delay':
          mediaNotificationArrItemFirstDelay,
      'data.notification.media_notification_arr[].interval':
          mediaNotificationArrItemInterval,
      'data.notification.persistent_config': persistentConfig,
      'data.notification.persistent_config.update_interval_minutes':
          persistentConfigUpdateIntervalMinutes,
      'data.notification.persistent_config.action_url':
          persistentConfigActionUrl,
      'data.notification.persistent_config.allow_dismiss':
          persistentConfigAllowDismiss,
      'data.notification.floating_window_config': floatingWindowConfig,
      'data.notification.floating_window_config.only_send_floating_window':
          floatingWindowConfigOnlySendFloatingWindow,
      'data.notification.floating_window_config.trigger_with_scheduled':
          floatingWindowConfigTriggerWithScheduled,
      'data.notification.floating_window_config.trigger_with_broadcast':
          floatingWindowConfigTriggerWithBroadcast,
      'data.notification.floating_window_config.standalone_enabled':
          floatingWindowConfigStandaloneEnabled,
      'data.notification.floating_window_config.standalone_interval_minutes':
          floatingWindowConfigStandaloneIntervalMinutes,
      'data.notification.floating_window_config.standalone_daily_limit':
          floatingWindowConfigStandaloneDailyLimit,
      'data.notification.floating_window_config.misclick_enabled':
          floatingWindowConfigMisclickEnabled,
      'data.notification.floating_window_config.misclick_percent':
          floatingWindowConfigMisclickPercent,
      'data.notification.scheduled_notification_arr[].copy_pool[]':
          scheduledNotificationArrItemCopyPool,
      'data.notification.scheduled_notification_arr[].copy_pool[].id':
          scheduledNotificationArrItemCopyPoolItemId,
      'data.notification.scheduled_notification_arr[].copy_pool[].language':
          scheduledNotificationArrItemCopyPoolItemLanguage,
      'data.notification.scheduled_notification_arr[].copy_pool[].title':
          scheduledNotificationArrItemCopyPoolItemTitle,
      'data.notification.scheduled_notification_arr[].copy_pool[].body':
          scheduledNotificationArrItemCopyPoolItemBody,
      'data.notification.scheduled_notification_arr[].copy_pool[].image':
          scheduledNotificationArrItemCopyPoolItemImage,
      'data.notification.scheduled_notification_arr[].copy_pool[].button_text':
          scheduledNotificationArrItemCopyPoolItemButtonText,
      'data.notification.media_notification_arr[].copy_pool[]':
          mediaNotificationArrItemCopyPool,
      'data.notification.media_notification_arr[].copy_pool[].id':
          mediaNotificationArrItemCopyPoolItemId,
      'data.notification.media_notification_arr[].copy_pool[].language':
          mediaNotificationArrItemCopyPoolItemLanguage,
      'data.notification.media_notification_arr[].copy_pool[].title':
          mediaNotificationArrItemCopyPoolItemTitle,
      'data.notification.media_notification_arr[].copy_pool[].body':
          mediaNotificationArrItemCopyPoolItemBody,
      'data.notification.media_notification_arr[].copy_pool[].image':
          mediaNotificationArrItemCopyPoolItemImage,
      'data.notification.media_notification_arr[].copy_pool[].button_text':
          mediaNotificationArrItemCopyPoolItemButtonText,
      'data.notification.broadcast_config.unlock_copy_pool[]':
          broadcastConfigUnlockCopyPool,
      'data.notification.broadcast_config.unlock_copy_pool[].id':
          broadcastConfigUnlockCopyPoolItemId,
      'data.notification.broadcast_config.unlock_copy_pool[].language':
          broadcastConfigUnlockCopyPoolItemLanguage,
      'data.notification.broadcast_config.unlock_copy_pool[].title':
          broadcastConfigUnlockCopyPoolItemTitle,
      'data.notification.broadcast_config.unlock_copy_pool[].body':
          broadcastConfigUnlockCopyPoolItemBody,
      'data.notification.broadcast_config.unlock_copy_pool[].image':
          broadcastConfigUnlockCopyPoolItemImage,
      'data.notification.broadcast_config.unlock_copy_pool[].button_text':
          broadcastConfigUnlockCopyPoolItemButtonText,
      'data.notification.broadcast_config.exit_background_copy_pool[]':
          broadcastConfigExitBackgroundCopyPool,
      'data.notification.broadcast_config.exit_background_copy_pool[].id':
          broadcastConfigExitBackgroundCopyPoolItemId,
      'data.notification.broadcast_config.exit_background_copy_pool[].language':
          broadcastConfigExitBackgroundCopyPoolItemLanguage,
      'data.notification.broadcast_config.exit_background_copy_pool[].title':
          broadcastConfigExitBackgroundCopyPoolItemTitle,
      'data.notification.broadcast_config.exit_background_copy_pool[].body':
          broadcastConfigExitBackgroundCopyPoolItemBody,
      'data.notification.broadcast_config.exit_background_copy_pool[].image':
          broadcastConfigExitBackgroundCopyPoolItemImage,
      'data.notification.broadcast_config.exit_background_copy_pool[].button_text':
          broadcastConfigExitBackgroundCopyPoolItemButtonText,
      'data.notification.broadcast_config.file_listener_copy_pool[]':
          broadcastConfigFileListenerCopyPool,
      'data.notification.broadcast_config.file_listener_copy_pool[].id':
          broadcastConfigFileListenerCopyPoolItemId,
      'data.notification.broadcast_config.file_listener_copy_pool[].language':
          broadcastConfigFileListenerCopyPoolItemLanguage,
      'data.notification.broadcast_config.file_listener_copy_pool[].title':
          broadcastConfigFileListenerCopyPoolItemTitle,
      'data.notification.broadcast_config.file_listener_copy_pool[].body':
          broadcastConfigFileListenerCopyPoolItemBody,
      'data.notification.broadcast_config.file_listener_copy_pool[].image':
          broadcastConfigFileListenerCopyPoolItemImage,
      'data.notification.broadcast_config.file_listener_copy_pool[].button_text':
          broadcastConfigFileListenerCopyPoolItemButtonText,
      'data.notification.broadcast_config.power_connection_copy_pool[]':
          broadcastConfigPowerConnectionCopyPool,
      'data.notification.broadcast_config.power_connection_copy_pool[].id':
          broadcastConfigPowerConnectionCopyPoolItemId,
      'data.notification.broadcast_config.power_connection_copy_pool[].language':
          broadcastConfigPowerConnectionCopyPoolItemLanguage,
      'data.notification.broadcast_config.power_connection_copy_pool[].title':
          broadcastConfigPowerConnectionCopyPoolItemTitle,
      'data.notification.broadcast_config.power_connection_copy_pool[].body':
          broadcastConfigPowerConnectionCopyPoolItemBody,
      'data.notification.broadcast_config.power_connection_copy_pool[].image':
          broadcastConfigPowerConnectionCopyPoolItemImage,
      'data.notification.broadcast_config.power_connection_copy_pool[].button_text':
          broadcastConfigPowerConnectionCopyPoolItemButtonText,
      'data.notification.broadcast_config.reboot_copy_pool[]':
          broadcastConfigRebootCopyPool,
      'data.notification.broadcast_config.reboot_copy_pool[].id':
          broadcastConfigRebootCopyPoolItemId,
      'data.notification.broadcast_config.reboot_copy_pool[].language':
          broadcastConfigRebootCopyPoolItemLanguage,
      'data.notification.broadcast_config.reboot_copy_pool[].title':
          broadcastConfigRebootCopyPoolItemTitle,
      'data.notification.broadcast_config.reboot_copy_pool[].body':
          broadcastConfigRebootCopyPoolItemBody,
      'data.notification.broadcast_config.reboot_copy_pool[].image':
          broadcastConfigRebootCopyPoolItemImage,
      'data.notification.broadcast_config.reboot_copy_pool[].button_text':
          broadcastConfigRebootCopyPoolItemButtonText,
      'data.notification.broadcast_config.ad_click_copy_pool[]':
          broadcastConfigAdClickCopyPool,
      'data.notification.broadcast_config.ad_click_copy_pool[].id':
          broadcastConfigAdClickCopyPoolItemId,
      'data.notification.broadcast_config.ad_click_copy_pool[].language':
          broadcastConfigAdClickCopyPoolItemLanguage,
      'data.notification.broadcast_config.ad_click_copy_pool[].title':
          broadcastConfigAdClickCopyPoolItemTitle,
      'data.notification.broadcast_config.ad_click_copy_pool[].body':
          broadcastConfigAdClickCopyPoolItemBody,
      'data.notification.broadcast_config.ad_click_copy_pool[].image':
          broadcastConfigAdClickCopyPoolItemImage,
      'data.notification.broadcast_config.ad_click_copy_pool[].button_text':
          broadcastConfigAdClickCopyPoolItemButtonText,
      'data.notification.broadcast_config.home_key_copy_pool[]':
          broadcastConfigHomeKeyCopyPool,
      'data.notification.broadcast_config.home_key_copy_pool[].id':
          broadcastConfigHomeKeyCopyPoolItemId,
      'data.notification.broadcast_config.home_key_copy_pool[].language':
          broadcastConfigHomeKeyCopyPoolItemLanguage,
      'data.notification.broadcast_config.home_key_copy_pool[].title':
          broadcastConfigHomeKeyCopyPoolItemTitle,
      'data.notification.broadcast_config.home_key_copy_pool[].body':
          broadcastConfigHomeKeyCopyPoolItemBody,
      'data.notification.broadcast_config.home_key_copy_pool[].image':
          broadcastConfigHomeKeyCopyPoolItemImage,
      'data.notification.broadcast_config.home_key_copy_pool[].button_text':
          broadcastConfigHomeKeyCopyPoolItemButtonText,
      'data.notification.broadcast_config.recent_apps_key_copy_pool[]':
          broadcastConfigRecentAppsKeyCopyPool,
      'data.notification.broadcast_config.recent_apps_key_copy_pool[].id':
          broadcastConfigRecentAppsKeyCopyPoolItemId,
      'data.notification.broadcast_config.recent_apps_key_copy_pool[].language':
          broadcastConfigRecentAppsKeyCopyPoolItemLanguage,
      'data.notification.broadcast_config.recent_apps_key_copy_pool[].title':
          broadcastConfigRecentAppsKeyCopyPoolItemTitle,
      'data.notification.broadcast_config.recent_apps_key_copy_pool[].body':
          broadcastConfigRecentAppsKeyCopyPoolItemBody,
      'data.notification.broadcast_config.recent_apps_key_copy_pool[].image':
          broadcastConfigRecentAppsKeyCopyPoolItemImage,
      'data.notification.broadcast_config.recent_apps_key_copy_pool[].button_text':
          broadcastConfigRecentAppsKeyCopyPoolItemButtonText,
      'data.notification.persistent_config.copy_pool[]':
          persistentConfigCopyPool,
      'data.notification.persistent_config.copy_pool[].id':
          persistentConfigCopyPoolItemId,
      'data.notification.persistent_config.copy_pool[].language':
          persistentConfigCopyPoolItemLanguage,
      'data.notification.persistent_config.copy_pool[].title':
          persistentConfigCopyPoolItemTitle,
      'data.notification.persistent_config.copy_pool[].body':
          persistentConfigCopyPoolItemBody,
      'data.notification.persistent_config.copy_pool[].image':
          persistentConfigCopyPoolItemImage,
      'data.notification.persistent_config.copy_pool[].button_text':
          persistentConfigCopyPoolItemButtonText,
      'data.notification.floating_window_config.copy_pool[]':
          floatingWindowConfigCopyPool,
      'data.notification.floating_window_config.copy_pool[].id':
          floatingWindowConfigCopyPoolItemId,
      'data.notification.floating_window_config.copy_pool[].language':
          floatingWindowConfigCopyPoolItemLanguage,
      'data.notification.floating_window_config.copy_pool[].title':
          floatingWindowConfigCopyPoolItemTitle,
      'data.notification.floating_window_config.copy_pool[].body':
          floatingWindowConfigCopyPoolItemBody,
      'data.notification.floating_window_config.copy_pool[].image':
          floatingWindowConfigCopyPoolItemImage,
      'data.notification.floating_window_config.copy_pool[].button_text':
          floatingWindowConfigCopyPoolItemButtonText,
    };
    for (final entry in paths.entries) {
      if (entry.value.trim().isEmpty) {
        throw ArgumentError.value(
          entry.value,
          entry.key,
          'mapping key must not be empty',
        );
      }
    }
    return <String, Object?>{
      'schemaRevision': schemaRevision,
      'mappingRevision': mappingRevision,
      'paths': paths,
    };
  }
}
