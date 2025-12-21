/// Model for storing API responses in local cache
class CachedResponse {
  final String id;
  final String endpoint;
  final String? responseData;
  final int statusCode;
  final DateTime cachedAt;
  final DateTime? expiresAt;
  final String requestMethod; // GET, POST, PUT, DELETE

  CachedResponse({
    required this.id,
    required this.endpoint,
    this.responseData,
    required this.statusCode,
    required this.cachedAt,
    this.expiresAt,
    required this.requestMethod,
  });

  /// Check if cache is still valid
  bool isValid() {
    if (expiresAt == null) return true;
    return DateTime.now().isBefore(expiresAt!);
  }

  /// Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'endpoint': endpoint,
      'responseData': responseData,
      'statusCode': statusCode,
      'cachedAt': cachedAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'requestMethod': requestMethod,
    };
  }

  /// Create from Map from database
  factory CachedResponse.fromMap(Map<String, dynamic> map) {
    return CachedResponse(
      id: map['id'] as String,
      endpoint: map['endpoint'] as String,
      responseData: map['responseData'] as String?,
      statusCode: map['statusCode'] as int,
      cachedAt: DateTime.parse(map['cachedAt'] as String),
      expiresAt: map['expiresAt'] != null ? DateTime.parse(map['expiresAt'] as String) : null,
      requestMethod: map['requestMethod'] as String,
    );
  }
}

