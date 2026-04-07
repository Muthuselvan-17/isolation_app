import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://13.204.191.123:3000';
  String? _token;

  void updateToken(String token) {
    _token = token;
  }

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.post(
      url,
      headers: _headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> get(String endpoint, [Map<String, String>? queryParams]) async {
    String queryString = '';
    if (queryParams != null && queryParams.isNotEmpty) {
      queryString = '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    }
    final url = Uri.parse('$baseUrl$endpoint$queryString');
    return await http.get(url, headers: _headers);
  }
}

// Global instance or provide via Riverpod
final apiServiceProvider = ApiService();
