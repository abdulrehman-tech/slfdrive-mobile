import '../user/user_model.dart';

/// The `data` payload returned by login-mobile / verify-otp / refresh.
///
/// - login-mobile: `requiresOtp == true`, `otpId` set, tokens empty.
/// - verify-otp / refresh: tokens populated, `requiresOtp == false`.
class AuthSession {
  final User? user;
  final String accessToken;
  final String refreshToken;
  final String? accessTokenExpiry;
  final String? refreshTokenExpiry;
  final int? otpId;
  final bool requiresOtp;

  const AuthSession({
    this.user,
    this.accessToken = '',
    this.refreshToken = '',
    this.accessTokenExpiry,
    this.refreshTokenExpiry,
    this.otpId,
    this.requiresOtp = false,
  });

  bool get hasTokens => accessToken.isNotEmpty && refreshToken.isNotEmpty;

  factory AuthSession.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>;
    return AuthSession(
      user: map['user'] != null ? User.fromJson(map['user'] as Map<String, dynamic>) : null,
      accessToken: (map['accessToken'] as String?) ?? '',
      refreshToken: (map['refreshToken'] as String?) ?? '',
      accessTokenExpiry: map['accessTokenExpiry'] as String?,
      refreshTokenExpiry: map['refreshTokenExpiry'] as String?,
      otpId: (map['otpId'] as num?)?.toInt(),
      requiresOtp: (map['requiresOtp'] as bool?) ?? false,
    );
  }
}
