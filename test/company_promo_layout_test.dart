// Layout guard for the company profile and promo UI: renders the real widgets
// with the real translations and fonts (Open Sans / Tajawal) across narrow
// and regular phones, English / Arabic / German and 1.0 / 1.3 text scale.
// Any RenderFlex overflow reported while pumping fails the test.
import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slfdrive/src/core/data/repositories/company_repository.dart';
import 'package:slfdrive/src/core/data/repositories/promo_code_repository.dart';
import 'package:slfdrive/src/core/data/repositories/review_repository.dart';
import 'package:slfdrive/src/core/di/injection_container.dart';
import 'package:slfdrive/src/core/models/booking/booking_quote.dart';
import 'package:slfdrive/src/core/models/company/company_profile.dart';
import 'package:slfdrive/src/core/models/driver/driver_listing_item.dart';
import 'package:slfdrive/src/core/models/promo/promo_code.dart';
import 'package:slfdrive/src/core/models/review/review.dart';
import 'package:slfdrive/src/core/models/vehicle/vehicle.dart';
import 'package:slfdrive/src/core/services/review_aggregates.dart';
import 'package:slfdrive/src/presentation/screens/customer/booking/models/booking_data.dart';
import 'package:slfdrive/src/presentation/screens/customer/booking/steps/summary_widgets/summary_promo_card.dart';
import 'package:slfdrive/src/presentation/screens/customer/company_profile/company_profile_screen.dart';
import 'package:slfdrive/src/presentation/screens/customer/favorites/provider/favorites_provider.dart';
import 'package:slfdrive/src/presentation/theme/app_theme.dart';
import 'package:slfdrive/src/presentation/widgets/vehicles/vehicle_card.dart';

import 'support/vehicle_fakes.dart';

const _longName = 'Al Maha Rent A Car (Al Hajiry Group) International Fleet Services';

final _profile = CompanyProfile(
  company: CompanyInfo.fromJson({
    'id': 6,
    'name': _longName,
    'nameAr': 'شركة المها لتأجير السيارات (مجموعة الهاجري) للخدمات الدولية',
    'description': 'Al Maha Rent A Car, a member of Al Hajiry Group, is a leading vehicle rental company '
        'providing reliable and high-quality transportation solutions across Oman. ' * 3,
    'contactPhone': '+96880076655',
    'contactEmail': 'reservations.department@almaha-rentacar-oman.com',
    'website': 'www.almaha-rentacar-oman.com',
    'address': 'Way 3503, Building 1024, Al Khuwair, Muscat, Sultanate of Oman',
    'numberOfBranches': 40,
  }),
  stats: const CompanyStats(averageRating: 4.75, totalReviews: 1280, completedBookings: 12045),
  vehicles: [
    for (var i = 1; i <= 3; i++)
      vehicle(i, brand: 'Mercedes-Benz', name: 'Mercedes-Benz GLE 450 AMG Line Coupé $i', companyId: 6, photo: false),
  ],
  drivers: [
    DriverListingItem.fromJson({
      'id': 5,
      'driverId': 5,
      'fullName': 'Mohammed Abdullah Al Balushi Al Hinai',
      'amountPerDay': 15,
      'yearsOfExperience': 12,
      'languagesKnown': 'English, Arabic, Hindi, Urdu, Swahili',
      'isActive': true,
      'isOnline': true,
      'isVerified': true,
      'allCompanyId': 6,
    }),
  ],
  recentReviews: [
    for (var i = 1; i <= 2; i++)
      Review.fromJson({
        'id': i,
        'rating': 5,
        'comment': 'Great service, the car was spotless and the pickup was on time. Would rent again.',
        'customerName': 'Customer With A Rather Long Display Name $i',
        'createdAt': DateTime.now().subtract(Duration(days: i)).toIso8601String(),
        'isActive': true,
      }),
  ],
);

class _FakeCompanies implements CompanyRepository {
  @override
  Future<CompanyProfile> profile(int companyId) async => _profile;

  @override
  Future<List<CompanyInfo>> active() async => [_profile.company];
}

