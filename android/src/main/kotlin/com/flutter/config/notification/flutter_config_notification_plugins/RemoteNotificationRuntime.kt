package com.flutter.config.notification.flutter_config_notification_plugins

import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone
import kotlin.math.min
import kotlin.random.Random

internal data class RemoteCopyItem(
    val id: String,
    val language: String,
    val title: String,
    val body: String,
    val image: String,
    val buttonText: String,
    val secondaryButtonText: String,
)

internal data class RemoteScheduledNotification(
    val id: String,
    val channelName: String,
    val firstDelayMinutes: Int,
    val intervalMinutes: Int,
    val dailyLimit: Int,
    val backgroundTriggerDelaySeconds: Int,
    val copyPool: List<RemoteCopyItem>,
)

internal data class RemoteMediaNotification(
    val id: String,
    val channelName: String,
    val firstDelayMinutes: Int,
    val intervalMinutes: Int,
    val copyPool: List<RemoteCopyItem>,
)

internal data class RemoteBroadcastEventConfig(
    val key: String,
    val enabled: Boolean,
    val dailyLimit: Int,
    val delaySeconds: Int,
    val copyPool: List<RemoteCopyItem>,
)

internal data class RemoteBroadcastConfig(
    val sendIntervalMinutes: Int,
    val dailyLimit: Int,
    val events: Map<String, RemoteBroadcastEventConfig>,
)

internal data class RemoteFloatingWindowConfig(
    val onlySendFloatingWindow: Boolean,
    val triggerWithScheduled: Boolean,
    val triggerWithBroadcast: Boolean,
    val standaloneEnabled: Boolean,
    val standaloneIntervalMinutes: Int,
    val standaloneDailyLimit: Int,
    val misclickEnabled: Boolean,
    val misclickPercent: Int,
    val copyPool: List<RemoteCopyItem>,
)

internal data class RemoteRefreshConfig(
    val enabled: Boolean,
    val intervalMillis: Long,
    val additionalRefreshCount: Int,
)

internal data class RemoteNotificationRuntimeConfig(
    val enabled: Boolean,
    val firstSendDelayMinutes: Int,
    val notificationIntervalMinutes: Int,
    val notificationTotalDailyLimit: Int,
    val refresh: RemoteRefreshConfig,
    val scheduledEnabled: Boolean,
    val broadcastEnabled: Boolean,
    val mediaEnabled: Boolean,
    val floatingWindowEnabled: Boolean,
    val scheduled: List<RemoteScheduledNotification>,
    val media: List<RemoteMediaNotification>,
    val broadcast: RemoteBroadcastConfig?,
    val floating: RemoteFloatingWindowConfig?,
)

internal enum class RemoteDisplaySource {
    SCHEDULED,
    BROADCAST,
    FCM,
}

/** Runtime reader and accounting for the decoded remote notification configuration. */
internal object RemoteNotificationRuntime {
    const val EVENT_UNLOCK = "unlock"
    const val EVENT_FILE_LISTENER = "file_listener"
    const val EVENT_POWER_CONNECTION = "power_connection"
    const val EVENT_REBOOT = "reboot"
    const val EVENT_AD_CLICK = "ad_click"
    const val EVENT_HOME_KEY = "home_key"
    const val EVENT_RECENT_APPS_KEY = "recent_apps_key"
    const val EVENT_SCREEN_WAKE_UP = "screen_wake_up"

    private const val TAG = "RemoteNotificationRuntime"
    private const val PREFS_NAME = "flutter_config_notification_plugins_remote_runtime"
    private const val KEY_INSTALL_TIME = "install_time_millis"
    private const val KEY_BACKGROUND_AT = "background_at_millis"
    private const val KEY_COUNTER_DATE = "counter_date"
    private const val KEY_GLOBAL_LAST_DISPLAYED_AT = "global_last_displayed_at"
    private const val KEY_GLOBAL_DAILY_COUNT = "global_daily_count"
    private const val KEY_BROADCAST_LAST_DISPLAYED_AT = "broadcast_last_displayed_at"
    private const val KEY_BROADCAST_DAILY_COUNT = "broadcast_daily_count"
    private const val KEY_SCHEDULED_DAILY_PREFIX = "scheduled_daily_count_"
    private const val KEY_BROADCAST_EVENT_DAILY_PREFIX = "broadcast_event_daily_count_"
    private const val KEY_MEDIA_LAST_DISPLAYED_PREFIX = "media_last_displayed_at_"
    private val lock = Any()

