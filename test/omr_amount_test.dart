import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slfdrive/src/presentation/widgets/omr_icon.dart';

void main() {
  for (final dir in TextDirection.values) {
    testWidgets('symbol stands on the digits baseline ($dir)', (tester) async {
      const style = TextStyle(fontSize: 40);
      await tester.pumpWidget(MaterialApp(
        home: Directionality(
          textDirection: dir,
          child: const Scaffold(body: Center(child: OmrAmount('12.50', style: style))),
        ),
      ));
      await tester.pumpAndSettle();

      final svg = tester.getRect(find.byType(SvgPicture));
      final para = tester.getRect(find.byType(RichText));
      // Measure with the style the paragraph actually resolves (it inherits
      // the app's DefaultTextStyle, e.g. Material's 1.43 line height).
      final ctx = tester.element(find.byType(RichText));
      final resolved = DefaultTextStyle.of(ctx).style.merge(style);
      final painter = TextPainter(text: TextSpan(text: '12.50', style: resolved), textDirection: dir)..layout();
      final baselineY = para.top + painter.computeDistanceToActualBaseline(TextBaseline.alphabetic);

      expect(svg.bottom, moreOrLessEquals(baselineY, epsilon: 0.5));
      // Drawn at Open Sans's flat-digit height (the default, English locale).
      expect(svg.height, moreOrLessEquals(style.fontSize! * 0.714, epsilon: 0.5));
      // Symbol leads the amount in reading order.
      expect(dir == TextDirection.ltr ? svg.left < para.center.dx : svg.right > para.center.dx, isTrue);
    });
  }
}
