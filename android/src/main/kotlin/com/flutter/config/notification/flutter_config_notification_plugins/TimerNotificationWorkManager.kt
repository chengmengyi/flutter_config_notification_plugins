package com.flutter.config.notification.flutter_config_notification_plugins

import android.content.Context
import android.util.Log
import androidx.work.Data
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import java.util.concurrent.TimeUnit

object TimerNotificationWorkManager {
    const val INPUT_TIMER_SLOT = "timer_slot"
    const val INPUT_SCHEDULE_ID = "schedule_id"
    private const val TAG = "TimerNotificationWorkMgr"
    private const val MIN_PERIODIC_INTERVAL_MILLIS = 15L * 60L * 1000L
    private const val WORK_NAME_PREFIX = "pdf_flow_timer_notification_work_"
    private const val WORK_TAG = "pdf_flow_timer_notification_work"

    fun schedule(context: Context, scheduleId: Int, update: Boolean) {
        val config =
            LocalNotificationScheduler.timerWorkConfigs(context)
                .firstOrNull { it.scheduleId == scheduleId } ?: return
        enqueue(context.applicationContext, config, update)
    }

    fun restore(context: Context) {
        val appContext = context.applicationContext
        val configs = LocalNotificationScheduler.timerWorkConfigs(appContext)
        WorkManager.getInstance(appContext).cancelAllWorkByTag(WORK_TAG)
        configs.forEach { enqueue(appContext, it, update = true) }
        Log.d(TAG, "restore count=${configs.size}")
    }

    fun cancelAll(context: Context) {
        WorkManager.getInstance(context.applicationContext).cancelAllWorkByTag(WORK_TAG)
    }

    private fun enqueue(
        context: Context,
        config: LocalNotificationScheduler.TimerWorkConfig,
        update: Boolean,
    ) {
        val interval = config.intervalMillis.coerceAtLeast(MIN_PERIODIC_INTERVAL_MILLIS)
        val request =
            PeriodicWorkRequestBuilder<TimerNotificationWorker>(interval, TimeUnit.MILLISECONDS)
                .setInitialDelay(interval, TimeUnit.MILLISECONDS)
                .setInputData(
                    Data.Builder()
                        .putInt(INPUT_TIMER_SLOT, config.slot)
                        .putInt(INPUT_SCHEDULE_ID, config.scheduleId)
                        .build(),
                )
                .addTag(WORK_TAG)
                .addTag(workName(config.scheduleId))
                .build()
        WorkManager.getInstance(context).enqueueUniquePeriodicWork(
            workName(config.scheduleId),
            if (update) ExistingPeriodicWorkPolicy.UPDATE else ExistingPeriodicWorkPolicy.KEEP,
            request,
        )
        Log.d(
            TAG,
            "enqueue slot=${config.slot} scheduleId=${config.scheduleId} interval=$interval update=$update",
        )
    }

    private fun workName(scheduleId: Int) = "$WORK_NAME_PREFIX$scheduleId"
}
