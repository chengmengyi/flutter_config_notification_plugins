package com.flutter.config.notification.flutter_config_notification_plugins

import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import androidx.core.content.ContextCompat
import kotlin.math.roundToInt

/**
 * Android 15 requires a SYSTEM_ALERT_WINDOW app to already have a visible overlay before it can
 * use that exemption to start a foreground service from the background. This coordinator mounts
 * the real overlay layout first and lets the service claim it after startForeground() succeeds.
 */
object Android15OverlayStartCoordinator {
    private const val TAG = "OverlayStartCoordinator"
    private const val VISIBILITY_TIMEOUT_MILLIS = 1_500L
    private const val SERVICE_CLAIM_TIMEOUT_MILLIS = 5_000L
    private const val FRAME_RECHECK_MILLIS = 16L

    enum class Kind {
        TIMER,
        PROCESSING,
    }

    data class ClaimedOverlay(
        val view: View,
        val layoutParams: Any? = null,
    )

    private data class PendingOverlay(
        val generation: Long,
        val context: Context,
        val view: View,
        val layoutParams: Any?,
        val removeView: (Context, View) -> Unit,
    )

    private val mainHandler = Handler(Looper.getMainLooper())
    private val lock = Any()
    private val pending = mutableMapOf<Kind, PendingOverlay>()
    private var generation = 0L

    fun startTimerService(
        context: Context,
        intent: Intent,
        layoutName: String,
        isBanner: Boolean,
        bannerContents: List<TimerOverlayHelper.TimerOverlayContent>,
        title: String,
        desc: String,
        button: String,
        button2: String?,
    ) {
        val appContext = context.applicationContext
        if (!requiresVisibleOverlayBeforeStart() ||
            FlutterConfigNotificationPluginsPlugin.isHostActivityInForeground() ||
            TimerOverlayService.isOverlayShowing()
        ) {
            startForegroundService(appContext, intent, Kind.TIMER)
            return
        }
        runOnMain {
            if (startUsingVisiblePendingOverlay(Kind.TIMER, appContext, intent)) {
                return@runOnMain
            }
            removeOnMain(Kind.TIMER, "replace_pending_timer")
            val layoutResId =
                if (isBanner) {
                    R.layout.fln_timer_top_banner
                } else {
                    appContext.resources.getIdentifier(layoutName, "layout", appContext.packageName)
                }
            if (layoutResId == 0) {
                Log.d(TAG, "timer preflight skipped missing layout=$layoutName")
                return@runOnMain
            }
            val view =
                runCatching {
                    LayoutInflater.from(appContext).inflate(layoutResId, null, false)
                }.onFailure {
                    Log.e(TAG, "timer preflight inflate failed layout=$layoutName", it)
                }.getOrNull() ?: return@runOnMain
            bindTimerPreview(
                context = appContext,
                view = view,
                isBanner = isBanner,
                bannerContents = bannerContents,
                title = title,
                desc = desc,
                button = button,
                button2 = button2,
            )
            val added =
                TimerOverlayHelper.addViewByReflection(
                    context = appContext,
                    view = view,
                    width = ViewGroup.LayoutParams.MATCH_PARENT,
                    height = ViewGroup.LayoutParams.WRAP_CONTENT,
                    type = 2038,
                    flags = 8,
                    format = -3,
                    gravity = if (isBanner) Gravity.TOP or Gravity.CENTER_HORIZONTAL else Gravity.CENTER,
                    x = 0,
                    y = 0,
                )
            if (!added) {
                Log.d(TAG, "timer preflight addView failed")
                return@runOnMain
            }
            registerPending(
                kind = Kind.TIMER,
                context = appContext,
                view = view,
                layoutParams = null,
                removeView = { targetContext, targetView ->
                    TimerOverlayHelper.removeViewByReflection(targetContext, targetView)
                },
                intent = intent,
            )
        }
    }

