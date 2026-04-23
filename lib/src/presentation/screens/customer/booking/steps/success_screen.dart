import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/breakpoints.dart';
import '../../../../providers/theme_provider.dart';
import '../models/booking_data.dart';
import 'success_widgets/success_actions.dart';
import 'success_widgets/success_animated_icon.dart';
import 'success_widgets/success_reference_card.dart';
import 'success_widgets/success_summary_card.dart';
import 'success_widgets/success_title.dart';

class BookingSuccessScreen extends StatefulWidget {
  final BookingData data;
  const BookingSuccessScreen({super.key, required this.data});

  @override
  State<BookingSuccessScreen> createState() => _BookingSuccessScreenState();
}

class _BookingSuccessScreenState extends State<BookingSuccessScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _tick;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();
    _tick = CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack));
    _pulse = CurvedAnimation(parent: _ctrl, curve: const Interval(0.3, 1.0, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _isDark {
    final tp = context.watch<ThemeProvider>();
    return tp.isDarkMode || (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(MediaQuery.of(context).size.width);
    final isDark = _isDark;
    final ref = widget.data.bookingRef ?? 'SLF000';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: isDesktop ? 620.r : double.infinity),
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32.r : 20.r, vertical: 24.r),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: isDesktop ? 12.r : 32.r),
                  SuccessAnimatedIcon(tick: _tick, pulse: _pulse),
                  SizedBox(height: 22.r),
                  const SuccessTitle(),
                  SizedBox(height: 22.r),
                  SuccessReferenceCard(reference: ref, isDark: isDark),
                  SizedBox(height: 16.r),
                  SuccessSummaryCard(data: widget.data, isDark: isDark),
                  SizedBox(height: 22.r),
                  const SuccessActions(),
                  SizedBox(height: 24.r),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
