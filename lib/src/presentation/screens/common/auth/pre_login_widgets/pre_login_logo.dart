import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../constants/icon_constants.dart';

/// White SLF Drive logo anchored top-leading. Size differs between mobile and
/// desktop entrypoints.
class PreLoginLogo extends StatelessWidget {
  final double size;

  const PreLoginLogo({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: SvgPicture.asset(IconConstants.logoWhite, width: size, height: size, fit: BoxFit.contain),
    );
  }
}