    fun rememberInstallTimeIfAbsent(context: Context): Long {
        synchronized(lock) {
            val sharedPrefs = prefs(context)
            val stored = sharedPrefs.getLong(KEY_INSTALL_TIME, 0L)
            if (stored > 0L) return stored
            val firstInstallTime =
                runCatching {
                    context.packageManager.getPackageInfo(context.packageName, 0).firstInstallTime
                }.getOrDefault(0L)
            val resolved = firstInstallTime.takeIf { it > 0L } ?: System.currentTimeMillis()
            sharedPrefs.edit().putLong(KEY_INSTALL_TIME, resolved).commit()
            return resolved
        }
    }

    fun onBackground(context: Context) {
        synchronized(lock) {
            val sharedPrefs = prefs(context)
            if (sharedPrefs.getLong(KEY_BACKGROUND_AT, 0L) <= 0L) {
                sharedPrefs.edit().putLong(KEY_BACKGROUND_AT, System.currentTimeMillis()).commit()
            }
        }
    }

    fun onForeground(context: Context) {
        synchronized(lock) {
            prefs(context).edit().remove(KEY_BACKGROUND_AT).commit()
        }
    }

    fun read(context: Context): RemoteNotificationRuntimeConfig? {
        val notification = RemoteNotificationConfigStore.readNotification(context) ?: return null
        return runCatching { parse(notification) }
            .onFailure { Log.d(TAG, "read failed error=${it.message}") }
            .getOrNull()
    }

    fun scheduledItem(context: Context, id: String): RemoteScheduledNotification? =
        read(context)?.scheduled?.firstOrNull { it.id == id }

    fun mediaItems(context: Context): List<RemoteMediaNotification> =
        read(context)?.takeIf { it.enabled && it.mediaEnabled }?.media.orEmpty()

    fun randomScheduledCopy(
        context: Context,
        id: String,
    ): Pair<RemoteScheduledNotification, RemoteCopyItem>? {
        val config = read(context) ?: return null
        if (!config.enabled || !config.scheduledEnabled) return null
        val item = config.scheduled.firstOrNull { it.id == id } ?: return null
        if (item.copyPool.isEmpty()) return null
        return item to item.copyPool[Random.nextInt(item.copyPool.size)]
    }

    fun broadcastEvent(
        context: Context,
        eventKey: String,
    ): RemoteBroadcastEventConfig? {
        val config = read(context) ?: return null
        if (!config.enabled || !config.broadcastEnabled) return null
        return config.broadcast?.events?.get(eventKey)?.takeIf { it.enabled }
    }

    fun randomBroadcastCopy(
        context: Context,
        eventKey: String,
    ): Pair<RemoteBroadcastEventConfig, RemoteCopyItem>? {
        val event = broadcastEvent(context, eventKey) ?: return null
        if (event.copyPool.isEmpty()) return null
        return event to event.copyPool[Random.nextInt(event.copyPool.size)]
    }

    fun selectMedia(
        context: Context,
        preferredId: String? = null,
        now: Long = System.currentTimeMillis(),
    ): Pair<RemoteMediaNotification, RemoteCopyItem>? {
        val config = read(context) ?: return null
        if (!config.enabled || !config.mediaEnabled) return null
        val installTime = rememberInstallTimeIfAbsent(context)
        val candidates =
            config.media.filter { item ->
                (preferredId == null || item.id == preferredId) &&
                    item.copyPool.isNotEmpty() &&
                    now - installTime >= minutesToMillis(item.firstDelayMinutes) &&
                    mediaIntervalSatisfied(context, item, now)
            }
        if (candidates.isEmpty()) return null
        val item = candidates[Random.nextInt(candidates.size)]
        return item to item.copyPool[Random.nextInt(item.copyPool.size)]
    }

