import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';

class AuthUser {
  final String id;
  final String email;
  final String displayName;

  const AuthUser({
    required this.id,
    required this.email,
    required this.displayName,
  });
}

class AuthException implements Exception {
  final String message;
  final int? statusCode;

  const AuthException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class AuthRepository {
  AuthRepository({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  String? _accessToken;
  String? _refreshToken;
  AuthUser? _currentUser;

  AuthUser? get currentUser => _currentUser;

  String? get accessToken => _accessToken;

  Future<AuthUser?> restoreSession() async {
    if (_accessToken == null) {
      return null;
    }

    try {
      final user = await _fetchCurrentUser();
      _currentUser = user;
      return user;
    } on AuthException catch (error) {
      if (error.statusCode == 401 && _refreshToken != null) {
        await _refreshTokens();
        final user = await _fetchCurrentUser();
        _currentUser = user;
        return user;
      }

      clearSession();
      return null;
    }
  }

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final response = _expectMap(
      await sendRequest(
        method: 'POST',
        path: '/auth/login',
        body: {'email': email, 'password': password},
      ),
      errorMessage: 'Phản hồi đăng nhập không hợp lệ từ server',
    );

    _accessToken = _readString(response, 'accessToken');
    _refreshToken = _readString(response, 'refreshToken');

    if (_accessToken == null || _refreshToken == null) {
      clearSession();
      throw const AuthException('Phản hồi đăng nhập không hợp lệ từ server');
    }

    final user = await _fetchCurrentUser();
    _currentUser = user;
    return user;
  }

  Future<AuthUser> register({
    required String email,
    required String password,
  }) async {
    final response = _expectMap(
      await sendRequest(
        method: 'POST',
        path: '/auth/register',
        body: {'email': email, 'password': password},
      ),
      errorMessage: 'Phản hồi đăng ký không hợp lệ từ server',
    );

    _accessToken = _readString(response, 'accessToken');
    _refreshToken = _readString(response, 'refreshToken');

    if (_accessToken == null || _refreshToken == null) {
      clearSession();
      throw const AuthException('Phản hồi đăng ký không hợp lệ từ server');
    }

    final user = await _fetchCurrentUser();
    _currentUser = user;
    return user;
  }

  Future<void> logout() async {
    final token = _accessToken;
    final refreshToken = _refreshToken;

    try {
      if (refreshToken != null) {
        await sendRequest(
          method: 'POST',
          path: '/auth/logout',
          body: {'refreshToken': refreshToken},
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        );
      }
    } finally {
      clearSession();
    }
  }

  void clearSession() {
    _accessToken = null;
    _refreshToken = null;
    _currentUser = null;
  }

  Future<AuthUser> _fetchCurrentUser() async {
    final data = _expectMap(
      await sendAuthenticatedRequest(
        method: 'GET',
        path: '/users/me',
      ),
      errorMessage: 'Phản hồi hồ sơ người dùng không hợp lệ',
    );

    final email = _readString(data, 'email') ?? '';
    final name = _readString(data, 'name');
    final fallbackName = email.contains('@') ? email.split('@').first : email;

    return AuthUser(
      id: _readId(data, 'id') ?? '',
      email: email,
      displayName: (name != null && name.trim().isNotEmpty)
          ? name.trim()
          : fallbackName,
    );
  }

  Future<void> _refreshTokens() async {
    final refreshToken = _refreshToken;
    if (refreshToken == null) {
      throw const AuthException('Phiên đăng nhập đã hết hạn');
    }

    final response = _expectMap(
      await sendRequest(
        method: 'POST',
        path: '/auth/refresh',
        body: {'refreshToken': refreshToken},
      ),
      errorMessage: 'Không thể làm mới phiên đăng nhập',
    );

    _accessToken = _readString(response, 'accessToken');
    _refreshToken = _readString(response, 'refreshToken');

    if (_accessToken == null || _refreshToken == null) {
      clearSession();
      throw const AuthException('Không thể làm mới phiên đăng nhập');
    }
  }

  Future<dynamic> sendRequest({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final response = await _sendRequest(
      method: method,
      path: path,
      body: body,
      headers: headers,
    );

    return _unwrapData(response);
  }

  Future<dynamic> sendAuthenticatedRequest({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final token = _accessToken;
    if (token == null) {
      throw const AuthException('Bạn chưa đăng nhập');
    }

    try {
      return _unwrapData(
        await _sendRequest(
          method: method,
          path: path,
          body: body,
          headers: {
            if (headers != null) ...headers,
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on AuthException catch (error) {
      if (error.statusCode == 401 && _refreshToken != null) {
        await _refreshTokens();

        final refreshedToken = _accessToken;
        if (refreshedToken == null) {
          throw const AuthException('Phiên đăng nhập đã hết hạn');
        }

        return _unwrapData(
          await _sendRequest(
            method: method,
            path: path,
            body: body,
            headers: {
              if (headers != null) ...headers,
              'Authorization': 'Bearer $refreshedToken',
            },
          ),
        );
      }

      rethrow;
    }
  }

  Future<dynamic> _sendRequest({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final uri = AppConfig.apiUri(path);
    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      if (headers != null) ...headers,
    };

    late final http.Response response;
    try {
      switch (method) {
        case 'POST':
          response = await _httpClient.post(
            uri,
            headers: requestHeaders,
            body: body == null ? null : jsonEncode(body),
          );
          break;
        case 'GET':
          response = await _httpClient.get(uri, headers: requestHeaders);
          break;
        case 'PATCH':
          response = await _httpClient.patch(
            uri,
            headers: requestHeaders,
            body: body == null ? null : jsonEncode(body),
          );
          break;
        case 'DELETE':
          response = await _httpClient.delete(
            uri,
            headers: requestHeaders,
            body: body == null ? null : jsonEncode(body),
          );
          break;
        default:
          throw AuthException('HTTP method chưa được hỗ trợ: $method');
      }
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException(
        'Không thể kết nối tới auth service. Kiểm tra API URL và server backend.',
      );
    }

    dynamic decoded;
    if (response.body.isNotEmpty) {
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = null;
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthException(
        _extractErrorMessage(decoded) ??
            'Request thất bại (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }

    return decoded;
  }

  dynamic _unwrapData(dynamic payload) {
    if (payload is! Map<String, dynamic>) {
      return payload;
    }

    final success = payload['success'];
    final data = payload['data'];

    if (success is bool && success && data != null) {
      return data;
    }

    return payload;
  }

  Map<String, dynamic> _expectMap(
    dynamic payload, {
    required String errorMessage,
  }) {
    if (payload is Map<String, dynamic>) {
      return payload;
    }

    throw AuthException(errorMessage);
  }

  String? _extractErrorMessage(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final message = decoded['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
      if (message is List && message.isNotEmpty) {
        final text = message.join(', ');
        if (text.isNotEmpty) {
          return text;
        }
      }

      final error = decoded['error'];
      if (error is String && error.isNotEmpty) {
        return error;
      }
    }
    return null;
  }

  String? _readId(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    if (value is int) {
      return value.toString();
    }
    return null;
  }

  String? _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return null;
  }
}
