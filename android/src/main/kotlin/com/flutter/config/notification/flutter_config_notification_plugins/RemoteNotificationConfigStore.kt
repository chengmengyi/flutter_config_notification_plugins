package com.flutter.config.notification.flutter_config_notification_plugins

import android.content.Context
import android.content.pm.ApplicationInfo
import android.os.Build
import android.util.Log
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import java.io.IOException
import java.net.HttpURLConnection
import java.net.URL

internal data class RemoteNotificationRequest(
    val url: String,
    val headers: Map<String, String>,
    val body: JSONObject,
    val paths: Map<String, String>,
    val timeoutMilliseconds: Int,
    val maxAttempts: Int,
    val retryDelayMilliseconds: List<Long>,
) {
    companion object {
        fun fromMap(values: Map<*, *>): RemoteNotificationRequest {
            val url = values["url"]?.toString()?.trim().orEmpty()
            require(url.isNotEmpty()) { "remoteRequest.url is required" }
            require(URL(url).protocol.equals("https", ignoreCase = true)) {
                "remoteRequest.url must use HTTPS"
            }

            val headers =
                (values["headers"] as? Map<*, *>)
                    ?.entries
                    ?.associate { entry ->
                        val key = entry.key?.toString()?.trim().orEmpty()
                        require(key.isNotEmpty()) { "remoteRequest.headers contains an empty key" }
                        key to entry.value?.toString().orEmpty()
                    }.orEmpty()
            val body = mapToJson(values["body"] as? Map<*, *> ?: emptyMap<Any, Any>())
            val mapping = values["mapping"] as? Map<*, *> ?: error("remoteRequest.mapping is required")
            val paths = parseMapping(mapping)
            require(paths.containsKey("code")) { "mapping.code is required" }
            require(paths.containsKey("data.notification")) { "mapping.notification is required" }

            val timeoutMilliseconds =
                (values["timeoutMilliseconds"] as? Number)?.toInt() ?: DEFAULT_TIMEOUT_MILLIS
            require(timeoutMilliseconds > 0) { "timeoutMilliseconds must be > 0" }
            val maxAttempts = (values["maxAttempts"] as? Number)?.toInt() ?: DEFAULT_MAX_ATTEMPTS
            require(maxAttempts in 1..MAX_ATTEMPTS) { "maxAttempts must be between 1 and $MAX_ATTEMPTS" }
            val retryDelays =
                (values["retryDelayMilliseconds"] as? List<*>)
                    ?.map { (it as? Number)?.toLong() ?: error("retry delay must be a number") }
                    .orEmpty()
            require(retryDelays.size >= maxAttempts - 1) {
                "retryDelayMilliseconds must cover every retry attempt"
            }
            require(retryDelays.all { it >= 0L }) { "retry delays must not be negative" }

            return RemoteNotificationRequest(
                url = url,
                headers = headers,
                body = body,
                paths = paths,
                timeoutMilliseconds = timeoutMilliseconds,
                maxAttempts = maxAttempts,
                retryDelayMilliseconds = retryDelays,
            )
        }

        private fun parseMapping(mapping: Map<*, *>): Map<String, String> {
            require(mapping.isNotEmpty()) { "remoteRequest.mapping must not be empty" }

            val fullPaths = linkedMapOf<String, List<String>>()
            val canonicalPathByObfuscatedPath = linkedMapOf<String, String>()
            mapping.entries.forEach { entry ->
                val canonicalPath = entry.key?.toString()?.trim().orEmpty()
                val obfuscatedPath = entry.value?.toString()?.trim().orEmpty()
                require(canonicalPath.isNotEmpty() && obfuscatedPath.isNotEmpty()) {
                    "remoteRequest.mapping contains an empty path"
                }

                val canonicalSegments = splitAndValidatePath(canonicalPath, "mapping key")
                val obfuscatedSegments = splitAndValidatePath(obfuscatedPath, "mapping value")
                require(canonicalSegments.size == obfuscatedSegments.size) {
                    "mapping paths must have the same depth: $canonicalPath -> $obfuscatedPath"
                }
                canonicalSegments.indices.forEach { index ->
                    require((canonicalSegments[index] == "*") == (obfuscatedSegments[index] == "*")) {
                        "mapping array markers must be aligned: $canonicalPath -> $obfuscatedPath"
                    }
                }

                val previousCanonicalPath =
                    canonicalPathByObfuscatedPath.put(obfuscatedPath, canonicalPath)
                require(previousCanonicalPath == null) {
                    "mapping paths must be one-to-one: $previousCanonicalPath and $canonicalPath"
                }
                fullPaths[canonicalPath] = obfuscatedSegments
            }

            fullPaths.forEach { (canonicalPath, obfuscatedSegments) ->
                val canonicalSegments = canonicalPath.split('.')
                for (length in 1 until canonicalSegments.size) {
                    if (canonicalSegments[length - 1] == "*") continue
                    val canonicalParent = canonicalSegments.take(length).joinToString(".")
                    val mappedParent =
                        fullPaths[canonicalParent]
                            ?: error("mapping parent path is missing: $canonicalParent")
                    require(mappedParent == obfuscatedSegments.take(length)) {
                        "mapping parent path is inconsistent: $canonicalPath"
                    }
                }
            }

            val arrayContainerPaths =
                fullPaths.keys
                    .flatMap { canonicalPath ->
                        val segments = canonicalPath.split('.')
                        segments.indices.mapNotNull { index ->
                            if (segments[index] == "*") {
                                segments.take(index).joinToString(".")
                            } else {
                                null
                            }
                        }
                    }.toSet()
            val result = linkedMapOf<String, String>()
            fullPaths.forEach { (canonicalPath, obfuscatedSegments) ->
                val normalizedPath =
                    normalizeCanonicalPath(
                        segments = canonicalPath.split('.'),
                        arrayContainerPaths = arrayContainerPaths,
                    )
                require(result.put(normalizedPath, obfuscatedSegments.last()) == null) {
                    "duplicate mapping path: $canonicalPath"
                }
            }
            return result
        }

        private fun splitAndValidatePath(
            path: String,
            label: String,
        ): List<String> {
            val segments = path.split('.')
            require(segments.none { it.isEmpty() }) { "$label contains an empty segment: $path" }
            require(segments.last() != "*") { "$label must not end with an array marker: $path" }
            segments.forEachIndexed { index, segment ->
                if (segment == "*") {
                    require(index > 0 && segments[index - 1] != "*") {
                        "$label contains an invalid array marker: $path"
                    }
                } else {
                    require(!segment.contains('*')) {
                        "$label must use * as a standalone segment: $path"
                    }
                }
            }
            return segments
        }

        private fun normalizeCanonicalPath(
            segments: List<String>,
            arrayContainerPaths: Set<String>,
        ): String {
            val normalized = mutableListOf<String>()
            val sourcePrefix = mutableListOf<String>()
            segments.forEach { segment ->
                sourcePrefix += segment
                if (segment == "*") return@forEach
                val isArray = sourcePrefix.joinToString(".") in arrayContainerPaths
                normalized += if (isArray) "$segment[]" else segment
            }
            return normalized.joinToString(".")
        }

        private const val DEFAULT_TIMEOUT_MILLIS = 10_000
        private const val DEFAULT_MAX_ATTEMPTS = 4
        private const val MAX_ATTEMPTS = 4
    }
}

