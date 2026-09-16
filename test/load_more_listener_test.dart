import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slfdrive/src/presentation/widgets/load_more.dart';

/// Minimal paged source: [total] rows, [pageSize] per load, optionally
/// filtering rows out so a loaded page can add nothing visible.
class _Source extends ChangeNotifier {
  _Source({required this.total, this.pageSize = 5, this.visible});

  final int total;
  final int pageSize;
  final bool Function(int)? visible;
  int loaded = 0;
  int calls = 0;

  bool get hasMore => loaded < total;
  List<int> get rows => [
    for (var i = 0; i < loaded; i++)
      if (visible?.call(i) ?? true) i,
  ];

  void loadMore() {
    if (!hasMore) return;
    calls++;
    loaded = (loaded + pageSize).clamp(0, total);
    notifyListeners();
  }
}

Widget _harness(_Source source, {double rowHeight = 50}) {
  return MaterialApp(
    home: ListenableBuilder(
      listenable: source,
      builder: (context, _) => LoadMoreListener(
        enabled: source.hasMore,
        onLoadMore: source.loadMore,
        threshold: 100,
        child: ListView(
          children: [for (final r in source.rows) SizedBox(height: rowHeight, child: Text('row $r'))],
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('keeps paging while the content is too short to scroll', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final source = _Source(total: 40)..loadMore(); // 5 rows = 250px < 800px
    await tester.pumpWidget(_harness(source));
    await tester.pumpAndSettle();

    // Fills past the viewport (+threshold), then stops without any scrolling.
    expect(source.loaded, greaterThanOrEqualTo(20));
    expect(source.loaded, lessThan(40));
  });

  testWidgets('keeps paging when a loaded page adds nothing visible', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // Only rows >= 30 are visible: the first 6 pages show nothing at all.
    final source = _Source(total: 60, visible: (i) => i >= 30)..loadMore();
    await tester.pumpWidget(_harness(source));
    await tester.pumpAndSettle();

    expect(source.rows, isNotEmpty);
    expect(source.loaded, greaterThan(30));
  });

  testWidgets('loads the next page when scrolled near the end', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final source = _Source(total: 100, pageSize: 40)..loadMore(); // 2000px
    await tester.pumpWidget(_harness(source));
    await tester.pumpAndSettle();
    expect(source.calls, 1);

    await tester.drag(find.byType(ListView), const Offset(0, -1150));
    await tester.pumpAndSettle();
    expect(source.calls, 2);
    expect(source.loaded, 80);
  });

  testWidgets('does nothing while disabled', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: LoadMoreListener(
          enabled: false,
          onLoadMore: () => calls++,
          child: ListView(children: const [SizedBox(height: 10)]),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(calls, 0);
  });
}
