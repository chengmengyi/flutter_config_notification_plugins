package com.flutter.config.notification.flutter_config_notification_plugins

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith

internal class RemoteNotificationConfigStoreTest {
    @Test
    fun `decodes nested and array fields with project mapping`() {
        val request = request()
        val decoded =
            RemoteNotificationConfigStore.decode(
                request,
                """
                {
                  "decal": 200,
                  "concur": {
                    "revisable": {
                      "catalyst": true,
                      "scam": 0,
                      "risotto": 30,
                      "serpent": 100,
                      "statutory": true,
                      "capital": true,
                      "repave": true,
                      "lunchtime": true,
                      "curry": true,
                      "avid": [{"starboard": "channel-1"}]
                    }
                  }
                }
                """.trimIndent(),
            )

        assertEquals(true, decoded.notification.getBoolean("enabled"))
        assertEquals(30, decoded.notification.getInt("notification_interval_minutes"))
        assertEquals(
            "channel-1",
            decoded.notification
                .getJSONArray("scheduled_notification_arr")
                .getJSONObject(0)
                .getString("id"),
        )
    }

    @Test
    fun `rejects non-success business response`() {
        assertFailsWith<IllegalArgumentException> {
            RemoteNotificationConfigStore.decode(
                request(),
                """{"decal":503,"concur":{"revisable":{}}}""",
            )
        }
    }

    private fun request(): RemoteNotificationRequest =
        RemoteNotificationRequest(
            url = "https://example.com/config",
            headers = emptyMap(),
            body = org.json.JSONObject(),
            paths =
                linkedMapOf(
                    "code" to "decal",
                    "data" to "concur",
                    "data.notification" to "revisable",
                    "data.notification.enabled" to "catalyst",
                    "data.notification.first_send_delay_minutes" to "scam",
                    "data.notification.notification_interval_minutes" to "risotto",
                    "data.notification.notification_total_limit" to "serpent",
                    "data.notification.scheduled_enabled" to "statutory",
                    "data.notification.broadcast_enabled" to "capital",
                    "data.notification.media_enabled" to "repave",
                    "data.notification.persistent_enabled" to "lunchtime",
                    "data.notification.floating_window_enabled" to "curry",
                    "data.notification.scheduled_notification_arr[]" to "avid",
                    "data.notification.scheduled_notification_arr[].id" to "starboard",
                ),
            timeoutMilliseconds = 10_000,
            maxAttempts = 1,
            retryDelayMilliseconds = emptyList(),
        )
}
