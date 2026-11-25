package com.flutter.config.notification.flutter_config_notification_plugins

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.util.Log

class TimerOverlayReceiver : BroadcastReceiver() {
    override fun onReceive(
        context: Context,
        intent: Intent?,
    ) {
        val pendingResult = goAsync()
        try {
            TimerOverlayHelper.handleAlarm(context)
        } catch (e: Exception) {
            Log.d("TimerOverlayReceiver", "onReceive failed error=${e.message}")
        } finally {
            finishWhenOverlayStartSettles(pendingResult)
        }
    }

    private fun finishWhenOverlayStartSettles(pendingResult: PendingResult) {
        val handler = Handler(Looper.getMainLooper())
        val startedAt = SystemClock.uptimeMillis()
        fun check() {
            val pending =
                Android15OverlayStartCoordinator.hasPending(
                    Android15OverlayStartCoordinator.Kind.TIMER,
                )
            if (!pending || SystemClock.uptimeMillis() - startedAt >= MAX_ASYNC_WAIT_MILLIS) {
                runCatching { pendingResult.finish() }
                return
            }
            handler.postDelayed({ check() }, ASYNC_POLL_MILLIS)
        }
        handler.post { check() }
    }

    companion object {
        private const val ASYNC_POLL_MILLIS = 50L
        private const val MAX_ASYNC_WAIT_MILLIS = 6_000L
    }
}
