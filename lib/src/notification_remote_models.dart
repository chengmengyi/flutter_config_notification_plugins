import 'dart:convert';

/// Android 原生层远程拉取通知配置所需的请求参数。
class NotificationRemoteRequest {
  const NotificationRemoteRequest({
    required this.url,
    required this.headers,
    required this.body,
    required this.mapping,
    this.timeout = const Duration(seconds: 40),
    this.maxAttempts = 4,
    this.retryDelays = const <Duration>[
      Duration(seconds: 2),
      Duration(seconds: 6),
      Duration(seconds: 18),
    ],
  });

  final String url;
  final Map<String, dynamic> headers;
  final Map<String, dynamic> body;

  /// JSON 字符串格式的“明文字段完整路径 → 混淆字段完整路径”映射。
  ///
  /// 数组层级使用单独的 `*` 路径段，例如：
  /// `data.notification.scheduled_notification_arr.*.id`。
  final String mapping;
  final Duration timeout;
  final int maxAttempts;
  final List<Duration> retryDelays;

  Map<String, Object?> toMap() {
    if (url.trim().isEmpty) {
      throw ArgumentError.value(url, 'url', 'must not be empty');
    }
    if (mapping.trim().isEmpty) {
      throw ArgumentError.value(mapping, 'mapping', 'must not be empty');
    }
    final decodedMapping = _decodeMapping();
    if (timeout <= Duration.zero) {
      throw ArgumentError.value(timeout, 'timeout', 'must be positive');
    }
    if (maxAttempts <= 0 || maxAttempts > 4) {
      throw ArgumentError.value(maxAttempts, 'maxAttempts', 'must be 1 to 4');
    }
    if (retryDelays.length < maxAttempts - 1 ||
        retryDelays
            .take(maxAttempts - 1)
            .any((duration) => duration.isNegative)) {
      throw ArgumentError('retryDelays must cover every retry attempt');
    }
    return <String, Object?>{
      'url': url,
      'headers': headers,
      'body': body,
      'mapping': decodedMapping,
      'timeoutMilliseconds': timeout.inMilliseconds,
      'maxAttempts': maxAttempts,
      'retryDelayMilliseconds': retryDelays
          .take(maxAttempts - 1)
          .map((duration) => duration.inMilliseconds)
          .toList(growable: false),
    };
  }

  Map<String, String> _decodeMapping() {
    late final Object? decoded;
    try {
      decoded = jsonDecode(mapping);
    } on FormatException catch (error) {
      throw ArgumentError.value(
        mapping,
        'mapping',
        'must be valid JSON: ${error.message}',
      );
    }
    if (decoded is! Map) {
      throw ArgumentError.value(mapping, 'mapping', 'must be a JSON object');
    }

    final result = <String, String>{};
    for (final entry in decoded.entries) {
      if (entry.key is! String || entry.value is! String) {
        throw ArgumentError.value(
          mapping,
          'mapping',
          'all keys and values must be strings',
        );
      }
      final key = (entry.key as String).trim();
      final value = (entry.value as String).trim();
      if (key.isEmpty || value.isEmpty) {
        throw ArgumentError.value(
          mapping,
          'mapping',
          'must not contain an empty path',
        );
      }
      result[key] = value;
    }
    if (result.isEmpty) {
      throw ArgumentError.value(mapping, 'mapping', 'must not be empty');
    }
    return result;
  }
}

/// 主动更新远程通知配置后的结果。
enum NotificationConfigUpdateResult {
  /// 新配置已保存并启用通知功能。
  enabled,

  /// 新配置已保存，但远端关闭了通知功能。
  disabled,

  /// 请求、解密、校验、保存或应用配置失败，旧配置保持不变。
  failed;

  static NotificationConfigUpdateResult fromChannelValue(String? value) {
    return switch (value) {
      'enabled' => NotificationConfigUpdateResult.enabled,
      'disabled' => NotificationConfigUpdateResult.disabled,
      _ => NotificationConfigUpdateResult.failed,
    };
  }
}
