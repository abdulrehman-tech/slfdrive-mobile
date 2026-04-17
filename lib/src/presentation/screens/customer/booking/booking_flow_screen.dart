import 'dart:math';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../constants/breakpoints.dart';
import '../../../../constants/color_constants.dart';
import '../../../providers/theme_provider.dart';
import '../../../widgets/omr_icon.dart';
import 'models/booking_data.dart';
import 'steps/dates_step.dart';
import 'steps/driver_select_step.dart';
import 'steps/extras_step.dart';
import 'steps/payment_step.dart';
import 'steps/pickup_mode_step.dart';
import 'steps/service_type_step.dart';
import 'steps/success_screen.dart';
import 'steps/summary_step.dart';
import 'widgets/booking_stepper.dart';

/// Multi-step booking flow container.
///
/// Owns a [BookingData] `ChangeNotifier` (provided to children) and tracks the
/// current step. The step list is derived from the currently-selected service
/// type so that the "driver selection" step only appears for Car + Driver and
/// "extras" is skipped for Driver Only.
class BookingFlowScreen extends StatefulWidget {
  final BookingServiceType? initialServiceType;
  final BookingCar? initialCar;
  final BookingDriver? initialDriver;

  const BookingFlowScreen({super.key, this.initialServiceType, this.initialCar, this.initialDriver});

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

enum _StepId { service, dates, pickup, extras, driver, summary, payment }

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  late final BookingData _data;
  int _currentIndex = 0;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _data = BookingData(
      initialServiceType: widget.initialServiceType,
      initialCar: widget.initialCar,
      initialDriver: widget.initialDriver,
    );
    // Seed sensible defaults BEFORE attaching the listener so the notify fired
    // by setDates doesn't trigger setState on this screen during the initial
    // build phase (which would violate the "tree locked" invariant).
    if (_data.startAt == null) {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      _data.setDates(start, start.add(const Duration(days: 2)));
    }
    _data.addListener(_onDataChange);
  }

  @override
  void dispose() {
    _data.removeListener(_onDataChange);
    _data.dispose();
    super.dispose();
  }

  void _onDataChange() {
    if (mounted) setState(() {});
  }

  bool get _isDark {
    final tp = context.watch<ThemeProvider>();
    return tp.isDarkMode || (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  // Visible steps filtered by service type & entry context.
  List<_StepId> get _steps {
    final service = _data.serviceType;
    final ids = <_StepId>[];
    // Service selector: skipped if the flow was entered with a preset
    // service + subject (typical when entering from car or driver detail).
    final skipService =
        widget.initialServiceType != null && (widget.initialCar != null || widget.initialDriver != null);
    if (!skipService) ids.add(_StepId.service);
    ids.add(_StepId.dates);
    if (service != BookingServiceType.driverOnly) ids.add(_StepId.pickup);
    if (service != BookingServiceType.driverOnly) ids.add(_StepId.extras);
    if (service == BookingServiceType.carWithDriver) ids.add(_StepId.driver);
    ids.add(_StepId.summary);
    ids.add(_StepId.payment);
    return ids;
  }

  _StepId get _currentStep => _steps[_currentIndex];

  // ------------------------------------------------------------
  // Navigation helpers
  // ------------------------------------------------------------

  bool get _canGoNext {
    switch (_currentStep) {
      case _StepId.service:
        return _data.serviceType != null;
      case _StepId.dates:
        return _data.startAt != null && _data.endAt != null;
      case _StepId.pickup:
        if (_data.pickupMode == PickupMode.delivery) {
          return _data.deliveryLocation != null;
        }
        return true;
      case _StepId.extras:
        return true;
      case _StepId.driver:
        return _data.driver != null;
      case _StepId.summary:
        return true;
      case _StepId.payment:
        return !_submitting;
    }
  }

  String get _nextLabelKey {
    if (_currentStep == _StepId.payment) return 'booking_pay_now';
    if (_currentStep == _StepId.summary) return 'booking_confirm_review';
    return 'booking_next';
  }

  Future<void> _handleNext() async {
    if (!_canGoNext) return;
    if (_currentStep == _StepId.payment) {
      await _submitPayment();
      return;
    }
    if (_currentIndex < _steps.length - 1) {
      setState(() => _currentIndex++);
    }
  }

  void _handleBack() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _submitPayment() async {
    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    final ref = _generateRef();
    _data.assignBookingRef(ref);
    if (!mounted) return;
    setState(() => _submitting = false);

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, _, _) => BookingSuccessScreen(data: _data),
        transitionsBuilder: (_, anim, _, child) => FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  String _generateRef() {
    final rand = Random();
    final code = List.generate(6, (_) => rand.nextInt(10)).join();
    return 'SLF$code';
  }

  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(MediaQuery.of(context).size.width);
    return ChangeNotifierProvider<BookingData>.value(
      value: _data,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
      ),
    );
  }

  // ------------------------------------------------------------
  // MOBILE LAYOUT
  // ------------------------------------------------------------

  Widget _buildMobileLayout() {
    final isDark = _isDark;
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Top bar
        _buildMobileTopBar(cs, isDark),
        // Step content
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
              key: ValueKey(_currentStep),
              padding: EdgeInsets.fromLTRB(20.r, 8.r, 20.r, 0.r),
              child: SingleChildScrollView(physics: const BouncingScrollPhysics(), child: _buildStepContent(isDark)),
            ),
          ),
        ),
        // Bottom action bar
        _buildBottomBar(cs, isDark),
      ],
    );
  }

  Widget _buildMobileTopBar(ColorScheme cs, bool isDark) {
    final steps = _steps;
    return Container(
      padding: EdgeInsets.fromLTRB(16.r, MediaQuery.of(context).padding.top + 8.r, 16.r, 14.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _handleBack,
                child: Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.07),
                    ),
                  ),
                  child: Icon(CupertinoIcons.back, size: 17.r, color: cs.onSurface),
                ),
              ),
              SizedBox(width: 12.r),
              Expanded(
                child: BookingStepperCompact(
                  currentIndex: _currentIndex,
                  totalSteps: steps.length,
                  currentTitle: _titleFor(_currentStep).tr(),
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // DESKTOP LAYOUT
  // ------------------------------------------------------------

  Widget _buildDesktopLayout() {
    final isDark = _isDark;
    final cs = Theme.of(context).colorScheme;
    final steps = _steps;

    return Row(
      children: [
        // Side stepper
        Container(
          width: 300.r,
          padding: EdgeInsets.symmetric(horizontal: 24.r, vertical: 28.r),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF111118) : Colors.white,
            border: Border(
              right: BorderSide(
                color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(CupertinoIcons.back, size: 17.r, color: cs.onSurface),
                    ),
                  ),
                  SizedBox(width: 12.r),
                  Text(
                    'booking_title'.tr(),
                    style: TextStyle(fontSize: 20.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                  ),
                ],
              ),
              SizedBox(height: 28.r),
              BookingStepperVertical(
                steps: steps.map((id) => BookingStep(icon: _iconFor(id), titleKey: _titleFor(id))).toList(),
                currentIndex: _currentIndex,
                isDark: isDark,
                onStepTap: (i) => setState(() => _currentIndex = i),
              ),
            ],
          ),
        ),
        // Step content
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
                      child: _buildStepContent(isDark),
                    ),
                  ),
                ),
              ),
              _buildBottomBar(cs, isDark),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------

  Widget _buildStepContent(bool isDark) {
    switch (_currentStep) {
      case _StepId.service:
        return ServiceTypeStep(data: _data, isDark: isDark);
      case _StepId.dates:
        return DatesStep(data: _data, isDark: isDark);
      case _StepId.pickup:
        return PickupModeStep(data: _data, isDark: isDark);
      case _StepId.extras:
        return ExtrasStep(data: _data, isDark: isDark);
      case _StepId.driver:
        return DriverSelectStep(data: _data, isDark: isDark);
      case _StepId.summary:
        return SummaryStep(data: _data, isDark: isDark);
      case _StepId.payment:
        return PaymentStep(data: _data, isDark: isDark);
    }
  }

  // ------------------------------------------------------------
  // BOTTOM ACTION BAR
  // ------------------------------------------------------------

  Widget _buildBottomBar(ColorScheme cs, bool isDark) {
    final isLast = _currentStep == _StepId.payment;
    final showPrice = _currentStep == _StepId.summary || _currentStep == _StepId.payment;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(20.r, 14.r, 20.r, 14.r + MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A28).withValues(alpha: 0.92) : Colors.white.withValues(alpha: 0.92),
            border: Border(
              top: BorderSide(
                color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06),
              ),
            ),
          ),
          child: Row(
            children: [
              if (_currentIndex > 0)
                GestureDetector(
                  onTap: _handleBack,
                  child: Container(
                    width: 48.r,
                    height: 48.r,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(CupertinoIcons.back, size: 19.r, color: cs.onSurface),
                  ),
                ),
              if (showPrice) ...[
                if (_currentIndex > 0) SizedBox(width: 14.r),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'booking_bar_total'.tr(),
                        style: TextStyle(
                          fontSize: 10.r,
                          color: cs.onSurface.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2.r),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          OmrIcon(size: 14.r, color: cs.primary),
                          SizedBox(width: 3.r),
                          Text(
                            _data.totalPrice.toStringAsFixed(2),
                            style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.w900, color: cs.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else
                Expanded(child: SizedBox(width: 14.r)),
              GestureDetector(
                onTap: _canGoNext ? _handleNext : null,
                child: Opacity(
                  opacity: _canGoNext ? 1.0 : 0.4,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: EdgeInsets.symmetric(horizontal: 28.r, vertical: 16.r),
                    decoration: BoxDecoration(
                      gradient: primaryGradient,
                      borderRadius: BorderRadius.circular(14.r),
                      boxShadow: _canGoNext
                          ? [
                              BoxShadow(
                                color: const Color(0xFF0C2485).withValues(alpha: 0.35),
                                blurRadius: 14.r,
                                offset: Offset(0, 5.r),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_submitting)
                          SizedBox(
                            width: 16.r,
                            height: 16.r,
                            child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        else
                          Text(
                            _nextLabelKey.tr(),
                            style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        SizedBox(width: 8.r),
                        Icon(
                          isLast ? Iconsax.tick_square_copy : CupertinoIcons.arrow_right,
                          size: 15.r,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------

  String _titleFor(_StepId id) {
    switch (id) {
      case _StepId.service:
        return 'booking_step_service';
      case _StepId.dates:
        return 'booking_step_dates';
      case _StepId.pickup:
        return 'booking_step_pickup';
      case _StepId.extras:
        return 'booking_step_extras';
      case _StepId.driver:
        return 'booking_step_driver';
      case _StepId.summary:
        return 'booking_step_summary';
      case _StepId.payment:
        return 'booking_step_payment';
    }
  }

  IconData _iconFor(_StepId id) {
    switch (id) {
      case _StepId.service:
        return Iconsax.setting_4_copy;
      case _StepId.dates:
        return Iconsax.calendar_2_copy;
      case _StepId.pickup:
        return Iconsax.truck_copy;
      case _StepId.extras:
        return Iconsax.additem_copy;
      case _StepId.driver:
        return Iconsax.user_octagon_copy;
      case _StepId.summary:
        return Iconsax.clipboard_text_copy;
      case _StepId.payment:
        return Iconsax.card_copy;
    }
  }
}
