import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {

  static SharedPreferences? prefs;
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyHeaderKey = 'headerKey';
  static const String _keyUserId = 'userId';
  static const String _keyUserName = 'userName';
  static const String _keyUserEmail = 'userEmail';
  static const String _keyUserPhone = 'userPhone';
  static const String _keyAccessToken = 'accessToken';
  static const String _keyRefreshToken = 'refreshToken';

  static Future init() async =>
      prefs = await SharedPreferences.getInstance();

  // ========== SYNCHRONOUS GETTERS (for immediate access) ==========
  // These use the cached prefs instance initialized in main()

  static String? getAccessTokenSync() {
    return prefs?.getString(_keyAccessToken);
  }

  static String? getRefreshTokenSync() {
    return prefs?.getString(_keyRefreshToken);
  }

  static String? getUserIdSync() {
    return prefs?.getString(_keyUserId);
  }

  static String? getUserNameSync() {
    return prefs?.getString(_keyUserName);
  }

  static String? getUserEmailSync() {
    return prefs?.getString(_keyUserEmail);
  }

  static String? getUserPhoneSync() {
    return prefs?.getString(_keyUserPhone);
  }

  static bool isLoggedInSync() {
    return prefs?.getBool(_keyIsLoggedIn) ?? false;
  }

  // ========== ASYNCHRONOUS METHODS (for when you need fresh data) ==========

  static Future<void> setLoginStatus(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, isLoggedIn);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Header key for API calls
  static Future<void> setLoginHeaderkey(String headerKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyHeaderKey, headerKey);
  }
  //
  // static Future<String?> getLoginHeaderkey() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getString(_keyHeaderKey);
  // }

  // User ID
  static Future<void> setUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, userId);
  }

  // static Future<String?> getUserId() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getString(_keyUserId);
  // }

  // User Name
  static Future<void> setUserName(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, userName);
  }

  // static Future<String?> getUserName() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getString(_keyUserName);
  // }

  // User Email
  static Future<void> setUserEmail(String userEmail) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserEmail, userEmail);
  }

  // static Future<String?> getUserEmail() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getString(_keyUserEmail);
  // }

  // User Phone
  static Future<void> setUserPhone(String userPhone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserPhone, userPhone);
  }
  //
  // static Future<String?> getUserPhone() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getString(_keyUserPhone);
  // }

  // Access Token
  static Future<void> setAccessToken(String accessToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, accessToken);
    // Also update the cached instance
    SessionManager.prefs = prefs;
  }

  // static Future<String?> getAccessToken() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getString(_keyAccessToken);
  // }

  // Refresh Token
  static Future<void> setRefreshToken(String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRefreshToken, refreshToken);
    // Also update the cached instance
    SessionManager.prefs = prefs;
  }

  // static Future<String?> getRefreshToken() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getString(_keyRefreshToken);
  // }

  // Clear all session data
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Save user session data after login
  static Future<void> saveUserSession({
    String? userName,
    String? userEmail,
    String? userPhone,
    String? accessToken,
    String? refreshToken,
    String? userRole,
  }) async {
    await setLoginStatus(true);
    print("access token in session manager: $accessToken");
    if (userName != null) await setUserName(userName);
    if (userEmail != null) await setUserEmail(userEmail);
    if (userPhone != null) await setUserPhone(userPhone);
    if (accessToken != null) await setAccessToken(accessToken);
    if (refreshToken != null) await setRefreshToken(refreshToken);
    if (userRole != null) await setUserId(userRole);
  }
}