    fun recordMediaDisplayed(
        context: Context,
        mediaId: String,
        now: Long = System.currentTimeMillis(),
    ) {
        synchronized(lock) {
            prefs(context).edit().putLong(KEY_MEDIA_LAST_DISPLAYED_PREFIX + mediaId, now).commit()
        }
    }

    fun canDisplay(
        context: Context,
        source: RemoteDisplaySource,
        sourceKey: String? = null,
        now: Long = System.currentTimeMillis(),
    ): Boolean {
        synchronized(lock) {
            val config = read(context) ?: return false
            if (!config.enabled) return false
            val installTime = rememberInstallTimeIfAbsent(context)
            if (now - installTime < minutesToMillis(config.firstSendDelayMinutes)) return false
            if (source == RemoteDisplaySource.FCM) return true

            resetDailyCountersIfNeeded(context, now)
            val sharedPrefs = prefs(context)
            val lastGlobal = sharedPrefs.getLong(KEY_GLOBAL_LAST_DISPLAYED_AT, 0L)
            if (lastGlobal > 0L && now - lastGlobal < minutesToMillis(config.notificationIntervalMinutes)) {
                return false
            }
            if (sharedPrefs.getInt(KEY_GLOBAL_DAILY_COUNT, 0) >= config.notificationTotalDailyLimit) {
                return false
            }

            return when (source) {
                RemoteDisplaySource.SCHEDULED -> {
                    if (!config.scheduledEnabled) return false
                    val scheduled = sourceKey?.let { key -> config.scheduled.firstOrNull { it.id == key } }
                    if (sourceKey != null && scheduled == null) return false
                    if (scheduled != null) {
                        if (now - installTime < minutesToMillis(scheduled.firstDelayMinutes)) return false
                        val backgroundAt = sharedPrefs.getLong(KEY_BACKGROUND_AT, 0L)
                        if (backgroundAt <= 0L) return false
                        if (now - backgroundAt < secondsToMillis(scheduled.backgroundTriggerDelaySeconds)) {
                            return false
                        }
                        if (
                            sharedPrefs.getInt(KEY_SCHEDULED_DAILY_PREFIX + scheduled.id, 0) >=
                            scheduled.dailyLimit
                        ) {
                            return false
                        }
                    }
                    true
                }

                RemoteDisplaySource.BROADCAST -> {
                    if (!config.broadcastEnabled) return false
                    val broadcast = config.broadcast ?: return false
                    val event = sourceKey?.let { key -> broadcast.events[key] } ?: return false
                    if (!event.enabled || event.copyPool.isEmpty()) return false
                    val lastBroadcast = sharedPrefs.getLong(KEY_BROADCAST_LAST_DISPLAYED_AT, 0L)
                    if (
                        lastBroadcast > 0L &&
                        now - lastBroadcast < minutesToMillis(broadcast.sendIntervalMinutes)
                    ) {
                        return false
                    }
                    if (sharedPrefs.getInt(KEY_BROADCAST_DAILY_COUNT, 0) >= broadcast.dailyLimit) {
                        return false
                    }
                    sharedPrefs.getInt(KEY_BROADCAST_EVENT_DAILY_PREFIX + event.key, 0) <
                        event.dailyLimit
                }

                RemoteDisplaySource.FCM -> true
            }
        }
    }

