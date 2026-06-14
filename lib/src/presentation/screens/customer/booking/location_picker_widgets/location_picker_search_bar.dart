import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../../core/services/places_service.dart';
import '../location_picker_provider/location_picker_provider.dart';

/// Glass search bar with Google Places autocomplete: typing queries the Places
/// API and taps on a suggestion recenter the map. Falls back to plain typed
/// text (reverse-geocoded from the map center) when no key/results.
class LocationPickerSearchBar extends StatelessWidget {
  final bool isDark;

  const LocationPickerSearchBar({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final provider = context.watch<LocationPickerProvider>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _glass(
          context,
          cs,
          child: Row(
            children: [
              Icon(Iconsax.search_normal_copy, size: 18.r, color: cs.primary),
              SizedBox(width: 10.r),
              Expanded(
                child: TextField(
                  controller: provider.addressController,
                  onChanged: provider.onSearchChanged,
                  textInputAction: TextInputAction.search,
                  style: TextStyle(fontSize: 13.r, color: cs.onSurface),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'booking_location_search_hint'.tr(),
                    hintStyle: TextStyle(fontSize: 13.r, color: cs.onSurface.withValues(alpha: 0.4)),
                    contentPadding: EdgeInsets.symmetric(vertical: 14.r),
                  ),
                ),
              ),
              if (provider.searching || provider.resolving)
                SizedBox(width: 14.r, height: 14.r, child: const CircularProgressIndicator(strokeWidth: 1.8))
              else if (provider.addressController.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    provider.addressController.clear();
                    provider.onSearchChanged('');
                    FocusScope.of(context).unfocus();
                  },
                  child: Icon(Iconsax.close_circle_copy, size: 16.r, color: cs.onSurface.withValues(alpha: 0.4)),
                ),
            ],
          ),
        ),
        if (provider.predictions.isNotEmpty) ...[
          SizedBox(height: 8.r),
          _glass(
            context,
            cs,
            padded: false,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 260.r),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(vertical: 4.r),
                itemCount: provider.predictions.length,
                separatorBuilder: (_, _) => Divider(
                  height: 1,
                  color: cs.onSurface.withValues(alpha: 0.06),
                  indent: 44.r,
                ),
                itemBuilder: (_, i) => _SuggestionTile(
                  prediction: provider.predictions[i],
                  cs: cs,
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    provider.selectPrediction(provider.predictions[i]);
                  },
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _glass(BuildContext context, ColorScheme cs, {required Widget child, bool padded = true}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padded ? EdgeInsets.symmetric(horizontal: 14.r) : EdgeInsets.zero,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A28).withValues(alpha: 0.92) : Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                blurRadius: 14.r,
                offset: Offset(0, 4.r),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final PlacePrediction prediction;
  final ColorScheme cs;
  final VoidCallback onTap;

  const _SuggestionTile({required this.prediction, required this.cs, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 11.r),
        child: Row(
          children: [
            Icon(Iconsax.location_copy, size: 16.r, color: cs.primary.withValues(alpha: 0.7)),
            SizedBox(width: 10.r),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prediction.primaryText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w600, color: cs.onSurface),
                  ),
                  if (prediction.secondaryText.isNotEmpty) ...[
                    SizedBox(height: 2.r),
                    Text(
                      prediction.secondaryText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.5)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
