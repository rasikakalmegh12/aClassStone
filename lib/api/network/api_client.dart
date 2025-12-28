import 'dart:async';
import 'package:http/http.dart' as http;
import '../../core/services/repository_provider.dart';
import '../../core/session/session_manager.dart';
import '../integration/api_integration.dart';

class ApiClient {
  static bool _isRefreshing = false;
  static Completer<void>? _refreshCompleter;

  /// This wraps ALL HTTP calls
  static Future<http.Response> send(
      Future<http.Response> Function() request,
      ) async {
    // 🔹 BEFORE API → check expiry
    if (SessionManager.isAccessTokenExpiringSoon()) {
      await _refreshTokenIfNeeded();
    }

    final response = await request();

    // 🔹 AFTER API → check 401
    if (response.statusCode == 401) {
      await _refreshTokenIfNeeded();
      return await request(); // retry once
    }

    return response;
  }

  static Future<void> _refreshTokenIfNeeded() async {
    if (_isRefreshing) {
      await _refreshCompleter!.future;
      return;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer();

    final refreshToken = SessionManager.getRefreshToken();
    print('refreshToken: $refreshToken');
    if (refreshToken == null) {
      _refreshCompleter!.completeError('No refresh token');
      _forceLogout();
      _isRefreshing = false;
      return;
    }

    final result = await ApiIntegration.refreshToken(refreshToken);

    if (result.status == true && result.data != null) {
      await SessionManager.setAccessToken(result.data!.accessToken!);
      await SessionManager.setRefreshToken(result.data!.refreshToken!);
      await SessionManager.setAccessTokenExpiry(
        result.data!.accessTokenExpiresAt!,
      );

      _refreshCompleter!.complete();
    } else {
      _refreshCompleter!.completeError('Refresh failed');
      _forceLogout();
    }

    _isRefreshing = false;
  }

  static void _forceLogout() {
    SessionManager.logout();
    AppBlocProvider.forceLogout();
  }


}