    fun recordDisplayed(
        context: Context,
        source: RemoteDisplaySource,
        sourceKey: String? = null,
        now: Long = System.currentTimeMillis(),
    ) {
        if (source == RemoteDisplaySource.FCM) return
        synchronized(lock) {
            resetDailyCountersIfNeeded(context, now)
            val sharedPrefs = prefs(context)
            val editor =
                sharedPrefs.edit()
                    .putLong(KEY_GLOBAL_LAST_DISPLAYED_AT, now)
                    .putInt(KEY_GLOBAL_DAILY_COUNT, sharedPrefs.getInt(KEY_GLOBAL_DAILY_COUNT, 0) + 1)
            when (source) {
                RemoteDisplaySource.SCHEDULED -> {
                    if (!sourceKey.isNullOrBlank()) {
                        val key = KEY_SCHEDULED_DAILY_PREFIX + sourceKey
                        editor.putInt(key, sharedPrefs.getInt(key, 0) + 1)
                    }
                }

                RemoteDisplaySource.BROADCAST -> {
                    editor
                        .putLong(KEY_BROADCAST_LAST_DISPLAYED_AT, now)
                        .putInt(
                            KEY_BROADCAST_DAILY_COUNT,
                            sharedPrefs.getInt(KEY_BROADCAST_DAILY_COUNT, 0) + 1,
                        )
                    if (!sourceKey.isNullOrBlank()) {
                        val key = KEY_BROADCAST_EVENT_DAILY_PREFIX + sourceKey
                        editor.putInt(key, sharedPrefs.getInt(key, 0) + 1)
                    }
                }

                RemoteDisplaySource.FCM -> Unit
            }
            editor.commit()
        }
    }

    fun refreshConfig(context: Context): RemoteRefreshConfig =
        read(context)?.refresh ?: RemoteRefreshConfig(false, 0L, 0)

    fun floatingConfig(context: Context): RemoteFloatingWindowConfig? {
        val config = read(context) ?: return null
        if (!config.enabled || !config.floatingWindowEnabled) return null
        return config.floating
    }

    fun shouldTryFloatingWindow(
        context: Context,
        source: RemoteDisplaySource,
    ): Boolean {
        val floating = floatingConfig(context) ?: return false
        if (floating.copyPool.isEmpty()) return false
        return when (source) {
            RemoteDisplaySource.SCHEDULED -> floating.triggerWithScheduled
            RemoteDisplaySource.BROADCAST -> floating.triggerWithBroadcast
            RemoteDisplaySource.FCM -> false
        }
    }

    fun desiredBroadcastActions(context: Context): Set<String> {
        val config = read(context) ?: return emptySet()
        if (!config.enabled || !config.broadcastEnabled || config.broadcast == null) return emptySet()
        val events = config.broadcast.events
        return buildSet {
            if (events[EVENT_UNLOCK]?.enabled == true) add(Intent.ACTION_USER_PRESENT)
            if (events[EVENT_POWER_CONNECTION]?.enabled == true) {
                add(Intent.ACTION_POWER_CONNECTED)
                add(Intent.ACTION_POWER_DISCONNECTED)
            }
            if (
                events[EVENT_HOME_KEY]?.enabled == true ||
                events[EVENT_RECENT_APPS_KEY]?.enabled == true
            ) {
                add(Intent.ACTION_CLOSE_SYSTEM_DIALOGS)
            }
            if (events[EVENT_SCREEN_WAKE_UP]?.enabled == true) add(Intent.ACTION_SCREEN_ON)
        }
    }

    fun eventKeyForIntent(
        action: String?,
        reason: String?,
    ): String? =
        when (action) {
            Intent.ACTION_USER_PRESENT -> EVENT_UNLOCK
            Intent.ACTION_POWER_CONNECTED,
            Intent.ACTION_POWER_DISCONNECTED,
            -> EVENT_POWER_CONNECTION
            Intent.ACTION_CLOSE_SYSTEM_DIALOGS ->
                when (reason) {
                    "homekey" -> EVENT_HOME_KEY
                    "recentapps" -> EVENT_RECENT_APPS_KEY
                    else -> null
                }
            Intent.ACTION_SCREEN_ON -> EVENT_SCREEN_WAKE_UP
            else -> null
        }

    fun disableAll(context: Context) {
        NotificationRefreshCoordinator.cancel("remote_notification_disabled")
        RemoteNotificationScheduleCoordinator.disable(context)
        RemoteBroadcastNotificationReceiver.cancelAll(context)
        BroadcastNotificationReceiverManager.disable(context)
        GalleryImageObserverHelper.stop(context)
        TimerOverlayHelper.cancel(context)
    }

