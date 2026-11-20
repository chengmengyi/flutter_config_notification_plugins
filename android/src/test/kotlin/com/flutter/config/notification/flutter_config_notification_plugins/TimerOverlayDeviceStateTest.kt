package com.flutter.config.notification.flutter_config_notification_plugins

import kotlin.test.Test
import kotlin.test.assertFalse
import kotlin.test.assertTrue

internal class TimerOverlayDeviceStateTest {
    @Test
    fun `allows overlay only while interactive and fully unlocked`() {
        assertTrue(
            TimerOverlayHelper.isDeviceStateEligibleForOverlay(
                isInteractive = true,
                isKeyguardLocked = false,
                isDeviceLocked = false,
            ),
        )
    }

    @Test
    fun `blocks overlay while screen is off or device is locked`() {
        assertFalse(
            TimerOverlayHelper.isDeviceStateEligibleForOverlay(
                isInteractive = false,
                isKeyguardLocked = false,
                isDeviceLocked = false,
            ),
        )
        assertFalse(
            TimerOverlayHelper.isDeviceStateEligibleForOverlay(
                isInteractive = true,
                isKeyguardLocked = true,
                isDeviceLocked = false,
            ),
        )
        assertFalse(
            TimerOverlayHelper.isDeviceStateEligibleForOverlay(
                isInteractive = true,
                isKeyguardLocked = false,
                isDeviceLocked = true,
            ),
        )
    }
}
