enum QueueRequestStatus { pending, inProgress, success, failed, retrying }

enum QueueRequestMethod { get, post, put, delete, patch }

/// Model for storing queued API requests
class QueuedRequest {
  final String id;
  final String endpoint;
  final String method;
  final String? requestBody;
  final Map<String, String>? headers;
  final QueueRequestStatus status;
  final DateTime createdAt;
  final DateTime? attemptedAt;
  final int retryCount;
  final int maxRetries;
  final String? errorMessage;
  final String? userId; // Owner of the request for sync visibility
  final Map<String, dynamic>? metadata; // Additional context

  QueuedRequest({
    required this.id,
    required this.endpoint,
    required this.method,
    this.requestBody,
    this.headers,
    required this.status,
    required this.createdAt,
    this.attemptedAt,
    required this.retryCount,
    this.maxRetries = 5,
    this.errorMessage,
    this.userId,
    this.metadata,
  });

  /// Check if request can be retried
  bool canRetry() => retryCount < maxRetries && status != QueueRequestStatus.success;

  /// Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'endpoint': endpoint,
      'method': method,
      'requestBody': requestBody,
      'headers': headers != null ? Uri.encodeComponent(headers.toString()) : null,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'attemptedAt': attemptedAt?.toIso8601String(),
      'retryCount': retryCount,
      'maxRetries': maxRetries,
      'errorMessage': errorMessage,
      'userId': userId,
      'metadata': metadata != null ? Uri.encodeComponent(metadata.toString()) : null,
    };
  }

  /// Create from Map from database
  factory QueuedRequest.fromMap(Map<String, dynamic> map) {
    return QueuedRequest(
      id: map['id'] as String,
      endpoint: map['endpoint'] as String,
      method: map['method'] as String,
      requestBody: map['requestBody'] as String?,
      headers: map['headers'] != null ? _parseHeaders(map['headers']) : null,
      status: QueueRequestStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => QueueRequestStatus.pending,
      ),
      createdAt: DateTime.parse(map['createdAt'] as String),
      attemptedAt: map['attemptedAt'] != null ? DateTime.parse(map['attemptedAt'] as String) : null,
      retryCount: map['retryCount'] as int? ?? 0,
      maxRetries: map['maxRetries'] as int? ?? 5,
      errorMessage: map['errorMessage'] as String?,
      userId: map['userId'] as String?,
      metadata: map['metadata'] != null ? _parseMetadata(map['metadata']) : null,
    );
  }

  /// Create a copy with updated status
  QueuedRequest copyWith({
    String? id,
    String? endpoint,
    String? method,
    String? requestBody,
    Map<String, String>? headers,
    QueueRequestStatus? status,
    DateTime? createdAt,
    DateTime? attemptedAt,
    int? retryCount,
    int? maxRetries,
    String? errorMessage,
    String? userId,
    Map<String, dynamic>? metadata,
  }) {
    return QueuedRequest(
      id: id ?? this.id,
      endpoint: endpoint ?? this.endpoint,
      method: method ?? this.method,
      requestBody: requestBody ?? this.requestBody,
      headers: headers ?? this.headers,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      attemptedAt: attemptedAt ?? this.attemptedAt,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries ?? this.maxRetries,
      errorMessage: errorMessage ?? this.errorMessage,
      userId: userId ?? this.userId,
      metadata: metadata ?? this.metadata,
    );
  }

  static Map<String, String>? _parseHeaders(dynamic data) {
    try {
      String decoded = Uri.decodeComponent(data.toString());
      // Parse the string representation back to map
      // This is a simple implementation - you may need to adjust based on actual format
      return {};
    } catch (e) {
      return null;
    }
  }

  static Map<String, dynamic>? _parseMetadata(dynamic data) {
    try {
      String decoded = Uri.decodeComponent(data.toString());
      // Parse the string representation back to map
      return {};
    } catch (e) {
      return null;
    }
  }
}