internal data class DecodedRemoteNotificationConfig(
    val response: JSONObject,
    val notification: JSONObject,
)

internal object RemoteNotificationConfigStore {
    private const val TAG = "RemoteNotificationConfig"
    private const val PREFS_NAME = "flutter_config_notification_plugins"
    private const val KEY_RESPONSE = "remote_notification_response_v1"
    private const val KEY_NOTIFICATION = "remote_notification_config_v1"
    private const val KEY_FETCHED_AT = "remote_notification_fetched_at"
    private val sensitiveHeaderPattern =
        Regex("authorization|token|cookie|secret|api[-_]?key|signature", RegexOption.IGNORE_CASE)

    fun fetchDecodeAndSave(
        context: Context,
        request: RemoteNotificationRequest,
    ): DecodedRemoteNotificationConfig? {
        val debug = isDebuggable(context)
        for (attempt in 1..request.maxAttempts) {
            if (debug) {
                logDebug("request start attempt=$attempt/${request.maxAttempts} url=${request.url}")
                logJson("request headers", sanitizedHeaders(request.headers))
                logJson("request body", request.body)
            }
            val response = executeRequest(request)
            if (debug) {
                logDebug("response httpStatus=${response.statusCode}")
                logJsonText("obfuscated response", response.body)
            }

            if (response.statusCode in 200..299) {
                val decoded =
                    runCatching { decode(request, response.body) }
                        .onFailure { error ->
                            if (debug) logDebug("decode failed: ${error.message}")
                        }.getOrNull()
                if (decoded != null) {
                    if (debug) logJson("decoded response", decoded.response)
                    if (save(context, decoded)) {
                        if (debug) logDebug("request completed and configuration saved")
                        return decoded
                    }
                    if (debug) logDebug("configuration save failed")
                    return null
                }
                return null
            }

            val shouldRetry = response.statusCode <= 0 || response.statusCode >= 500
            if (!shouldRetry || attempt >= request.maxAttempts) return null
            val delayMillis = request.retryDelayMilliseconds[attempt - 1]
            if (debug) logDebug("request retry scheduled after ${delayMillis}ms")
            try {
                Thread.sleep(delayMillis)
            } catch (_: InterruptedException) {
                Thread.currentThread().interrupt()
                return null
            }
        }
        return null
    }

