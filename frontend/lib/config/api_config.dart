/// API configuration for connecting to the FastAPI backend.
class ApiConfig {
  /// Base URL for the backend API.
  /// Change this to your deployed backend URL in production.
  static const String baseUrl = 'http://localhost:8000/api';

  // Auth endpoints
  static const String loginUrl = '$baseUrl/auth/login';
  static const String signupUrl = '$baseUrl/auth/signup';

  // Job endpoints
  static const String jobsUrl = '$baseUrl/jobs';

  // AI endpoints
  static const String aiExtractUrl = '$baseUrl/ai/extract';

  /// Request timeout in seconds
  static const int timeoutSeconds = 30;
}
