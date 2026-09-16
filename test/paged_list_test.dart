import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:slfdrive/src/core/models/common/paged_response.dart';
import 'package:slfdrive/src/core/utils/paged_list.dart';

/// In-memory `*/paginated` backend over [rows], newest-first like the API.
class FakePager {
  FakePager(this.rows);

  List<int> rows;
  final calls = <int>[];
  final failPages = <int>{};
  final gates = <int, Completer<void>>{};

  Future<PagedResponse<int>> fetch(int page, int size) async {
    calls.add(page);
    final gate = gates[page];
    if (gate != null) await gate.future;
    if (failPages.contains(page)) throw Exception('page $page failed');
    final start = (page - 1) * size;
    final items = rows.skip(start).take(size).toList();
    return PagedResponse(
      items: items,
      totalCount: rows.length,
      pageNumber: page,
      pageSize: size,
      totalPages: (rows.length / size).ceil(),
    );
  }
}

PagedList<int> listOver(FakePager pager, {int pageSize = 10}) =>
    PagedList<int>(fetch: pager.fetch, keyOf: (v) => v, pageSize: pageSize);

void main() {
  group('PagedList', () {
    test('loads the first page, then appends pages until exhausted', () async {
      final pager = FakePager(List.generate(25, (i) => i));
      final list = listOver(pager);

      expect(list.isStale, isTrue);
      await list.ensureFirstPage();
      expect(list.items, List.generate(10, (i) => i));
      expect(list.totalCount, 25);
      expect(list.hasMore, isTrue);

      await list.loadMore();
      await list.loadMore();
      expect(list.items, List.generate(25, (i) => i));
      expect(list.hasMore, isFalse);

      await list.loadMore(); // no-op at the end
      expect(pager.calls, [1, 2, 3]);
    });

    test('concurrent loadMore calls share one request', () async {
      final pager = FakePager(List.generate(30, (i) => i));
      final list = listOver(pager);
      await list.ensureFirstPage();

      await Future.wait([list.loadMore(), list.loadMore(), list.loadMore()]);
      expect(pager.calls, [1, 2]);
      expect(list.items.length, 20);
    });

    test('loadAll pages through everything', () async {
      final pager = FakePager(List.generate(131, (i) => i));
      final list = listOver(pager, pageSize: 20);
      await list.ensureFirstPage();
      await list.loadAll();
      expect(list.items.length, 131);
      expect(list.hasMore, isFalse);
      expect(pager.calls, [1, 2, 3, 4, 5, 6, 7]);
    });

    test('drops duplicate rows when a new row shifts the page offsets', () async {
      final pager = FakePager(List.generate(20, (i) => 100 - i)); // 100..81
      final list = listOver(pager);
      await list.ensureFirstPage();
      // A new row lands at the top: page 2 now starts with the old row 10.
      pager.rows = [101, ...pager.rows];
      await list.loadMore(); // [91..82] — 91 already shown
      await list.loadMore(); // [81]
      expect(list.items, List.generate(20, (i) => 100 - i));
      expect(list.hasMore, isFalse);
    });

    test('a failed page keeps loaded rows and blocks auto paging until retried', () async {
      final pager = FakePager(List.generate(30, (i) => i))..failPages.add(2);
      final list = listOver(pager);
      await list.ensureFirstPage();

      await list.loadMore();
      expect(list.items.length, 10);
      expect(list.loadMoreFailed, isTrue);
      expect(list.canLoadMore, isFalse);

      pager.failPages.clear();
      await list.loadMore(); // explicit retry
      expect(list.loadMoreFailed, isFalse);
      expect(list.items.length, 20);
    });

    test('a failed first page clears stale rows and rethrows', () async {
      final pager = FakePager(List.generate(30, (i) => i));
      final list = listOver(pager);
      await list.ensureFirstPage();

      pager.failPages.add(1);
      list.invalidate();
      await expectLater(list.ensureFirstPage(), throwsException);
      expect(list.items, isEmpty);
      expect(list.hasMore, isFalse);
    });

    test('invalidate drops a page still in flight for the old query', () async {
      final pager = FakePager(List.generate(30, (i) => i));
      final list = listOver(pager);
      await list.ensureFirstPage();

      final gate = pager.gates[2] = Completer<void>();
      final stale = list.loadMore();
      expect(list.isLoadingMore, isTrue);

      list.invalidate();
      pager.rows = List.generate(5, (i) => 500 + i);
      pager.gates.clear();
      await list.ensureFirstPage();
      gate.complete();
      await stale;

      expect(list.items, [500, 501, 502, 503, 504]);
      expect(list.hasMore, isFalse);
      expect(list.isLoadingMore, isFalse);
    });

    test('stops when a page comes back empty despite totalPages', () async {
      final list = PagedList<int>(
        keyOf: (v) => v,
        pageSize: 10,
        fetch: (page, size) async => PagedResponse(
          items: page == 1 ? List.generate(10, (i) => i) : const [],
          totalCount: 50,
          pageNumber: page,
          pageSize: size,
          totalPages: 5,
        ),
      );
      await list.ensureFirstPage();
      await list.loadAll();
      expect(list.items.length, 10);
      expect(list.hasMore, isFalse);
    });
  });

  group('fetchAllPages', () {
    test('drains every page', () async {
      final pager = FakePager(List.generate(131, (i) => i));
      final all = await fetchAllPages(pager.fetch, pageSize: 50);
      expect(all.length, 131);
      expect(pager.calls, [1, 2, 3]);
    });

    test('stops early once `until` is satisfied', () async {
      final pager = FakePager(List.generate(131, (i) => i));
      final all = await fetchAllPages(pager.fetch, pageSize: 50, until: (rows) => rows.contains(60));
      expect(all.length, 100);
      expect(pager.calls, [1, 2]);
    });

    test('propagates errors', () async {
      final pager = FakePager(List.generate(131, (i) => i))..failPages.add(2);
      await expectLater(fetchAllPages(pager.fetch, pageSize: 50), throwsException);
    });
  });
}
