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

  Uri _buildUrl(String endpoint, [Map<String, String>? queryParams]) {
    String queryString = '';
    if (queryParams != null && queryParams.isNotEmpty) {
      queryString = '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    }
    return Uri.parse('$baseUrl$endpoint$queryString');
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body, [Map<String, String>? queryParams]) async {
    final url = _buildUrl(endpoint, queryParams);
    return await http.post(
      url,
      headers: _headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body, [Map<String, String>? queryParams]) async {
    final url = _buildUrl(endpoint, queryParams);
    return await http.put(
      url,
      headers: _headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> patch(String endpoint, Map<String, dynamic> body, [Map<String, String>? queryParams]) async {
    final url = _buildUrl(endpoint, queryParams);
    return await http.patch(
      url,
      headers: _headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> get(String endpoint, [Map<String, String>? queryParams]) async {
    final url = _buildUrl(endpoint, queryParams);
    print('ApiService: GET Request -> $url');
    try {
      final response = await http.get(url, headers: _headers);
      print('ApiService: Status -> ${response.statusCode}, Length -> ${response.body.length}');
      return response;
    } catch (e) {
      print('ApiService: GET Error -> $e');
      rethrow;
    }
  }
}

// Global instance or provide via Riverpod
final apiServiceProvider = ApiService();
