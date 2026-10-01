import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slfdrive/src/presentation/widgets/exit_confirm_scope.dart';

// No translations are loaded here, so `.tr()` renders the keys.
Widget _app(Widget home) => ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, _) => MaterialApp(home: home),
    );

void main() {
  late List<MethodCall> platformCalls;

  setUp(() {
    platformCalls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        platformCalls.add(call);
        return null;
      },
    );
  });

  bool exited() => platformCalls.any((c) => c.method == 'SystemNavigator.pop');

  testWidgets('back at the root asks first; Stay keeps the app open', (tester) async {
    await tester.pumpWidget(_app(const ExitConfirmScope(child: Scaffold(body: Text('home')))));

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('exit_app_title'), findsOneWidget);
    expect(exited(), isFalse);

    await tester.tap(find.text('exit_app_stay'));
    await tester.pumpAndSettle();
    expect(find.text('exit_app_title'), findsNothing);
    expect(find.text('home'), findsOneWidget);
    expect(exited(), isFalse);
  });

  testWidgets('confirming closes the app', (tester) async {
    await tester.pumpWidget(_app(const ExitConfirmScope(child: Scaffold(body: Text('home')))));

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.text('exit_app_confirm'));
    await tester.pumpAndSettle();
    expect(exited(), isTrue);
  });

  testWidgets('back closes an open drawer instead of asking', (tester) async {
    final scaffold = GlobalKey<ScaffoldState>();
    await tester.pumpWidget(
      _app(ExitConfirmScope(
        child: Scaffold(key: scaffold, drawer: const Drawer(child: Text('drawer')), body: const Text('home')),
      )),
    );
    scaffold.currentState!.openDrawer();
    await tester.pumpAndSettle();
    expect(find.text('drawer'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('drawer'), findsNothing);
    expect(find.text('exit_app_title'), findsNothing);
  });

  testWidgets('a pushed copy pops normally', (tester) async {
    final nav = GlobalKey<NavigatorState>();
    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, _) => MaterialApp(navigatorKey: nav, home: const Scaffold(body: Text('below'))),
    ));
    nav.currentState!.push(
      MaterialPageRoute<void>(builder: (_) => const ExitConfirmScope(child: Scaffold(body: Text('auth')))),
    );
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('below'), findsOneWidget);
    expect(find.text('exit_app_title'), findsNothing);
    expect(exited(), isFalse);
  });
}
