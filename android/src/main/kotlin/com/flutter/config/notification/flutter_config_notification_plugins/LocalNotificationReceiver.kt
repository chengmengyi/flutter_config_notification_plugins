package com.flutter.config.notification.flutter_config_notification_plugins

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class LocalNotificationReceiver : BroadcastReceiver() {
    override fun onReceive(
        context: Context,
        intent: Intent,
    ) {
        try {
            Log.d("LocalNotificationPlugin", "LocalNotificationReceiver.onReceive")
            if (!LocalNotificationScheduler.handleAlarm(context, intent)) {
                // Migrate an Alarm PendingIntent created by a previous plugin version.
                FlutterConfigNotificationPluginsPlugin.showNotificationFromIntent(context, intent)
                LocalNotificationScheduler.register(context, intent)
            }
        } catch (e: Exception) {
            Log.d("LocalNotificationPlugin", "LocalNotificationReceiver failed error=${e.message}")
        }
    }
}