    private fun mediaIntervalSatisfied(
        context: Context,
        item: RemoteMediaNotification,
        now: Long,
    ): Boolean {
        val last = prefs(context).getLong(KEY_MEDIA_LAST_DISPLAYED_PREFIX + item.id, 0L)
        return last <= 0L || now - last >= minutesToMillis(item.intervalMinutes)
    }

    private fun resetDailyCountersIfNeeded(
        context: Context,
        now: Long,
    ) {
        val sharedPrefs = prefs(context)
        val today = dayKey(now)
        if (sharedPrefs.getString(KEY_COUNTER_DATE, null) == today) return
        val editor =
            sharedPrefs.edit()
                .remove(KEY_GLOBAL_DAILY_COUNT)
                .remove(KEY_BROADCAST_DAILY_COUNT)
        sharedPrefs.all.keys
            .filter { key ->
                key.startsWith(KEY_SCHEDULED_DAILY_PREFIX) ||
                    key.startsWith(KEY_BROADCAST_EVENT_DAILY_PREFIX)
            }.forEach { key -> editor.remove(key) }
        editor.putString(KEY_COUNTER_DATE, today).commit()
    }

    private fun dayKey(now: Long): String =
        SimpleDateFormat("yyyy-MM-dd", Locale.US).apply {
            timeZone = TimeZone.getDefault()
        }.format(Date(now))

    private fun parse(notification: JSONObject): RemoteNotificationRuntimeConfig {
        val refreshEnabled = notification.optBoolean("refresh_enabled", false)
        val refreshIntervalSeconds = notification.optInt("refresh_interval_seconds", 0)
        val refreshDurationSeconds = notification.optInt("refresh_duration_seconds", 0)
        val additionalRefreshCount =
            if (refreshEnabled && refreshIntervalSeconds > 0 && refreshDurationSeconds > 0) {
                min(
                    Int.MAX_VALUE.toLong(),
                    refreshDurationSeconds.toLong() / refreshIntervalSeconds.toLong(),
                )
                    .toInt()
            } else {
                0
            }
        return RemoteNotificationRuntimeConfig(
            enabled = notification.optBoolean("enabled", false),
            firstSendDelayMinutes = notification.optInt("first_send_delay_minutes", 0).coerceAtLeast(0),
            notificationIntervalMinutes =
                notification.optInt("notification_interval_minutes", 1).coerceAtLeast(1),
            notificationTotalDailyLimit =
                notification.optInt("notification_total_limit", 1).coerceAtLeast(1),
            refresh =
                RemoteRefreshConfig(
                    enabled = refreshEnabled && additionalRefreshCount > 0,
                    intervalMillis = secondsToMillis(refreshIntervalSeconds.coerceAtLeast(1)),
                    additionalRefreshCount = additionalRefreshCount,
                ),
            scheduledEnabled = notification.optBoolean("scheduled_enabled", false),
            broadcastEnabled = notification.optBoolean("broadcast_enabled", false),
            mediaEnabled = notification.optBoolean("media_enabled", false),
            floatingWindowEnabled = notification.optBoolean("floating_window_enabled", false),
            scheduled = parseScheduled(notification.optJSONArray("scheduled_notification_arr")),
            media = parseMedia(notification.optJSONArray("media_notification_arr")),
            broadcast = parseBroadcast(notification.optJSONObject("broadcast_config")),
            floating = parseFloating(notification.optJSONObject("floating_window_config")),
        )
    }

    private fun parseScheduled(array: JSONArray?): List<RemoteScheduledNotification> =
        array.objects().mapNotNull { item ->
            val id = item.optString("id").trim()
            if (id.isEmpty()) return@mapNotNull null
            RemoteScheduledNotification(
                id = id,
                channelName = item.optString("channel_name").ifBlank { "Notifications" },
                firstDelayMinutes = item.optInt("first_delay", 0).coerceAtLeast(0),
                intervalMinutes = item.optInt("interval", 1).coerceAtLeast(1),
                dailyLimit = item.optInt("send_limit", 1).coerceAtLeast(1),
                backgroundTriggerDelaySeconds =
                    item.optInt("background_trigger_delay_seconds", 0).coerceAtLeast(0),
                copyPool = parseCopyPool(item.optJSONArray("copy_pool")),
            )
        }

