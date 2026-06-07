/// Request body for the backend's `*/paginated` endpoints
/// (`SLF.Domain.CommonDTOs.PaginationParams`). 1-based page numbers.
class PaginationParams {
  final int pageNumber;
  final int pageSize;
  final String? sortBy;
  final String? sortOrder; // 'asc' | 'desc'
  final String? searchFilter;
  final int? userId;

  const PaginationParams({
    this.pageNumber = 1,
    this.pageSize = 10,
    this.sortBy,
    this.sortOrder,
    this.searchFilter,
    this.userId,
  });

  PaginationParams copyWith({
    int? pageNumber,
    int? pageSize,
    String? sortBy,
    String? sortOrder,
    String? searchFilter,
    int? userId,
  }) {
    return PaginationParams(
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      searchFilter: searchFilter ?? this.searchFilter,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      if (sortBy != null && sortBy!.isNotEmpty) 'sortBy': sortBy,
      if (sortOrder != null && sortOrder!.isNotEmpty) 'sortOrder': sortOrder,
      if (searchFilter != null && searchFilter!.isNotEmpty) 'searchFilter': searchFilter,
      if (userId != null) 'userId': userId,
    };
  }
}