    fun readNotification(context: Context): JSONObject? {
        val appContext = context.applicationContext
        val raw =
            appContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .getString(KEY_NOTIFICATION, null)
                ?: if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    appContext.createDeviceProtectedStorageContext()
                        .getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                        .getString(KEY_NOTIFICATION, null)
                } else {
                    null
                }
                ?: return null
        return runCatching { JSONObject(raw) }.getOrNull()
    }

    private fun executeRequest(request: RemoteNotificationRequest): HttpResponse {
        var connection: HttpURLConnection? = null
        return try {
            connection = URL(request.url).openConnection() as HttpURLConnection
            connection.requestMethod = "POST"
            connection.connectTimeout = request.timeoutMilliseconds
            connection.readTimeout = request.timeoutMilliseconds
            connection.doInput = true
            connection.doOutput = true
            connection.useCaches = false
            if (request.headers.keys.none { it.equals("Content-Type", ignoreCase = true) }) {
                connection.setRequestProperty("Content-Type", "application/json")
            }
            request.headers.forEach(connection::setRequestProperty)
            connection.outputStream.bufferedWriter(Charsets.UTF_8).use { writer ->
                writer.write(request.body.toString())
            }
            val statusCode = connection.responseCode
            val stream = if (statusCode in 200..399) connection.inputStream else connection.errorStream
            HttpResponse(statusCode, stream?.bufferedReader(Charsets.UTF_8)?.use { it.readText() }.orEmpty())
        } catch (error: IOException) {
            HttpResponse(-1, JSONObject().put("network_error", error.message.orEmpty()).toString())
        } finally {
            connection?.disconnect()
        }
    }

    internal fun decode(
        request: RemoteNotificationRequest,
        rawBody: String,
    ): DecodedRemoteNotificationConfig {
        val source = JSONObject(rawBody)
        val root = MappingNode(canonicalName = "", isArray = false)
        request.paths.forEach { (canonicalPath, obfuscatedKey) ->
            insertMapping(root, canonicalPath, obfuscatedKey)
        }
        val decoded = decodeObject(source, root)
        require(decoded.optInt("code", -1) == 200) { "business code is not 200" }
        val data = decoded.optJSONObject("data") ?: error("decoded data object is missing")
        val notification = data.optJSONObject("notification") ?: error("decoded notification object is missing")
        validateNotification(notification)
        return DecodedRemoteNotificationConfig(
            response = decoded,
            notification = notification,
        )
    }

    private fun save(
        context: Context,
        config: DecodedRemoteNotificationConfig,
    ): Boolean {
        val appContext = context.applicationContext
        val saved =
            appContext
            .getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(KEY_RESPONSE, config.response.toString())
            .putString(KEY_NOTIFICATION, config.notification.toString())
            .putLong(KEY_FETCHED_AT, System.currentTimeMillis())
            .commit()
        val directBootSaved =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                appContext.createDeviceProtectedStorageContext()
                    .getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                    .edit()
                    .putString(KEY_NOTIFICATION, config.notification.toString())
                    .putLong(KEY_FETCHED_AT, System.currentTimeMillis())
                    .commit()
            } else {
                true
            }
        return saved && directBootSaved
    }

    private fun validateNotification(notification: JSONObject) {
        listOf(
            "enabled",
            "scheduled_enabled",
            "broadcast_enabled",
            "media_enabled",
            "persistent_enabled",
            "floating_window_enabled",
        ).forEach { key ->
            require(notification.has(key) && notification.opt(key) is Boolean) { "$key must be a boolean" }
        }
        requireNonNegativeInt(notification, "first_send_delay_minutes")
        requirePositiveInt(notification, "notification_interval_minutes")
        requirePositiveInt(notification, "notification_total_limit")
    }

    private fun requireNonNegativeInt(
        json: JSONObject,
        key: String,
    ) {
        val value = json.opt(key) as? Number ?: error("$key must be an integer")
        require(value.toDouble() == value.toInt().toDouble() && value.toInt() >= 0) {
            "$key must be a non-negative integer"
        }
    }

    private fun requirePositiveInt(
        json: JSONObject,
        key: String,
    ) {
        val value = json.opt(key) as? Number ?: error("$key must be an integer")
        require(value.toDouble() == value.toInt().toDouble() && value.toInt() > 0) {
            "$key must be a positive integer"
        }
    }

    private fun insertMapping(
        root: MappingNode,
        path: String,
        obfuscatedKey: String,
    ) {
        var current = root
        path.split('.').forEach { rawSegment ->
            val isArray = rawSegment.endsWith("[]")
            val name = rawSegment.removeSuffix("[]")
            current =
                current.children.getOrPut(name) {
                    MappingNode(canonicalName = name, isArray = isArray)
                }
            require(current.isArray == isArray) { "mapping path type conflict at $path" }
        }
        current.obfuscatedKey = obfuscatedKey
    }

    private fun decodeObject(
        source: JSONObject,
        parent: MappingNode,
    ): JSONObject {
        val output = JSONObject()
        val nodesBySourceKey =
            parent.children.values.associateBy { node ->
                node.obfuscatedKey ?: error("missing mapping for ${node.canonicalName}")
            }
        val sourceKeys = source.keys()
        while (sourceKeys.hasNext()) {
            val sourceKey = sourceKeys.next()
            val node = nodesBySourceKey[sourceKey] ?: continue
            val value = source.opt(sourceKey)
            output.put(node.canonicalName, decodeValue(value, node))
        }
        return output
    }

    private fun decodeValue(
        value: Any?,
        node: MappingNode,
    ): Any {
        if (value == null || value === JSONObject.NULL) return JSONObject.NULL
        if (node.isArray) {
            val sourceArray = value as? JSONArray ?: error("${node.canonicalName} must be an array")
            val output = JSONArray()
            for (index in 0 until sourceArray.length()) {
                val item = sourceArray.opt(index)
                output.put(
                    if (node.children.isEmpty()) {
                        item
                    } else {
                        decodeObject(item as? JSONObject ?: error("${node.canonicalName} item must be an object"), node)
                    },
                )
            }
            return output
        }
        if (node.children.isNotEmpty()) {
            return decodeObject(value as? JSONObject ?: error("${node.canonicalName} must be an object"), node)
        }
        return value
    }

    private fun sanitizedHeaders(headers: Map<String, String>): JSONObject {
        val json = JSONObject()
        headers.forEach { (key, value) ->
            json.put(key, if (sensitiveHeaderPattern.containsMatchIn(key)) "***" else value)
        }
        return json
    }

    private fun logJsonText(
        label: String,
        raw: String,
    ) {
        val pretty =
            runCatching { JSONObject(raw).toString(2) }
                .recoverCatching { JSONArray(raw).toString(2) }
                .getOrDefault(raw)
        logMultiline("$label:\n$pretty")
    }

    private fun logJson(
        label: String,
        json: JSONObject,
    ) {
        logMultiline("$label:\n${json.toString(2)}")
    }

    private fun logDebug(message: String) {
        logMultiline(message)
    }

    private fun logMultiline(message: String) {
        message.lineSequence().forEach { line ->
            if (line.length <= LOG_CHUNK_SIZE) {
                Log.d(TAG, line)
            } else {
                line.chunked(LOG_CHUNK_SIZE).forEach { chunk -> Log.d(TAG, chunk) }
            }
        }
    }

    private fun isDebuggable(context: Context): Boolean =
        context.applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE != 0

    private data class HttpResponse(
        val statusCode: Int,
        val body: String,
    )

    private data class MappingNode(
        val canonicalName: String,
        val isArray: Boolean,
        var obfuscatedKey: String? = null,
        val children: LinkedHashMap<String, MappingNode> = linkedMapOf(),
    )

    private const val LOG_CHUNK_SIZE = 3_500
}

private fun mapToJson(values: Map<*, *>): JSONObject {
    val json = JSONObject()
    values.forEach { (key, value) ->
        json.put(key?.toString() ?: return@forEach, toJsonValue(value))
    }
    return json
}

private fun toJsonValue(value: Any?): Any =
    when (value) {
        null -> JSONObject.NULL
        is Map<*, *> -> mapToJson(value)
        is Iterable<*> -> JSONArray().apply { value.forEach { put(toJsonValue(it)) } }
        is Array<*> -> JSONArray().apply { value.forEach { put(toJsonValue(it)) } }
        else -> value
    }
