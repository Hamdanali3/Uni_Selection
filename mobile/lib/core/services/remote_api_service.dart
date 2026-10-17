import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_config.dart';

enum BackendSyncStatus {
  unconfigured,
  connected,
  offlineFallback,
}

class RemoteApiService {
  final http.Client _client;

  bool get isConfigured => AppConfig.isSupabaseConfigured;

  RemoteApiService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> get _headers => {
        'apikey': AppConfig.supabaseAnonKey,
        'Authorization': 'Bearer ${AppConfig.supabaseAnonKey}',
        'Content-Type': 'application/json',
      };

  /// Fetches remote published catalogue from Supabase PostgREST endpoints
  Future<Map<String, dynamic>> fetchPublishedData() async {
    if (!AppConfig.isSupabaseConfigured) {
      throw const FormatException('Supabase credentials not configured in AppConfig.');
    }

    final baseUrl = AppConfig.supabaseUrl.replaceAll(RegExp(r'/+$'), '');
    final timeout = Duration(seconds: AppConfig.apiTimeoutSeconds);

    try {
      final results = await Future.wait([
        _get('$baseUrl/rest/v1/countries?select=*', timeout),
        _get('$baseUrl/rest/v1/cities?select=*', timeout),
        _get('$baseUrl/rest/v1/categories?select=*', timeout),
        _get('$baseUrl/rest/v1/disciplines?select=*', timeout),
        _get('$baseUrl/rest/v1/institutions?status=eq.published&select=*', timeout),
        _get('$baseUrl/rest/v1/campuses?status=eq.published&select=*', timeout),
        _get('$baseUrl/rest/v1/programmes?status=eq.published&select=*', timeout),
        _get('$baseUrl/rest/v1/eligibility_rules?select=*', timeout),
        _get('$baseUrl/rest/v1/admissions?select=*', timeout),
        _get('$baseUrl/rest/v1/fee_records?select=*', timeout),
      ]);

      return {
        'countries': results[0],
        'cities': results[1],
        'categories': results[2],
        'disciplines': results[3],
        'institutions': results[4],
        'campuses': results[5],
        'programmes': results[6],
        'eligibility_rules': results[7],
        'admissions': results[8],
        'fee_records': results[9],
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> _get(String url, Duration timeout) async {
    final uri = Uri.parse(url);
    final response = await _client.get(uri, headers: _headers).timeout(timeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded;
      }
      return [decoded];
    } else {
      throw HttpException(
        'PostgREST query failed [${response.statusCode}]: ${response.body}',
        uri: uri,
      );
    }
  }

  void dispose() {
    _client.close();
  }
}

class HttpException implements Exception {
  final String message;
  final Uri? uri;

  const HttpException(this.message, {this.uri});

  @override
  String toString() => uri != null ? '$message ($uri)' : message;
}
