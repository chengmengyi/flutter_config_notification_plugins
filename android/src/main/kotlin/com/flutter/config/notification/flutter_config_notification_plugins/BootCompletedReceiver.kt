package com.flutter.config.notification.flutter_config_notification_plugins

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BootCompletedReceiver : BroadcastReceiver() {
    override fun onReceive(
        context: Context,
        intent: Intent,
    ) {
        val action = intent.action ?: "unknown"
        try {
            Log.d("LocalNotificationPlugin", "BootCompletedReceiver.onReceive action=$action")
            FlutterConfigNotificationPluginsPlugin.restoreAfterBoot(
                context = context,
                reason = action,
            )
            if (intent.action == Intent.ACTION_LOCKED_BOOT_COMPLETED) {
                RemoteBroadcastNotificationReceiver.schedule(
                    context,
                    RemoteNotificationRuntime.EVENT_REBOOT,
                )
            }
        } catch (e: Exception) {
            Log.d("LocalNotificationPlugin", "BootCompletedReceiver failed action=$action error=${e.message}")
        }
    }
}