    private fun parseMedia(array: JSONArray?): List<RemoteMediaNotification> =
        array.objects().mapNotNull { item ->
            val id = item.optString("id").trim()
            if (id.isEmpty()) return@mapNotNull null
            RemoteMediaNotification(
                id = id,
                channelName = item.optString("channel_name").ifBlank { "Media notifications" },
                firstDelayMinutes = item.optInt("first_delay", 0).coerceAtLeast(0),
                intervalMinutes = item.optInt("interval", 1).coerceAtLeast(1),
                copyPool = parseCopyPool(item.optJSONArray("copy_pool")),
            )
        }

    private fun parseBroadcast(json: JSONObject?): RemoteBroadcastConfig? {
        json ?: return null
        fun event(key: String): RemoteBroadcastEventConfig =
            RemoteBroadcastEventConfig(
                key = key,
                enabled = json.optBoolean("${key}_enabled", false),
                dailyLimit = json.optInt("${key}_daily_limit", 1).coerceAtLeast(1),
                delaySeconds = json.optInt("${key}_delay_seconds", 0).coerceAtLeast(0),
                copyPool = parseCopyPool(json.optJSONArray("${key}_copy_pool")),
            )
        val eventKeys =
            listOf(
                EVENT_UNLOCK,
                EVENT_FILE_LISTENER,
                EVENT_POWER_CONNECTION,
                EVENT_REBOOT,
                EVENT_AD_CLICK,
                EVENT_HOME_KEY,
                EVENT_RECENT_APPS_KEY,
                EVENT_SCREEN_WAKE_UP,
            )
        return RemoteBroadcastConfig(
            sendIntervalMinutes = json.optInt("send_interval_minutes", 1).coerceAtLeast(1),
            dailyLimit = json.optInt("send_limit", 1).coerceAtLeast(1),
            events = eventKeys.associateWith(::event),
        )
    }

    private fun parseFloating(json: JSONObject?): RemoteFloatingWindowConfig? {
        json ?: return null
        return RemoteFloatingWindowConfig(
            onlySendFloatingWindow = json.optBoolean("only_send_floating_window", false),
            triggerWithScheduled = json.optBoolean("trigger_with_scheduled", false),
            triggerWithBroadcast = json.optBoolean("trigger_with_broadcast", false),
            standaloneEnabled = json.optBoolean("standalone_enabled", false),
            standaloneIntervalMinutes = json.optInt("standalone_interval_minutes", 1).coerceAtLeast(1),
            standaloneDailyLimit = json.optInt("standalone_daily_limit", 1).coerceAtLeast(1),
            misclickEnabled = json.optBoolean("misclick_enabled", false),
            misclickPercent = json.optInt("misclick_percent", 0).coerceIn(0, 100),
            copyPool = parseCopyPool(json.optJSONArray("copy_pool")),
        )
    }

    private fun parseCopyPool(array: JSONArray?): List<RemoteCopyItem> =
        array.objects().map { item ->
            RemoteCopyItem(
                id = item.optString("id"),
                language = item.optString("language"),
                title = item.optString("title"),
                body = item.optString("body"),
                image = item.optString("image"),
                buttonText = item.optString("button_text"),
                secondaryButtonText = item.optString("secondary_button_text"),
            )
        }

    private fun JSONArray?.objects(): List<JSONObject> {
        if (this == null) return emptyList()
        return buildList {
            for (index in 0 until length()) {
                optJSONObject(index)?.let(::add)
            }
        }
    }

    private fun minutesToMillis(minutes: Int): Long =
        minutes.toLong().coerceAtLeast(0L) * 60_000L

    private fun secondsToMillis(seconds: Int): Long =
        seconds.toLong().coerceAtLeast(0L) * 1_000L

    private fun prefs(context: Context) =
        (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            context.applicationContext.createDeviceProtectedStorageContext()
        } else {
            context.applicationContext
        })
            .getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
}