class _FakeReviews implements ReviewRepository {
  @override
  Future<List<Review>> active() async => const [];

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePromos implements PromoCodeRepository {
  @override
  Future<List<PromoOffer>> active() async => [
        for (final (code, pct) in [('SUMMERSPECIAL2026', true), ('WELCOME', false), ('RAMADANKAREEM', true)])
          PromoOffer.fromJson({
            'id': code.length,
            'code': code,
            'name': 'Seasonal campaign with a long descriptive name',
            'discountType': pct ? 'Percentage' : 'Fixed',
            'discountValue': pct ? 15 : 5,
            'isActive': true,
          }),
      ];

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _loadFonts() async {
  Future<void> family(String name, List<String> files) async {
    final loader = FontLoader(name);
    for (final f in files) {
      loader.addFont(rootBundle.load(f));
    }
    await loader.load();
  }

  const open = 'assets/fonts/Open_Sans/static/OpenSans-';
  const taj = 'assets/fonts/Tajawal/Tajawal-';
  await family('OpenSans', ['${open}Regular.ttf', '${open}SemiBold.ttf', '${open}Bold.ttf']);
  await family('Tajawal', ['${taj}Regular.ttf', '${taj}Medium.ttf', '${taj}Bold.ttf']);
}

const _locales = [Locale('en', 'US'), Locale('ar', 'AE'), Locale('de', 'DE')];

/// Serves the real translation files from memory: the asset-bundle loader only
/// completes in the first widget test of a run under fake async.
class _MemoryLoader extends AssetLoader {
  const _MemoryLoader();

  static final Map<String, Map<String, dynamic>> _files = {
    for (final l in _locales)
      '${l.languageCode}-${l.countryCode}': jsonDecode(
        File('assets/translations/${l.languageCode}-${l.countryCode}.json').readAsStringSync(),
      ) as Map<String, dynamic>,
  };

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) =>
      // Not a SynchronousFuture: Future.wait (used by the controller) drops
      // synchronous completions and would yield empty translations.
      Future.value(_files['${locale.languageCode}-${locale.countryCode}']);
}

Future<void> _pump(
  WidgetTester tester, {
  required Locale locale,
  required Size size,
  required double textScale,
  required bool dark,
  required Widget child,
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final font = locale.languageCode == 'ar' ? 'Tajawal' : 'OpenSans';
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: _locales,
      path: 'assets/translations',
      assetLoader: const _MemoryLoader(),
      fallbackLocale: const Locale('en', 'US'),
      // As in main.dart: partial locales back-fill from English.
      useFallbackTranslations: true,
      startLocale: locale,
      saveLocale: false,
      child: Builder(
        builder: (ctx) => ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, _) => MaterialApp(
            locale: ctx.locale,
            localizationsDelegates: ctx.localizationDelegates,
            supportedLocales: ctx.supportedLocales,
            theme: dark ? AppTheme.darkTheme(font) : AppTheme.lightTheme(font),
            builder: (c, w) => MediaQuery(
              data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(textScale)),
              child: w!,
            ),
            home: ChangeNotifierProvider(create: (_) => FavoritesProvider(), child: child),
          ),
        ),
      ),
    ),
  );
  // Translations load from the asset bundle on real async IO; EasyLocalization
  // renders nothing until they arrive.
  for (var i = 0; i < 100 && find.byType(Scaffold).evaluate().isEmpty; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump();
  }
  expect(find.byType(Scaffold), findsWidgets, reason: 'translations never loaded');
  await tester.pumpAndSettle();
}

typedef _Case = ({Locale locale, Size size, double scale, bool dark});

final _cases = <_Case>[
  for (final locale in _locales)
    for (final size in const [Size(320, 640), Size(390, 844)])
      for (final scale in const [1.0, 1.3, 1.5]) (locale: locale, size: size, scale: scale, dark: scale == 1.3),
];

