/// API configuration for connecting to the FastAPI backend.
class ApiConfig {
  /// Base URL for the backend API — live Render.com cloud deployment.
  static const String baseUrl = 'https://job-tracker-api-i9hd.onrender.com/api';

  // Auth endpoints
  static const String loginUrl = '$baseUrl/auth/login';
  static const String signupUrl = '$baseUrl/auth/signup';

  // Job endpoints
  static const String jobsUrl = '$baseUrl/jobs';

  // AI endpoints
  static const String aiExtractUrl = '$baseUrl/ai/extract';
  static const String aiChatUrl = '$baseUrl/ai/chat';
  static const String aiAnalyzeUrl = '$baseUrl/ai/analyze';
  static const String aiAdviceUrl = '$baseUrl/ai/advice';

  // Extension endpoints
  static const String extensionScrapeUrl = '$baseUrl/extension/scrape';
  static const String extensionCheckUrl = '$baseUrl/extension/check';
  static const String extensionCaptureUrl = '$baseUrl/extension/capture';

  /// Request timeout in seconds
  static const int timeoutSeconds = 30;
}
