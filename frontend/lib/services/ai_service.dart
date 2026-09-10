import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Service for AI-powered job data extraction, chat, and analysis.
class AiService {
  final String _token;

  AiService(this._token);

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      };

  /// Extract job data from text and/or URL using AI.
  /// Returns a map with extracted job fields.
  Future<Map<String, dynamic>> extractJobData({
    String? text,
    String? url,
  }) async {
    if ((text == null || text.isEmpty) && (url == null || url.isEmpty)) {
      throw Exception('Either text or URL must be provided');
    }

    final body = <String, dynamic>{};
    if (text != null && text.isNotEmpty) body['text'] = text;
    if (url != null && url.isNotEmpty) body['url'] = url;

    final response = await http
        .post(
          Uri.parse(ApiConfig.aiExtractUrl),
          headers: _headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 60)); // Longer timeout for AI + scraping

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'AI extraction failed');
    }
  }

  /// Send a message to the AI job coach and get a response.
  Future<Map<String, dynamic>> chat({
    required String message,
    List<Map<String, String>> history = const [],
    String? jobContext,
  }) async {
    final body = <String, dynamic>{
      'message': message,
      'history': history,
      if (jobContext != null) 'job_context': jobContext,
    };

    final response = await http
        .post(
          Uri.parse(ApiConfig.aiChatUrl),
          headers: _headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 45));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'AI chat failed');
    }
  }

  /// Analyze overall job application statistics and get insights.
  Future<Map<String, dynamic>> analyzeApplications(String jobsSummary) async {
    final response = await http
        .post(
          Uri.parse(ApiConfig.aiAnalyzeUrl),
          headers: _headers,
          body: jsonEncode({'jobs_summary': jobsSummary}),
        )
        .timeout(const Duration(seconds: 45));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'AI analysis failed');
    }
  }

  /// Get AI advice for a specific job application.
  Future<Map<String, dynamic>> getJobAdvice({
    required String company,
    required String role,
    required String status,
    List<String> skills = const [],
    String? notes,
  }) async {
    final body = <String, dynamic>{
      'company': company,
      'role': role,
      'status': status,
      'skills': skills,
      if (notes != null) 'notes': notes,
    };

    final response = await http
        .post(
          Uri.parse(ApiConfig.aiAdviceUrl),
          headers: _headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 45));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'AI advice failed');
    }
  }
}