String _label(_Case c) =>
    '${c.locale.languageCode} ${c.size.width.toInt()}w x${c.scale}${c.dark ? ' dark' : ''}';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    await _loadFonts();
  });

  setUp(() {
    getIt.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());
    getIt.registerSingleton<CompanyRepository>(_FakeCompanies());
    getIt.registerSingleton<ReviewAggregates>(ReviewAggregates(_FakeReviews()));
    getIt.registerSingleton<PromoCodeRepository>(_FakePromos());
  });

  tearDown(() => getIt.reset());

  // Component themes (AppBar titles, buttons) don't inherit ThemeData.fontFamily;
  // they fell back to the system font (SF) until the theme set it explicitly.
  for (final locale in [_locales[0], _locales[1]]) {
    testWidgets('app bar titles use the locale font (${locale.languageCode})', (tester) async {
      await _pump(
        tester,
        locale: locale,
        size: const Size(390, 844),
        textScale: 1,
        dark: true,
        child: Scaffold(
          appBar: AppBar(title: const Text('title')),
          body: Center(child: TextButton(onPressed: () {}, child: const Text('button'))),
        ),
      );
      final font = locale.languageCode == 'ar' ? 'Tajawal' : 'OpenSans';
      for (final label in ['title', 'button']) {
        final paragraph = tester.renderObject<RenderParagraph>(find.text(label));
        expect(paragraph.text.style?.fontFamily, font, reason: label);
      }
    });
  }

  for (final c in _cases) {
    testWidgets('company profile lays out without overflow (${_label(c)})', (tester) async {
      await _pump(
        tester,
        locale: c.locale,
        size: c.size,
        textScale: c.scale,
        dark: c.dark,
        child: const CompanyProfileScreen(companyId: 6),
      );
      expect(find.byType(VehicleCard), findsWidgets);
      expect(tester.takeException(), isNull, reason: 'layout error in header / vehicles');

      // Collapse the header, then walk every tab.
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();
      for (final key in ['company_tab_drivers', 'company_tab_reviews', 'company_tab_vehicles']) {
        await tester.tap(find.textContaining(key.tr()).first, warnIfMissed: false);
        await tester.pumpAndSettle();
        final err = tester.takeException();
        expect(err, isNull, reason: 'layout error on the $key tab');
      }
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 800));
      await tester.pumpAndSettle();
    });

    testWidgets('vehicle card company link lays out without overflow (${_label(c)})', (tester) async {
      await _pump(
        tester,
        locale: c.locale,
        size: c.size,
        textScale: c.scale,
        dark: c.dark,
        child: Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final v in _profile.vehicles)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: VehicleCard(
                    vehicle: Vehicle.fromJson({
                      ...{'id': v.id, 'name': v.name, 'brandName': 'Mercedes-Benz', 'year': 2024, 'pricePerDay': 45.5},
                      'companyId': 6,
                      'companyName': _longName,
                      'companyNameAr': 'شركة المها لتأجير السيارات (مجموعة الهاجري)',
                      'seats': 5,
                      'transmissionTypeName': 'Automatic',
                      'fuelTypeName': 'Petrol',
                      'isActive': true,
                      'statusId': 1,
                      'statusName': 'available',
                    }),
                    ar: c.locale.languageCode == 'ar',
                    rating: 4.8,
                    onTap: () {},
                  ),
                ),
            ],
          ),
        ),
      );
      expect(find.byType(VehicleCard), findsNWidgets(3));
    });

    testWidgets('promo card lays out without overflow (${_label(c)})', (tester) async {
      final data = BookingData();
      await _pump(
        tester,
        locale: c.locale,
        size: c.size,
        textScale: c.scale,
        dark: c.dark,
        child: Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // The review step rebuilds the card from BookingData; mirror it.
              ListenableBuilder(
                listenable: data,
                builder: (_, _) => SummaryPromoCard(data: data, isDark: c.dark),
              ),
            ],
          ),
        ),
      );
      expect(find.text('SUMMERSPECIAL2026'), findsOneWidget);

      // Error state.
      data.setPromoError('promo_not_applicable');
      await tester.pumpAndSettle();

      // Applied state: a quote carrying the server discount.
      data.setQuote(BookingQuote.fromJson({
        'days': 3,
        'rentalAmount': 360.0,
        'grossAmount': 360.0,
        'promoCode': 'SUMMERSPECIAL2026',
        'promoCodeId': 7,
        'discountAmount': 54.0,
        'totalAmount': 306.0,
      }));
      data.setPromoApplied('SUMMERSPECIAL2026');
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });
  }
}
