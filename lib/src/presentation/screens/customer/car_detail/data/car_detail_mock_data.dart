import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../models/car_spec.dart';

/// Mock car detail identifiers and copy used across the car detail screen.
const kCarDetailId = 'car-1';
const kCarDetailName = 'Mercedes AMG GT';
const kCarDetailBrand = 'Mercedes';
const kCarDetailRating = '4.9';
const kCarDetailReviewsLabel = '(128 reviews)';
const kCarDetailPricePerDay = 250.0;
const kCarDetailPricePerDayLabel = '250';
const kCarDetailLocation = 'Muscat, Oman';
const kCarDetailPlateNumber = '12345';
const kCarDetailPlateCode = 'A';
const kCarDetailOwnerName = 'Ahmed Al-Balushi';
const kCarDetailOwnerInitial = 'A';
const kCarDetailOwnerStats = '4.9  ·  24 cars listed';
const kCarDetailOwnerPhone = '+96890000000';
const kCarDetailOwnerWhatsAppMessage =
    'Hi, I am interested in your Mercedes AMG GT listing on SLF Drive.';
const kCarDetailHeroImage =
    'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=800&q=80';

const kCarDetailImages = <String>[
  'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=800&q=80',
  'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=800&q=80',
  'https://images.unsplash.com/photo-1583121274602-3e2820c69888?w=800&q=80',
];

List<CarSpec> buildCarSpecs() => [
      CarSpec(icon: Iconsax.people, label: 'car_detail_seats'.tr(), value: '2', color: const Color(0xFF3D5AFE)),
      CarSpec(
          icon: Iconsax.cpu_setting,
          label: 'car_detail_transmission'.tr(),
          value: 'Automatic',
          color: const Color(0xFF7C4DFF)),
      CarSpec(
          icon: Iconsax.gas_station, label: 'car_detail_fuel'.tr(), value: 'Petrol', color: const Color(0xFF00BCD4)),
      CarSpec(icon: Iconsax.calendar_1, label: 'car_detail_year'.tr(), value: '2024', color: const Color(0xFFFFC107)),
      CarSpec(
          icon: Iconsax.colorfilter, label: 'car_detail_color'.tr(), value: 'Silver', color: const Color(0xFFE91E63)),
      CarSpec(icon: Iconsax.cpu, label: 'car_detail_engine'.tr(), value: '4.0L V8', color: const Color(0xFF4CAF50)),
    ];

List<String> buildCarFeatures() => [
      'car_feature_gps'.tr(),
      'car_feature_bluetooth'.tr(),
      'car_feature_leather'.tr(),
      'car_feature_sunroof'.tr(),
      'car_feature_heated_seats'.tr(),
      'car_feature_cruise'.tr(),
      'car_feature_camera'.tr(),
      'car_feature_keyless'.tr(),
    ];
