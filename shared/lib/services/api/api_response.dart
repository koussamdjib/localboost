/// Generic API response wrapper
///
/// Wraps successful responses with typed data and metadata.
class ApiResponse<T> {
  final T data;
  final int statusCode;
  final String? message;
  final Map<String, dynamic>? meta;

  ApiResponse({
    required this.data,
    required this.statusCode,
    this.message,
    this.meta,
  });

  /// Check if response indicates success (2xx status code)
  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  /// Factory constructor from JSON
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) dataParser,
  ) {
    return ApiResponse(
      data: dataParser(json['data']),
      statusCode: json['status_code'] ?? 200,
      message: json['message'],
      meta: json['meta'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson(dynamic Function(T) dataSerializer) {
    return {
      'data': dataSerializer(data),
      'status_code': statusCode,
      if (message != null) 'message': message,
      if (meta != null) 'meta': meta,
    };
  }
}

/// Paginated response wrapper
class PaginatedResponse<T> extends ApiResponse<List<T>> {
  final int total;
  final int page;
  final int pageSize;
  final bool hasNext;
  final bool hasPrevious;

  PaginatedResponse({
    required super.data,
    required super.statusCode,
    required this.total,
    required this.page,
    required this.pageSize,
    super.message,
    super.meta,
  })  : hasNext = (page * pageSize) < total,
        hasPrevious = page > 1;

  /// Total number of pages
  int get totalPages => (total / pageSize).ceil();

  /// Factory constructor from JSON
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    List<T> Function(dynamic) dataParser,
  ) {
    return PaginatedResponse(
      data: dataParser(json['results'] ?? json['data']),
      statusCode: json['status_code'] ?? 200,
      total: json['count'] ?? json['total'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['page_size'] ?? json['limit'] ?? 20,
      message: json['message'],
      meta: json['meta'],
    );
  }
}

/// Empty response for DELETE and other operations without body
class EmptyResponse extends ApiResponse<void> {
  EmptyResponse({required super.statusCode, super.message})
      : super(data: null);
}
