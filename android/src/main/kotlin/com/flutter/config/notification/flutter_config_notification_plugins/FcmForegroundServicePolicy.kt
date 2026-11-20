package com.flutter.config.notification.flutter_config_notification_plugins

import com.google.firebase.messaging.RemoteMessage

internal object FcmForegroundServicePolicy {
    fun shouldStart(deliveredPriority: Int): Boolean =
        deliveredPriority == RemoteMessage.PRIORITY_HIGH
}
