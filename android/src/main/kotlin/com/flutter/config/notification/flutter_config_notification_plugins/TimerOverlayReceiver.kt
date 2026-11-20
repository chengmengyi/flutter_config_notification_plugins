package com.flutter.config.notification.flutter_config_notification_plugins

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class TimerOverlayReceiver : BroadcastReceiver() {
    override fun onReceive(
        context: Context,
        intent: Intent?,
    ) {
        try {
            TimerOverlayHelper.handleAlarm(context)
        } catch (e: Exception) {
            Log.d("TimerOverlayReceiver", "onReceive failed error=${e.message}")
        }
    }
}