    fun startProcessingService(
        context: Context,
        intent: Intent,
        progress: Double,
    ) {
        val appContext = context.applicationContext
        if (!requiresVisibleOverlayBeforeStart() ||
            FlutterConfigNotificationPluginsPlugin.isHostActivityInForeground() ||
            ProcessingOverlayService.isRunning
        ) {
            startForegroundService(appContext, intent, Kind.PROCESSING)
            return
        }
        runOnMain {
            if (startUsingVisiblePendingOverlay(Kind.PROCESSING, appContext, intent)) {
                return@runOnMain
            }
            removeOnMain(Kind.PROCESSING, "replace_pending_processing")
            val rootView =
                runCatching {
                    LayoutInflater.from(appContext).inflate(
                        R.layout.fln_processing_overlay_view,
                        FrameLayout(appContext),
                        false,
                    )
                }.onFailure {
                    Log.e(TAG, "processing preflight inflate failed", it)
                }.getOrNull() ?: return@runOnMain
            val overlaySize = screenWToPx(appContext, 68)
            val iconSize = screenWToPx(appContext, 56)
            rootView.layoutParams = ViewGroup.LayoutParams(overlaySize, overlaySize)
            rootView.findViewById<ProcessingOverlayProgressRingView>(
                R.id.fln_processing_overlay_progress_ring,
            )?.apply {
                layoutParams = FrameLayout.LayoutParams(overlaySize, overlaySize, Gravity.CENTER)
                this.progress = progress.coerceIn(0.0, 1.0).times(100.0).roundToInt()
            }
            rootView.findViewById<ImageView>(R.id.fln_processing_logo)?.apply {
                layoutParams = FrameLayout.LayoutParams(iconSize, iconSize, Gravity.CENTER)
                setImageDrawable(appContext.applicationInfo.loadIcon(appContext.packageManager))
            }
            val layoutParams =
                ProcessingOverlayService.createLayoutParamsByReflection(
                    context = appContext,
                    width = overlaySize,
                    height = overlaySize,
                    type = 2038,
                    flags = 8 or 256,
                    format = -3,
                    gravity = Gravity.TOP or Gravity.START,
                    x =
                        (
                            appContext.resources.displayMetrics.widthPixels -
                                overlaySize -
                                dpToPx(appContext, 10)
                        ).coerceAtLeast(0),
                    y = resolveStatusBarHeight(appContext) + dpToPx(appContext, 10),
                ) ?: return@runOnMain
            if (!ProcessingOverlayService.addViewByReflection(appContext, rootView, layoutParams)) {
                Log.d(TAG, "processing preflight addView failed")
                return@runOnMain
            }
            registerPending(
                kind = Kind.PROCESSING,
                context = appContext,
                view = rootView,
                layoutParams = layoutParams,
                removeView = { targetContext, targetView ->
                    ProcessingOverlayService.removeViewByReflection(targetContext, targetView)
                },
                intent = intent,
            )
        }
    }

    fun claim(kind: Kind): ClaimedOverlay? {
        val claimed = synchronized(lock) { pending.remove(kind) } ?: return null
        Log.d(TAG, "overlay claimed kind=$kind generation=${claimed.generation}")
        return ClaimedOverlay(claimed.view, claimed.layoutParams)
    }

    fun hasPending(kind: Kind): Boolean = synchronized(lock) { pending.containsKey(kind) }

    // The notification fallback must wait for preflight/claim to finish rather than
    // treating a slower Android 15 service start as a failed overlay after 500 ms.
    internal fun whenTimerStartSettles(action: () -> Unit) {
        fun check() {
            if (hasPending(Kind.TIMER)) {
                mainHandler.postDelayed({ check() }, 50L)
            } else {
                action()
            }
        }
        mainHandler.postDelayed({ check() }, 500L)
    }

    fun remove(kind: Kind, reason: String) {
        runOnMain { removeOnMain(kind, reason) }
    }

    private fun registerPending(
        kind: Kind,
        context: Context,
        view: View,
        layoutParams: Any?,
        removeView: (Context, View) -> Unit,
        intent: Intent,
    ) {
        val currentGeneration = synchronized(lock) {
            generation += 1L
            val value = generation
            pending[kind] =
                PendingOverlay(
                    generation = value,
                    context = context,
                    view = view,
                    layoutParams = layoutParams,
                    removeView = removeView,
                )
            value
        }
        val startedAt = android.os.SystemClock.uptimeMillis()
        fun awaitVisibility() {
            val current = synchronized(lock) { pending[kind] }
            if (current?.generation != currentGeneration) return
            if (view.isAttachedToWindow &&
                view.visibility == View.VISIBLE &&
                view.windowVisibility == View.VISIBLE
            ) {
                Log.d(TAG, "overlay visible, starting service kind=$kind generation=$currentGeneration")
                if (!startForegroundService(context, intent, kind)) {
                    removeOnMain(kind, "start_foreground_service_failed")
                    return
                }
                mainHandler.postDelayed(
                    {
                        val unclaimed = synchronized(lock) { pending[kind] }
                        if (unclaimed?.generation == currentGeneration) {
                            removeOnMain(kind, "service_claim_timeout")
                        }
                    },
                    SERVICE_CLAIM_TIMEOUT_MILLIS,
                )
                return
            }
            if (android.os.SystemClock.uptimeMillis() - startedAt >= VISIBILITY_TIMEOUT_MILLIS) {
                removeOnMain(kind, "visibility_timeout")
                return
            }
            mainHandler.postDelayed({ awaitVisibility() }, FRAME_RECHECK_MILLIS)
        }
        awaitVisibility()
    }

