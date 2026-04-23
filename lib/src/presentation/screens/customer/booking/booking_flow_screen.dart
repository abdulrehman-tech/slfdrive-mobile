import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../constants/breakpoints.dart';
import '../../../providers/theme_provider.dart';
import 'models/booking_data.dart';
import 'provider/booking_flow_provider.dart';
import 'steps/success_screen.dart';
import 'widgets/booking_flow_bottom_bar.dart';
import 'widgets/booking_flow_desktop_sidebar.dart';
import 'widgets/booking_flow_step_content.dart';
import 'widgets/booking_flow_top_bar.dart';

/// Multi-step booking flow container.
///
/// Thin composer over [BookingFlowProvider]. The provider owns step index,
/// validation gates, submission state, and the wrapped [BookingData]; this
/// widget only wires navigation side-effects (pop / push success) and picks
/// between mobile and desktop layouts.
class BookingFlowScreen extends StatelessWidget {
  final BookingServiceType? initialServiceType;
  final BookingCar? initialCar;
  final BookingDriver? initialDriver;

  const BookingFlowScreen({
    super.key,
    this.initialServiceType,
    this.initialCar,
    this.initialDriver,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BookingFlowProvider>(
      create: (_) => BookingFlowProvider(
        initialServiceType: initialServiceType,
        initialCar: initialCar,
        initialDriver: initialDriver,
      ),
      child: const _BookingFlowView(),
    );
  }
}

class _BookingFlowView extends StatelessWidget {
  const _BookingFlowView();

  bool _isDark(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    return tp.isDarkMode ||
        (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  Future<void> _handleNext(BuildContext context) async {
    final provider = context.read<BookingFlowProvider>();
    final shouldSubmit = provider.advance();
    if (!shouldSubmit) return;
    await provider.submitPayment();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, _, _) => BookingSuccessScreen(data: provider.data),
        transitionsBuilder: (_, anim, _, child) => FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  void _handleBack(BuildContext context) {
    final shouldPop = context.read<BookingFlowProvider>().goBack();
    if (shouldPop) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(MediaQuery.of(context).size.width);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: isDesktop ? _buildDesktopLayout(context) : _buildMobileLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final provider = context.watch<BookingFlowProvider>();
    final isDark = _isDark(context);
    final steps = provider.steps;

    return Column(
      children: [
        BookingFlowTopBar(
          currentStep: provider.currentStep,
          currentIndex: provider.currentIndex,
          totalSteps: steps.length,
          isDark: isDark,
          onBack: () => _handleBack(context),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0.03, 0), end: Offset.zero).animate(anim),
                child: child,
              ),
            ),
            child: Padding(
              key: ValueKey(provider.currentStep),
              padding: EdgeInsets.fromLTRB(20.r, 8.r, 20.r, 0.r),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: BookingFlowStepContent(
                  step: provider.currentStep,
                  data: provider.data,
                  isDark: isDark,
                ),
              ),
            ),
          ),
        ),
        _buildBottomBar(context, provider, isDark),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final provider = context.watch<BookingFlowProvider>();
    final isDark = _isDark(context);
    final steps = provider.steps;

    return Row(
      children: [
        BookingFlowDesktopSidebar(
          steps: steps,
          currentIndex: provider.currentIndex,
          isDark: isDark,
          onBack: () => Navigator.of(context).pop(),
          onStepTap: provider.goToStep,
        ),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 40.r, vertical: 28.r),
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 760.r),
                      child: BookingFlowStepContent(
                        step: provider.currentStep,
                        data: provider.data,
                        isDark: isDark,
                      ),
                    ),
                  ),
                ),
              ),
              _buildBottomBar(context, provider, isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, BookingFlowProvider provider, bool isDark) {
    return BookingFlowBottomBar(
      isDark: isDark,
      showBack: !provider.isFirstStep,
      showPrice: provider.showPrice,
      isLastStep: provider.isLastStep,
      canGoNext: provider.canGoNext,
      submitting: provider.submitting,
      totalPrice: provider.data.totalPrice,
      nextLabelKey: provider.nextLabelKey,
      onBack: () => _handleBack(context),
      onNext: () => _handleNext(context),
    );
  }
}
