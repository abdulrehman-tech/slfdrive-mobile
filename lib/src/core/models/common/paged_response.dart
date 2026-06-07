/// A single page of results returned inside `ApiResponse.data` by the backend's
/// `*/paginated` endpoints (`SLF.Domain.CommonDTOs.PagedResponse<T>`).
class PagedResponse<T> {
  final List<T> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;

  const PagedResponse({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
  });

  bool get hasMore => pageNumber < totalPages;

  factory PagedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemFromJson,
  ) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems.whereType<Map<String, dynamic>>().map(itemFromJson).toList()
        : <T>[];
    return PagedResponse<T>(
      items: items,
      totalCount: (json['totalCount'] as num?)?.toInt() ?? items.length,
      pageNumber: (json['pageNumber'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? items.length,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }

  static PagedResponse<T> empty<T>() =>
      PagedResponse<T>(items: const [], totalCount: 0, pageNumber: 1, pageSize: 0, totalPages: 0);
}