    private fun startForegroundService(
        context: Context,
        intent: Intent,
        kind: Kind,
    ): Boolean {
        return try {
            ContextCompat.startForegroundService(context, intent)
            Log.d(TAG, "startForegroundService requested kind=$kind")
            true
        } catch (error: Exception) {
            Log.e(
                TAG,
                "startForegroundService failed kind=$kind error=${error.javaClass.simpleName}:${error.message}",
                error,
            )
            false
        }
    }

    private fun startUsingVisiblePendingOverlay(
        kind: Kind,
        context: Context,
        intent: Intent,
    ): Boolean {
        val existing = synchronized(lock) { pending[kind] } ?: return false
        if (!existing.view.isAttachedToWindow ||
            existing.view.visibility != View.VISIBLE ||
            existing.view.windowVisibility != View.VISIBLE
        ) {
            return false
        }
        Log.d(TAG, "reusing visible pending overlay kind=$kind generation=${existing.generation}")
        return startForegroundService(context, intent, kind)
    }

    private fun removeOnMain(kind: Kind, reason: String) {
        val target = synchronized(lock) { pending.remove(kind) } ?: return
        runCatching { target.removeView(target.context, target.view) }
            .onFailure { Log.e(TAG, "remove failed kind=$kind reason=$reason", it) }
        Log.d(TAG, "overlay removed kind=$kind reason=$reason generation=${target.generation}")
    }

    private fun bindTimerPreview(
        context: Context,
        view: View,
        isBanner: Boolean,
        bannerContents: List<TimerOverlayHelper.TimerOverlayContent>,
        title: String,
        desc: String,
        button: String,
        button2: String?,
    ) {
        if (isBanner) {
            view.findViewById<ImageView>(R.id.fln_timer_banner_logo)
                ?.setImageDrawable(context.applicationInfo.loadIcon(context.packageManager))
            val iconIds =
                intArrayOf(
                    R.id.fln_timer_banner_icon_1,
                    R.id.fln_timer_banner_icon_2,
                    R.id.fln_timer_banner_icon_3,
                    R.id.fln_timer_banner_icon_4,
                )
            val textIds =
                intArrayOf(
                    R.id.fln_timer_banner_text_1,
                    R.id.fln_timer_banner_text_2,
                    R.id.fln_timer_banner_text_3,
                    R.id.fln_timer_banner_text_4,
                )
            bannerContents.take(4).forEachIndexed { index, content ->
                view.findViewById<TextView>(textIds[index])?.text = content.title
                view.findViewById<ImageView>(iconIds[index])?.let { iconView ->
                    val drawableId =
                        context.resources.getIdentifier(content.desc, "drawable", context.packageName)
                    val mipmapId =
                        context.resources.getIdentifier(content.desc, "mipmap", context.packageName)
                    val iconId = drawableId.takeIf { it != 0 } ?: mipmapId.takeIf { it != 0 }
                    if (iconId != null) {
                        iconView.setImageResource(iconId)
                    } else {
                        iconView.setImageDrawable(
                            context.applicationInfo.loadIcon(context.packageManager),
                        )
                    }
                }
            }
            return
        }
        bindTextByName(context, view, "app_name_text", context.applicationInfo.loadLabel(context.packageManager).toString())
        bindTextByName(context, view, "title_text", title)
        bindTextByName(context, view, "desc_text", desc)
        bindTextByName(context, view, "btn_text", button)
        val laterId = context.resources.getIdentifier("later_btn_text", "id", context.packageName)
        if (laterId != 0) {
            view.findViewById<TextView>(laterId)?.apply {
                visibility = if (button2.isNullOrBlank()) View.GONE else View.VISIBLE
                text = button2.orEmpty()
            }
        }
        val logoId = context.resources.getIdentifier("icon_logo", "id", context.packageName)
        if (logoId != 0) {
            view.findViewById<ImageView>(logoId)
                ?.setImageDrawable(context.applicationInfo.loadIcon(context.packageManager))
        }
    }

    private fun bindTextByName(
        context: Context,
        view: View,
        name: String,
        value: String,
    ) {
        val id = context.resources.getIdentifier(name, "id", context.packageName)
        if (id != 0) view.findViewById<TextView>(id)?.text = value
    }

    private fun runOnMain(block: () -> Unit) {
        if (Looper.myLooper() == Looper.getMainLooper()) {
            block()
        } else {
            mainHandler.post(block)
        }
    }

    private fun requiresVisibleOverlayBeforeStart(): Boolean =
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.VANILLA_ICE_CREAM

    private fun dpToPx(context: Context, value: Int): Int =
        (value * context.resources.displayMetrics.density).roundToInt()

    private fun screenWToPx(context: Context, value: Int): Int =
        (value * context.resources.displayMetrics.widthPixels / 375f).roundToInt()

    private fun resolveStatusBarHeight(context: Context): Int {
        val id = context.resources.getIdentifier("status_bar_height", "dimen", "android")
        return if (id == 0) 0 else context.resources.getDimensionPixelSize(id)
    }
}
