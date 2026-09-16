import 'dart:collection';
import 'dart:math' as math;

import '../models/common/paged_response.dart';

/// Fetches one 1-based page of [pageSize] rows from a `*/paginated` endpoint.
typedef PageFetcher<T> = Future<PagedResponse<T>> Function(int pageNumber, int pageSize);

/// Accumulates pages from a `*/paginated` endpoint for infinite-scroll lists.
///
/// Not a `ChangeNotifier` — the owning provider notifies. [invalidate] bumps a
/// generation counter so any page still in flight for an older query is
/// dropped instead of being appended to the new one. Rows are de-duplicated by
/// [keyOf]: the backend orders newest-first, so a row created between two page
/// requests shifts the offsets and would otherwise appear twice.
class PagedList<T> {
  PagedList({required PageFetcher<T> fetch, required Object Function(T) keyOf, this.pageSize = 20})
    : _fetch = fetch,
      _keyOf = keyOf;

  final PageFetcher<T> _fetch;
  final Object Function(T) _keyOf;
  final int pageSize;

  final List<T> _items = [];
  final Set<Object> _keys = {};
  int _page = 0;
  int _totalPages = 0;
  int _totalCount = 0;
  int _generation = 0;
  bool _stale = true;
  bool _loadMoreFailed = false;
  Future<void>? _firstPage;
  Future<void>? _nextPage;

  /// Rows loaded so far. While [isStale], these belong to the previous query.
  List<T> get items => UnmodifiableListView(_items);

  /// Server-side total for the current query (all pages).
  int get totalCount => _totalCount;

  /// Page 1 hasn't been fetched for the current query yet.
  bool get isStale => _stale;

  bool get hasMore => !_stale && _page < _totalPages;
  bool get isLoadingMore => _nextPage != null;

  /// The last [loadMore] failed. Scroll-triggered paging should hold off until
  /// the user retries, or a broken connection turns into a request loop.
  bool get loadMoreFailed => _loadMoreFailed;

  bool get canLoadMore => hasMore && !isLoadingMore && !_loadMoreFailed;

  /// Marks the contents out of date (query/filter changed). The rows stay
  /// visible until [ensureFirstPage] replaces them.
  void invalidate() {
    _generation++;
    _stale = true;
    _loadMoreFailed = false;
    _firstPage = null;
    _nextPage = null;
  }

  /// Fetches page 1 when [isStale]; concurrent callers share one request.
  /// Errors propagate, and a failed fetch clears the old rows.
  Future<void> ensureFirstPage() {
    if (!_stale) return Future.value();
    return _firstPage ??= _fetchFirst(_generation);
  }

  /// Appends the next page. Concurrent callers share one request; a failure
  /// sets [loadMoreFailed] and keeps the rows already loaded.
  Future<void> loadMore() {
    if (!hasMore) return Future.value();
    _loadMoreFailed = false;
    return _nextPage ??= _fetchPages(_generation, [_page + 1]);
  }

  /// Pages through to the end — for sorts/filters the backend can't apply, which
  /// are only correct over the complete set. Page 1 already gave the total, so
  /// the rest is fetched [parallel] pages at a time. Stops on failure or
  /// [invalidate].
  Future<void> loadAll({int maxPages = 100, int parallel = 6}) async {
    final gen = _generation;
    _loadMoreFailed = false;
    var budget = maxPages;
    while (budget > 0) {
      // Let a page already in flight land first so the offsets are settled.
      final pending = _nextPage;
      if (pending != null) await pending;
      if (gen != _generation || !hasMore || _loadMoreFailed) return;
      final count = math.min(budget, math.min(parallel, _totalPages - _page));
      budget -= count;
      final first = _page + 1;
      await (_nextPage = _fetchPages(gen, [for (var i = 0; i < count; i++) first + i]));
    }
  }

  Future<void> _fetchFirst(int gen) async {
    try {
      final res = await _fetch(1, pageSize);
      if (gen != _generation) return;
      _items.clear();
      _keys.clear();
      _page = 1;
      _apply(res);
      _stale = false;
    } catch (_) {
      if (gen == _generation) {
        _items.clear();
        _keys.clear();
        _page = 0;
        _totalPages = 0;
        _totalCount = 0;
      }
      rethrow;
    } finally {
      if (gen == _generation) _firstPage = null;
    }
  }

  /// Fetches consecutive [pages] together and appends them in order.
  Future<void> _fetchPages(int gen, List<int> pages) async {
    try {
      final results = await Future.wait([for (final p in pages) _fetch(p, pageSize)]);
      if (gen != _generation) return;
      for (var i = 0; i < pages.length && (i == 0 || hasMore); i++) {
        _page = pages[i];
        _apply(results[i]);
      }
    } catch (_) {
      if (gen == _generation) _loadMoreFailed = true;
    } finally {
      if (gen == _generation) _nextPage = null;
    }
  }

  void _apply(PagedResponse<T> res) {
    for (final row in res.items) {
      if (_keys.add(_keyOf(row))) _items.add(row);
    }
    _totalCount = res.totalCount;
    // An empty page means the end, whatever totalPages claims — never loop.
    _totalPages = res.items.isEmpty ? _page : res.totalPages;
  }
}

/// Drains every page of a `*/paginated` endpoint — for pickers and lookups that
/// need the complete set rather than an infinite-scroll list. [until] stops
/// early once the rows fetched so far contain what the caller needs.
Future<List<T>> fetchAllPages<T>(
  PageFetcher<T> fetch, {
  int pageSize = 100,
  int maxPages = 50,
  bool Function(List<T> soFar)? until,
}) async {
  final all = <T>[];
  for (var page = 1; page <= maxPages; page++) {
    final res = await fetch(page, pageSize);
    all.addAll(res.items);
    if (res.items.isEmpty || page >= res.totalPages) break;
    if (until != null && until(all)) break;
  }
  return all;
}
