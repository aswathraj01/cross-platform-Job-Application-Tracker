import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Service for AI-powered job data extraction.
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
        .timeout(Duration(seconds: 60)); // Longer timeout for AI + scraping

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'AI extraction failed');
    }
  }
}
