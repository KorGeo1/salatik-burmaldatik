import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'api_exception.dart';

/// Centralized HTTP client with JWT Bearer injection and 401 handling.
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  String? _token;

  void setToken(String token) => _token = token;
  void clearToken() => _token = null;
  bool get hasToken => _token != null && _token!.isNotEmpty;

  // Callback invoked on 401 so AuthState can trigger logout
  VoidCallback? onUnauthorized;

  // ── headers ──────────────────────────────────────────────────────────────

  Map<String, String> get _headers => {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: 'application/json',
        if (_token != null) HttpHeaders.authorizationHeader: 'Bearer $_token',
      };

  // ── helpers ───────────────────────────────────────────────────────────────

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  dynamic _parse(http.Response res) {
    if (res.statusCode == 401) {
      onUnauthorized?.call();
      throw ApiException(401, 'Unauthorized');
    }
    final body = utf8.decode(res.bodyBytes);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (body.isEmpty) return null;
      return jsonDecode(body);
    }
    String message = 'Server error';
    try {
      final json = jsonDecode(body);
      message = json['detail'] ?? json['message'] ?? message;
    } catch (_) {}
    throw ApiException(res.statusCode, message);
  }

  // ── public methods ────────────────────────────────────────────────────────

  Future<dynamic> get(String path) async {
    final res = await http.get(_uri(path), headers: _headers);
    return _parse(res);
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final res = await http.post(
      _uri(path),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _parse(res);
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    final res = await http.put(
      _uri(path),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _parse(res);
  }

  Future<dynamic> delete(String path) async {
    final res = await http.delete(_uri(path), headers: _headers);
    return _parse(res);
  }
}
