package com.flutter.config.notification.flutter_config_notification_plugins

import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat

/** Reconciles every remote scheduled/media entry into the persistent scheduler. */
internal object RemoteNotificationScheduleCoordinator {
    private const val PREFS_NAME = "flutter_config_notification_plugins_remote_schedules"
    private const val KEY_SCHEDULED_INITIALIZED = "scheduled_initialized"
    private const val KEY_MEDIA_INITIALIZED = "media_initialized"
    private const val KEY_MEDIA_IMAGE = "media_image"

    fun initializeScheduled(context: Context) {
        prefs(context).edit().putBoolean(KEY_SCHEDULED_INITIALIZED, true).commit()
        reconcile(context)
    }

    fun initializeMedia(
        context: Context,
        image: String,
    ) {
        prefs(context).edit()
            .putBoolean(KEY_MEDIA_INITIALIZED, true)
            .putString(KEY_MEDIA_IMAGE, image)
            .commit()
        reconcile(context)
    }

    fun restore(context: Context) {
        reconcile(context)
    }

    fun disable(context: Context) {
        prefs(context).edit().clear().commit()
        LocalNotificationScheduler.clearRemoteSchedules(context)
    }

    private fun reconcile(context: Context) {
        val config = RemoteNotificationRuntime.read(context)
        if (config == null || !config.enabled) {
            LocalNotificationScheduler.clearRemoteSchedules(context)
            return
        }
        val sharedPrefs = prefs(context)
        val installTime = RemoteNotificationRuntime.rememberInstallTimeIfAbsent(context)
        val intents = mutableListOf<Intent>()
        if (sharedPrefs.getBoolean(KEY_SCHEDULED_INITIALIZED, false) && config.scheduledEnabled) {
            config.scheduled.forEach { item ->
                intents +=
                    baseIntent(context, stableId("scheduled:${item.id}"), "local").apply {
                        putExtra("channelId", item.id)
                        putExtra("channelName", item.channelName)
                        putExtra("channelDescription", item.channelName)
                        putExtra("priority", NotificationCompat.PRIORITY_MAX)
                        putExtra("importance", android.app.NotificationManager.IMPORTANCE_MAX)
                        putExtra("repeatIntervalMilliseconds", item.intervalMinutes * 60_000L)
                        putExtra(LocalNotificationScheduler.EXTRA_REMOTE_SCHEDULE_ID, item.id)
                        putExtra(
                            LocalNotificationScheduler.EXTRA_INITIAL_TRIGGER_AT,
                            installTime + item.firstDelayMinutes * 60_000L,
                        )
                    }
            }
        }
        if (sharedPrefs.getBoolean(KEY_MEDIA_INITIALIZED, false) && config.mediaEnabled) {
            val image = sharedPrefs.getString(KEY_MEDIA_IMAGE, null)
            config.media.forEach { item ->
                intents +=
                    baseIntent(context, stableId("media:${item.id}"), "media").apply {
                        putExtra("channelId", item.id)
                        putExtra("channelName", item.channelName)
                        putExtra("channelDescription", item.channelName)
                        putExtra("priority", NotificationCompat.PRIORITY_HIGH)
                        putExtra("importance", android.app.NotificationManager.IMPORTANCE_HIGH)
                        putExtra("mediaBackgroundImageName", image)
                        putExtra("style", "media")
                        putExtra("repeatIntervalMilliseconds", item.intervalMinutes * 60_000L)
                        putExtra(LocalNotificationScheduler.EXTRA_REMOTE_MEDIA_ID, item.id)
                        putExtra(
                            LocalNotificationScheduler.EXTRA_INITIAL_TRIGGER_AT,
                            installTime + item.firstDelayMinutes * 60_000L,
                        )
                    }
            }
        }
        LocalNotificationScheduler.replaceRemoteSchedules(context, intents)
    }

    private fun baseIntent(
        context: Context,
        id: Int,
        payload: String,
    ) =
        Intent(context.applicationContext, LocalNotificationReceiver::class.java).apply {
            putExtra("id", id)
            putExtra("payload", payload)
            putExtra(LocalNotificationScheduler.EXTRA_REMOTE_CONFIG_SCHEDULE, true)
        }

    private fun stableId(value: String): Int {
        val positive = value.hashCode() and Int.MAX_VALUE
        return if (positive == 0) 1 else positive
    }

    private fun prefs(context: Context) =
        context.applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
}
