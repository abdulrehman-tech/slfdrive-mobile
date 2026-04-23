import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../constants/breakpoints.dart';
import '../../../providers/theme_provider.dart';
import 'location_picker_provider/location_picker_provider.dart';
import 'location_picker_widgets/location_picker_desktop_layout.dart';
import 'location_picker_widgets/location_picker_mobile_layout.dart';
import 'models/booking_data.dart';

/// Full-screen Google Maps picker.
///
/// Set a Google Maps API key in the Android manifest / iOS AppDelegate for the
/// map tiles to render. If no key is set, the UI still works — a search/manual
/// address field lets the user type the location and the selected coordinate
/// is the map center (default Muscat).
class LocationPickerScreen extends StatelessWidget {
  final BookingLocation? initial;
  final bool forDelivery;

  const LocationPickerScreen({super.key, this.initial, this.forDelivery = false});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LocationPickerProvider(initial: initial, forDelivery: forDelivery),
      child: _LocationPickerView(forDelivery: forDelivery),
    );
  }
}

class _LocationPickerView extends StatelessWidget {
  final bool forDelivery;

  const _LocationPickerView({required this.forDelivery});

  bool _isDark(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    return tp.isDarkMode || (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  void _confirm(BuildContext context) {
    final result = context.read<LocationPickerProvider>().buildResult();
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(MediaQuery.of(context).size.width);
    final isDark = _isDark(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: isDesktop
          ? LocationPickerDesktopLayout(isDark: isDark, forDelivery: forDelivery, onConfirm: () => _confirm(context))
          : LocationPickerMobileLayout(isDark: isDark, onConfirm: () => _confirm(context)),
    );
  }
}
