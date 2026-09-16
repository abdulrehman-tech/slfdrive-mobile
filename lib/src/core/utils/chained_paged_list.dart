import 'paged_list.dart';

/// One server query in a [ChainedPagedList].
class PageSegment<T> {
  const PageSegment({required this.fetch, this.keep, this.skipIf});

  final PageFetcher<T> fetch;

  /// Client-side row filter, for a segment the API can only approximate.
  final bool Function(T row)? keep;

  /// Checked just before the segment starts, with the server totals of the
  /// segments before it — lets a caller skip a query that can't return
  /// anything new.
  final bool Function(int countSoFar)? skipIf;
}

/// A list built from consecutive server queries — e.g. available cars first,
/// then unavailable ones — for an ordering the API can't sort by. Each
/// segment pages lazily, and the next one starts only once the previous one
/// is exhausted. Mirrors [PagedList]'s surface.
class ChainedPagedList<T> {
  ChainedPagedList({
    required List<PageSegment<T>> Function() segments,
    required Object Function(T) keyOf,
    this.pageSize = 20,
  })  : _build = segments,
        _keyOf = keyOf;

  final List<PageSegment<T>> Function() _build;
  final Object Function(T) _keyOf;
  final int pageSize;

  List<PageSegment<T>> _segments = const [];
  List<PagedList<T>> _lists = const [];
  int _current = 0;
  int _generation = 0;
  bool _stale = true;
  bool _failed = false;
  Future<void>? _first;
  Future<void>? _next;

  /// Rows of every started segment, in segment order, de-duplicated.
  List<T> get items {
    final seen = <Object>{};
    final out = <T>[];
    for (var i = 0; i <= _current && i < _lists.length; i++) {
      final keep = _segments[i].keep;
      for (final row in _lists[i].items) {
        if ((keep == null || keep(row)) && seen.add(_keyOf(row))) out.add(row);
      }
    }
    return out;
  }

  bool get isStale => _stale;
  bool get hasMore =>
      !_stale && _lists.isNotEmpty && (_lists[_current].hasMore || _current < _lists.length - 1);
  bool get isLoadingMore => _next != null;
  bool get loadMoreFailed => _failed;
  bool get canLoadMore => hasMore && !isLoadingMore && !_failed;

  /// Starts over with freshly built segments (the query changed).
  void invalidate() {
    _generation++;
    _segments = _build();
    _lists = [for (final s in _segments) PagedList<T>(fetch: s.fetch, keyOf: _keyOf, pageSize: pageSize)];
    _current = 0;
    _stale = true;
    _failed = false;
    _first = null;
    _next = null;
  }

  /// Loads the first segment's first page, moving on through the next
  /// segments while nothing is visible yet. Errors on the first page
  /// propagate; later ones set [loadMoreFailed].
  Future<void> ensureFirstPage() {
    if (!_stale) return Future.value();
    if (_lists.isEmpty) invalidate();
    return _first ??= _loadFirst(_generation);
  }

  Future<void> loadMore() {
    if (!hasMore) return Future.value();
    _failed = false;
    return _next ??= _advance(_generation);
  }

  Future<void> _loadFirst(int gen) async {
    try {
      await _lists.first.ensureFirstPage();
      if (gen != _generation) return;
      _stale = false;
      while (gen == _generation && items.isEmpty && hasMore && !_failed) {
        await (_next = _advance(gen));
      }
    } finally {
      if (gen == _generation) _first = null;
    }
  }

  Future<void> _advance(int gen) async {
    // Always suspend once: callers store this future in `_next`, and the
    // `finally` below must not run before they have.
    await Future<void>.value();
    try {
      final current = _lists[_current];
      if (current.hasMore) {
        await current.loadMore();
        if (gen == _generation && current.loadMoreFailed) _failed = true;
        return;
      }
      var i = _current + 1;
      while (i < _lists.length && (_segments[i].skipIf?.call(_countBefore(i)) ?? false)) {
        i++;
      }
      if (i >= _lists.length) {
        // Nothing left worth asking for: park on the last (never started,
        // so empty and without more) segment.
        _current = _lists.length - 1;
        return;
      }
      await _lists[i].ensureFirstPage();
      if (gen == _generation) _current = i;
    } catch (_) {
      if (gen == _generation) _failed = true;
    } finally {
      if (gen == _generation) _next = null;
    }
  }

  int _countBefore(int index) {
    var sum = 0;
    for (var i = 0; i < index && i <= _current; i++) {
      if (_segments[i].keep == null) sum += _lists[i].totalCount;
    }
    return sum;
  }
}
