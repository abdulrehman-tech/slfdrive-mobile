class ApiEndpoints {
  /// Backend base URL — includes the `/api` segment. The path constants below
  /// also start with `/api`, so the full request URL intentionally contains
  /// `/api/api/...`, which matches the backend routing.
  static const String baseUrl = 'https://161.97.144.112/api';

  /// Host that serves uploaded media (no `/api` segment). Stored photo/document
  /// URLs are relative to this.
  static const String mediaBaseUrl = 'https://161.97.144.112';

  /// Resolves a stored media path into an absolute URL. Backend photo URLs are
  /// relative to `/Uploads/`; an already-absolute URL is returned untouched.
  /// Returns null for an empty/missing path.
  static String? resolveMediaUrl(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    final p = path.trim();
    if (p.startsWith('http://') || p.startsWith('https://')) return p;
    if (p.startsWith('/')) return '$mediaBaseUrl$p';
    return '$mediaBaseUrl/api/$p';
  }

  // Auth
  static const String loginMobile = '/api/Auth/login-mobile';
  static const String verifyOtp = '/api/Auth/verify-otp';
  static const String refresh = '/api/Auth/refresh';
  static const String signout = '/api/Auth/signout';

  // User
  static const String setLocation = '/api/User/set-location';
  static const String setRole = '/api/User/set-role';

  // Driver
  static const String driver = '/api/Driver';
  static String driverById(int id) => '/api/Driver/$id';

  // Customer
  static const String customer = '/api/Customer';
  static String customerById(int id) => '/api/Customer/$id';

  // Lookups
  static const String activeLocations = '/api/Location/active';

  /// Nearest active location(s) to a point (`POST`, body `{lat, lon, top}`),
  /// sorted by great-circle distance. Used to resolve a delivery point to the
  /// nearest serviceable area (its `id` becomes the booking `locationId`).
  static const String locationNearest = '/api/Location/nearest';
  static const String activeVehicleBrands = '/api/VehicleBrand/active';
  static const String activeVehicleModels = '/api/VehicleModel/active';
  static String vehicleModelsByBrand(int brandId) => '/api/VehicleModel/brand/$brandId';
  static const String activeOfferedServices = '/api/OfferedServices/active';

  // General types / statuses (drive serviceType/paymentType/bookingType/status ids)
  static const String activeGeneralTypes = '/api/GeneralType/active';
  static const String activeGeneralStatuses = '/api/GeneralStatus/active';
  static String generalTypesByType(String type) => '/api/GeneralType/type/$type';
  static String generalStatusesByType(String type) => '/api/GeneralStatus/type/$type';

  // Corporate companies (booking-time company picker)
  static const String activeAllCompanies = '/api/AllCompanies/active';

  // Delivery fees (per company + area). Used to price vehicle delivery.
  static const String deliveryFeeActive = '/api/DeliveryFee/active';
  static String deliveryFeeByCompany(int companyId) => '/api/DeliveryFee/by-company/$companyId';
  static String deliveryFeeByArea(int locationId) => '/api/DeliveryFee/by-area/$locationId';

  // Corporate membership (apply + the signed-in user's memberships)
  static const String corporateMembershipApply = '/api/CorporateMembership/apply';

  /// The mobile user's own memberships. (`/my` is the corporate-admin view;
  /// mobile clients use the per-user endpoint with their own id.)
  static String corporateMembershipByUser(int userId) =>
      '/api/CorporateMembership/user/$userId';

  // Branch (resolves a vehicle's branch -> owning company)
  static String branchById(int id) => '/api/Branch/$id';

  // Bookings
  static const String bookingCreate = '/api/Booking/create';
  static const String bookingMyPaginated = '/api/Booking/my/paginated';
  static const String bookingPaginated = '/api/Booking/paginated';

  /// A specific driver's bookings (`POST`, server-scoped to `driverId`). Same
  /// response shape as `/paginated`; preferred over client-side filtering.
  static String bookingDriverPaginated(int driverId) =>
      '/api/Booking/driver/$driverId/paginated';
  static const String bookingPay = '/api/Booking/pay';
  static String bookingById(int id) => '/api/Booking/$id';

  // Booking lifecycle (driver/owner side)
  static const String bookingApprove = '/api/Booking/approve';
  static const String bookingReject = '/api/Booking/reject';
  static String bookingComplete(int id) => '/api/Booking/$id/complete';
  static String bookingOmPayInit(int id) => '/api/Booking/$id/pay/ompay/init';
  static String bookingOmPayVerify(int id) => '/api/Booking/$id/pay/ompay/verify';

  // Reviews
  static const String review = '/api/Review';
  static String reviewsByBooking(int bookingId) => '/api/Review/booking/$bookingId';
  static String reviewAverageByBooking(int bookingId) =>
      '/api/Review/booking/$bookingId/average';

  // Vehicles (listings)
  static const String vehiclePaginated = '/api/Vehicle/paginated';
  static const String vehicleNearestPaginated = '/api/Vehicle/nearest/paginated';
  static String vehicleById(int id) => '/api/Vehicle/$id';
  static String vehiclesByBrand(int brandId) => '/api/Vehicle/brand/$brandId';

  // Drivers (listings)
  static const String driverPaginated = '/api/Driver/paginated';
  static const String driverNearestPaginated = '/api/Driver/nearest/paginated';

  // Profile completion (post-OTP, multipart/form-data)
  static const String completeIndividualProfile = '/api/User/complete-individual-profile';
  static const String completeDriverProfile = '/api/Driver/complete-profile-driver';
}
