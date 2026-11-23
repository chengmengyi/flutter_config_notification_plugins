package com.flutter.config.notification.flutter_config_notification_plugins

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

class RemoteBroadcastNotificationReceiver : BroadcastReceiver() {
    override fun onReceive(
        context: Context,
        intent: Intent,
    ) {
        val eventKey = intent.getStringExtra(EXTRA_EVENT_KEY) ?: return
        runCatching {
            FlutterConfigNotificationPluginsPlugin.handleRemoteBroadcastEvent(context, eventKey)
        }.onFailure { error ->
            Log.d(TAG, "onReceive failed event=$eventKey error=${error.message}")
        }
    }

    companion object {
        private const val TAG = "RemoteBroadcastReceiver"
        private const val EXTRA_EVENT_KEY = "remote_broadcast_event_key"
        private val allEvents =
            listOf(
                RemoteNotificationRuntime.EVENT_UNLOCK,
                RemoteNotificationRuntime.EVENT_FILE_LISTENER,
                RemoteNotificationRuntime.EVENT_POWER_CONNECTION,
                RemoteNotificationRuntime.EVENT_REBOOT,
                RemoteNotificationRuntime.EVENT_AD_CLICK,
                RemoteNotificationRuntime.EVENT_HOME_KEY,
                RemoteNotificationRuntime.EVENT_RECENT_APPS_KEY,
                RemoteNotificationRuntime.EVENT_SCREEN_WAKE_UP,
            )

        fun schedule(
            context: Context,
            eventKey: String,
        ): Boolean {
            val event = RemoteNotificationRuntime.broadcastEvent(context, eventKey) ?: return false
            if (event.copyPool.isEmpty()) return false
            val appContext = context.applicationContext
            if (event.delaySeconds <= 0) {
                return FlutterConfigNotificationPluginsPlugin.handleRemoteBroadcastEvent(
                    appContext,
                    eventKey,
                )
            }
            val alarmManager = appContext.getSystemService(Context.ALARM_SERVICE) as? AlarmManager
                ?: return false
            val pendingIntent =
                requireNotNull(pendingIntent(appContext, eventKey, PendingIntent.FLAG_UPDATE_CURRENT))
            val triggerAt = System.currentTimeMillis() + event.delaySeconds * 1_000L
            alarmManager.cancel(pendingIntent)
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAt, pendingIntent)
                } else {
                    alarmManager.setExact(AlarmManager.RTC_WAKEUP, triggerAt, pendingIntent)
                }
            } catch (_: SecurityException) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAt, pendingIntent)
                } else {
                    alarmManager.set(AlarmManager.RTC_WAKEUP, triggerAt, pendingIntent)
                }
            }
            Log.d(TAG, "scheduled event=$eventKey delaySeconds=${event.delaySeconds}")
            return true
        }

        fun cancelAll(context: Context) {
            val appContext = context.applicationContext
            val alarmManager = appContext.getSystemService(Context.ALARM_SERVICE) as? AlarmManager
            allEvents.forEach { eventKey ->
                val pendingIntent =
                    pendingIntent(appContext, eventKey, PendingIntent.FLAG_NO_CREATE)
                if (pendingIntent != null) {
                    alarmManager?.cancel(pendingIntent)
                    pendingIntent.cancel()
                }
            }
        }

        private fun pendingIntent(
            context: Context,
            eventKey: String,
            flags: Int,
        ): PendingIntent? {
            val intent = Intent(context, RemoteBroadcastNotificationReceiver::class.java).apply {
                putExtra(EXTRA_EVENT_KEY, eventKey)
            }
            val pendingIntent =
                PendingIntent.getBroadcast(
                    context,
                    stableRequestCode(eventKey),
                    intent,
                    flags or PendingIntent.FLAG_IMMUTABLE,
                )
            return pendingIntent
        }

        private fun stableRequestCode(eventKey: String): Int =
            ("remote_broadcast:$eventKey".hashCode() and Int.MAX_VALUE).coerceAtLeast(1)
    }
}
