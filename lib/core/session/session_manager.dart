import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static SharedPreferences? _preferences;

  // Constants following your exact structure
  static const _isLOGIN = "is_login";
  static const _userId = 'userId';           // Replaces depoId
  static const _userRole = 'userRole';       // NEW: For permissions
  static const _userName = 'userName';       // Replaces depoName
  static const _userEmail = 'userEmail';     // NEW
  static const _userPhone = 'userPhone';     // Replaces depoMobile
  static const _accessToken = 'accessToken'; // Replaces encryptedToken
  static const _refreshToken = 'refreshToken'; // NEW
  static const _headerKey = 'headerKey';
  static const _isPunchedIn = 'isPunchedIn'; // NEW
  static const _punchInTime = 'punchInTime'; // NEW
  static const _fgsRunning = 'fgsRunning'; // foreground service running flag
  static const _accessTokenExpiry = 'accessTokenExpiry'; // NEW

  // ✅ EXACT SAME INIT METHOD
  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  // Helper to provide a consistent fallback for setter return values
  static Future<bool> _falseFuture() => Future.value(false);

  // ========== SYNCHRONOUS GETTERS/SETTERS (Your Style) ==========
  static dynamic setUserLoggedIn(bool isLogin) {
    return _preferences?.setBool(_isLOGIN, isLogin) ?? _falseFuture();
  }

  static dynamic isLoggedIn() {
    return _preferences?.getBool(_isLOGIN) ?? false;
  }

  static dynamic setUserId(String userId) {
    return _preferences?.setString(_userId, userId) ?? _falseFuture();
  }

  static dynamic getUserId() {
    return _preferences?.getString(_userId);
  }

  static dynamic setUserRole(String userRole) {
    return _preferences?.setString(_userRole, userRole) ?? _falseFuture();
  }

  static dynamic getUserRole() {
    return _preferences?.getString(_userRole);
  }

  static dynamic setUserName(String name) {
    return _preferences?.setString(_userName, name) ?? _falseFuture();
  }

  static dynamic getUserName() {
    return _preferences?.getString(_userName);
  }

  static dynamic setUserEmail(String email) {
    return _preferences?.setString(_userEmail, email) ?? _falseFuture();
  }

  static dynamic getUserEmail() {
    return _preferences?.getString(_userEmail);
  }

  static dynamic setUserPhone(String mobile) {
    return _preferences?.setString(_userPhone, mobile) ?? _falseFuture();
  }

  static dynamic getUserPhone() {
    return _preferences?.getString(_userPhone);
  }

  static dynamic setAccessToken(String token) {
    return _preferences?.setString(_accessToken, token) ?? _falseFuture();
  }

  static dynamic getAccessToken() {
    return _preferences?.getString(_accessToken);
  }

  static dynamic setRefreshToken(String token) {
    return _preferences?.setString(_refreshToken, token) ?? _falseFuture();
  }

  static dynamic getRefreshToken() {
    return _preferences?.getString(_refreshToken);
  }

  static dynamic setHeaderKey(String header) {
    return _preferences?.setString(_headerKey, header) ?? _falseFuture();
  }

  static dynamic getHeaderKey() {
    return _preferences?.getString(_headerKey);
  }

  static dynamic setPunchIn(bool isPunchedIn) {
    return _preferences?.setBool(_isPunchedIn, isPunchedIn) ?? _falseFuture();
  }

  // Return a non-null bool; default to false if SharedPreferences isn't initialized
  static bool isPunchedIn() {
    try {
      final val = _preferences?.getBool(_isPunchedIn);
      return val ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Persist whether the foreground service is running (so we don't start duplicates)
  static Future<bool> setForegroundServiceRunning(bool running) async {
    return _preferences?.setBool(_fgsRunning, running) ?? false;
  }

  static bool isForegroundServiceRunning() {
    try {
      return _preferences?.getBool(_fgsRunning) ?? false;
    } catch (e) {
      return false;
    }
  }

  static dynamic setPunchInTime(String? time) {
    if (time == null) {
      return _preferences?.remove(_punchInTime) ?? _falseFuture();
    }
    return _preferences?.setString(_punchInTime, time) ?? _falseFuture();
  }

  static dynamic getPunchInTime() {
    return _preferences?.getString(_punchInTime);
  }

  static dynamic setAccessTokenExpiry(String expiry) {
    return _preferences?.setString(_accessTokenExpiry, expiry) ?? _falseFuture();
  }

  static dynamic getAccessTokenExpiry() {
    final expiryStr = _preferences?.getString(_accessTokenExpiry);
    if (expiryStr == null) return null;
    try {
      return DateTime.parse(expiryStr);
    } catch (e) {
      return null;
    }
  }

  // ========== UTILITY METHODS (Modern Features) ==========
  /// Get user role for catalogue permissions (superadmin/admin/executive)
  static String getUserRoleForPermissions() {
    final role = getUserRole()?.toLowerCase() ?? '';
    if (role.contains('superadmin')) return 'superadmin';
    if (role.contains('admin')) return 'admin';
    return 'executive';
  }

  /// Save complete user session after login (Your Style)
  static dynamic saveUserSession({
    required String userId,
    required String userRole,
    String? userName,
    String? userEmail,
    String? userPhone,
    required String accessToken,
    required String refreshToken,
    String? headerKey,
  }) {
    print('🔐 Saving user session: $userId ($userRole)');

    final results = [
      setUserLoggedIn(true),
      setUserId(userId),
      setUserRole(userRole),
      if (userName != null) setUserName(userName),
      if (userEmail != null) setUserEmail(userEmail),
      if (userPhone != null) setUserPhone(userPhone),
      setAccessToken(accessToken),
      setRefreshToken(refreshToken),
      if (headerKey != null) setHeaderKey(headerKey),
    ];

    print('✅ Session saved successfully (${results.length} operations)');
    return results.every((r) => r != null);
  }

  /// Clear entire session (Your Style + Modern)
  static dynamic logout() {
    print('🧹 Clearing session');
    _preferences?.remove(_isLOGIN);
    _preferences?.remove(_userId);
    _preferences?.remove(_userRole);
    _preferences?.remove(_userName);
    _preferences?.remove(_userEmail);
    _preferences?.remove(_userPhone);
    _preferences?.remove(_accessToken);
    _preferences?.remove(_refreshToken);
    _preferences?.remove(_headerKey);
    _preferences?.remove(_isPunchedIn);
    _preferences?.remove(_punchInTime);
    _preferences?.remove(_fgsRunning);
    _preferences?.remove(_accessTokenExpiry);
    print('✅ Logout completed');
  }

  /// Clear only punch-in data
  static dynamic clearPunchIn() {
    setPunchIn(false);
    setPunchInTime(null);
  }

  /// Check if access token is expiring soon
  static bool isAccessTokenExpiringSoon() {
    final expiry = getAccessTokenExpiry();
    if (expiry == null) return true;
    return DateTime.now().isAfter(expiry.toLocal().subtract(const Duration(minutes: 2)));
  }

  /// Session validation
  static bool isSessionValid() {
    return isLoggedIn() &&
        getUserId() != null &&
        getAccessToken() != null;
  }

  /// Debug info (Optional - remove in production)
  static Map<String, dynamic> getDebugInfo() {
    return {
      'isLoggedIn': isLoggedIn(),
      'userId': getUserId(),
      'userRole': getUserRole(),
      'userName': getUserName(),
      'hasAccessToken': getAccessToken() != null,
      'isPunchedIn': isPunchedIn(),
    };
  }
}
