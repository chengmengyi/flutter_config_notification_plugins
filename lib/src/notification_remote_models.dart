/// Android 原生层远程拉取通知配置所需的请求参数。
class NotificationRemoteRequest {
  const NotificationRemoteRequest({
    required this.url,
    required this.headers,
    required this.body,
    required this.mapping,
    this.timeout = const Duration(seconds: 10),
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

  /// 明文字段完整路径到当前项目混淆字段完整路径的映射。
  ///
  /// 数组层级使用单独的 `*` 路径段，例如：
  /// `data.notification.scheduled_notification_arr.*.id`。
  final Map<String, String> mapping;
  final Duration timeout;
  final int maxAttempts;
  final List<Duration> retryDelays;

  Map<String, Object?> toMap() {
    if (url.trim().isEmpty) {
      throw ArgumentError.value(url, 'url', 'must not be empty');
    }
    if (mapping.isEmpty) {
      throw ArgumentError.value(mapping, 'mapping', 'must not be empty');
    }
    for (final entry in mapping.entries) {
      if (entry.key.trim().isEmpty || entry.value.trim().isEmpty) {
        throw ArgumentError.value(
          mapping,
          'mapping',
          'must not contain an empty path',
        );
      }
    }
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
      'mapping': mapping,
      'timeoutMilliseconds': timeout.inMilliseconds,
      'maxAttempts': maxAttempts,
      'retryDelayMilliseconds': retryDelays
          .take(maxAttempts - 1)
          .map((duration) => duration.inMilliseconds)
          .toList(growable: false),
    };
  }
}
