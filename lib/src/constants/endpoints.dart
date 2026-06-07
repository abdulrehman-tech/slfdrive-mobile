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
  static const String activeVehicleBrands = '/api/VehicleBrand/active';
  static const String activeVehicleModels = '/api/VehicleModel/active';
  static String vehicleModelsByBrand(int brandId) => '/api/VehicleModel/brand/$brandId';
  static const String activeOfferedServices = '/api/OfferedServices/active';

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
