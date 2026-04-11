import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../constants/icon_constants.dart';
import '../../../../../constants/color_constants.dart';
import '../../../../../constants/breakpoints.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isDriver;
  final String deliveryMethod;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.isDriver = false,
    this.deliveryMethod = 'sms',
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isButtonEnabled = false;
  int _resendTimer = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    for (int i = 0; i < 6; i++) {
      _otpControllers[i].addListener(_validateOtp);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _validateOtp() {
    setState(() {
      _isButtonEnabled = _otpControllers.every((controller) => controller.text.isNotEmpty);
    });
  }

  void _onVerify() {
    if (_isButtonEnabled) {
      final otp = _otpControllers.map((c) => c.text).join();
      // TODO: Verify OTP with backend
      context.push(
        '/auth/profile-completion',
        extra: {'phone': widget.phoneNumber, 'isDriver': widget.isDriver, 'otp': otp},
      );
    }
  }

  void _onResend() {
    if (_resendTimer == 0) {
      // TODO: Resend OTP
      _startResendTimer();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('otp_resent'.tr())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = Breakpoints.isDesktop(constraints.maxWidth);

          if (isDesktop) {
            return _buildDesktopLayout(isDark);
          }

          return _buildMobileLayout(isDark);
        },
      ),
    );
  }

  Widget _buildMobileLayout(bool isDark) {
    return SafeArea(
      child: Column(
        children: [
          // Header with back button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.r, vertical: 16.r),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: isDark ? Colors.white : const Color(0xFF3D3D3D),
                    size: 20.r,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.r),

                  // Logo
                  Center(
                    child: SvgPicture.asset(
                      isDark ? IconConstants.logoWhite : IconConstants.logo,
                      width: 120.r,
                      height: 120.r,
                    ),
                  ),

                  SizedBox(height: 40.r),

                  // Title
                  Text(
                    'otp_title'.tr(),
                    style: TextStyle(
                      fontSize: 28.r,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF3D3D3D),
                    ),
                  ),

                  SizedBox(height: 12.r),

                  // Subtitle
                  Row(
                    children: [
                      Icon(
                        widget.deliveryMethod == 'whatsapp' ? Icons.chat_bubble_outline : Icons.sms_outlined,
                        size: 18.r,
                        color: isDark ? Colors.white70 : const Color(0xFF757575),
                      ),
                      SizedBox(width: 8.r),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 16.r,
                              color: isDark ? Colors.white70 : const Color(0xFF757575),
                              height: 1.5,
                            ),
                            children: [
                              TextSpan(
                                text: widget.deliveryMethod == 'whatsapp'
                                    ? 'otp_sent_via_whatsapp'.tr()
                                    : 'otp_sent_via_sms'.tr(),
                              ),
                              TextSpan(
                                text: ' ${widget.phoneNumber}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : const Color(0xFF3D3D3D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 40.r),

                  // OTP Input Fields — always LTR so boxes 0→5 are left→right in all locales
                  Directionality(
                    textDirection: ui.TextDirection.ltr,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) => _buildOtpBox(index, isDark)),
                    ),
                  ),

                  SizedBox(height: 32.r),

                  // Resend OTP
                  Center(
                    child: _resendTimer > 0
                        ? Text(
                            'resend_in'.tr(args: [_resendTimer.toString()]),
                            style: TextStyle(fontSize: 14.r, color: isDark ? Colors.white54 : const Color(0xFF9E9E9E)),
                          )
                        : TextButton(
                            onPressed: _onResend,
                            child: Text(
                              'resend_otp'.tr(),
                              style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.w600, color: secondaryColor),
                            ),
                          ),
                  ),

                  SizedBox(height: 40.r),

                  // Verify Button
                  Container(
                    width: double.infinity,
                    height: 56.r,
                    decoration: BoxDecoration(
                      gradient: _isButtonEnabled
                          ? const LinearGradient(
                              colors: [Color(0xFF4D63DD), Color(0xFF677EF0)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            )
                          : null,
                      color: _isButtonEnabled ? null : (isDark ? Colors.grey[800] : const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isButtonEnabled ? _onVerify : null,
                        borderRadius: BorderRadius.circular(16.r),
                        child: Center(
                          child: Text(
                            'verify'.tr(),
                            style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 24.r),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(bool isDark) {
    final isRtl = Directionality.of(context) == ui.TextDirection.rtl;

    final brandingColumn = Expanded(
      flex: 5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(isDark ? IconConstants.logoWhite : IconConstants.logo, width: 180.r, height: 180.r),
          SizedBox(height: 40.r),
          Text(
            'otp_title'.tr(),
            style: TextStyle(fontSize: 48.r, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.r),
          Row(
            children: [
              Icon(
                widget.deliveryMethod == 'whatsapp' ? Icons.chat_bubble_outline : Icons.sms_outlined,
                size: 20.r,
                color: isDark ? Colors.white70 : const Color(0xFF757575),
              ),
              SizedBox(width: 8.r),
              Expanded(
                child: Text(
                  '${widget.deliveryMethod == 'whatsapp' ? 'otp_sent_via_whatsapp'.tr() : 'otp_sent_via_sms'.tr()} ${widget.phoneNumber}',
                  style: TextStyle(
                    fontSize: 18.r,
                    color: isDark ? Colors.white70 : const Color(0xFF757575),
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    final formColumn = Expanded(
      flex: 4,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () => context.pop(),
              icon: Icon(
                isRtl ? Icons.arrow_forward_ios : Icons.arrow_back_ios_new,
                color: isDark ? Colors.white : const Color(0xFF3D3D3D),
                size: 24.r,
              ),
            ),
            SizedBox(height: 40.r),
            // OTP Input Fields — always LTR so boxes 0→5 are left→right in all locales
            Directionality(
              textDirection: ui.TextDirection.ltr,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) => _buildOtpBoxDesktop(index, isDark)),
              ),
            ),
            SizedBox(height: 32.r),
            Center(
              child: _resendTimer > 0
                  ? Text(
                      'resend_in'.tr(args: [_resendTimer.toString()]),
                      style: TextStyle(fontSize: 16.r, color: isDark ? Colors.white54 : const Color(0xFF9E9E9E)),
                    )
                  : TextButton(
                      onPressed: _onResend,
                      child: Text(
                        'resend_otp'.tr(),
                        style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.w600, color: secondaryColor),
                      ),
                    ),
            ),
            SizedBox(height: 40.r),
            Container(
              width: double.infinity,
              height: 60.r,
              decoration: BoxDecoration(
                gradient: _isButtonEnabled
                    ? const LinearGradient(
                        colors: [Color(0xFF4D63DD), Color(0xFF677EF0)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : null,
                color: _isButtonEnabled ? null : (isDark ? Colors.grey[800] : const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isButtonEnabled ? _onVerify : null,
                  borderRadius: BorderRadius.circular(16.r),
                  child: Center(
                    child: Text(
                      'verify'.tr(),
                      style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        padding: EdgeInsets.symmetric(horizontal: 80.r),
        child: Row(
          children: isRtl
              ? [formColumn, SizedBox(width: 80.r), brandingColumn]
              : [brandingColumn, SizedBox(width: 80.r), formColumn],
        ),
      ),
    );
  }

  void _handleOtpInput(int index, String value) {
    if (value.length > 1) {
      // Paste handling — fill boxes from current index
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < digits.length && (index + i) < 6; i++) {
        _otpControllers[index + i].text = digits[i];
        _otpControllers[index + i].selection = TextSelection.fromPosition(TextPosition(offset: 1));
      }
      final nextFocus = (index + digits.length).clamp(0, 5);
      _focusNodes[nextFocus].requestFocus();
      _validateOtp();
      return;
    }
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Widget _buildOtpBox(int index, bool isDark) {
    final isFilled = _otpControllers[index].text.isNotEmpty;
    return SizedBox(
      width: 52.r,
      height: 68.r,
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(
          fontSize: 22.r,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : const Color(0xFF3D3D3D),
          height: 1.0,
        ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: isFilled ? secondaryColor : (isDark ? Colors.white24 : const Color(0xFFE0E0E0)),
              width: isFilled ? 2 : 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: secondaryColor, width: 2),
          ),
        ),
        onChanged: (value) => _handleOtpInput(index, value),
      ),
    );
  }

  Widget _buildOtpBoxDesktop(int index, bool isDark) {
    final isFilled = _otpControllers[index].text.isNotEmpty;
    return SizedBox(
      width: 60.r,
      height: 80.r,
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : const Color(0xFF3D3D3D),
          height: 1.0,
        ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isFilled ? secondaryColor : (isDark ? Colors.white24 : const Color(0xFFE0E0E0)),
              width: isFilled ? 2 : 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: secondaryColor, width: 2),
          ),
        ),
        onChanged: (value) => _handleOtpInput(index, value),
      ),
    );
  }
}
