import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user_model.dart';

/// Service for handling authentication API calls.
class AuthService {
  /// Login with email and password.
  Future<UserModel> login(String email, String password) async {
    final response = await http
        .post(
          Uri.parse(ApiConfig.loginUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Login failed');
    }
  }

  /// Sign up with email and password.
  Future<UserModel> signup(String email, String password) async {
    final response = await http
        .post(
          Uri.parse(ApiConfig.signupUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Signup failed');
    }
  }

  /// Silently refresh the ID token using a stored refresh token.
  /// Returns a new [UserModel] with updated tokens. Throws on failure.
  Future<UserModel> refreshToken(UserModel currentUser) async {
    if (currentUser.refreshToken.isEmpty) {
      throw Exception('No refresh token available — please log in again');
    }

    final response = await http
        .post(
          Uri.parse(ApiConfig.refreshUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refresh_token': currentUser.refreshToken}),
        )
        .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Merge new tokens into existing user (email stays the same)
      return currentUser.copyWith(
        token: data['token'] ?? '',
        refreshToken: data['refresh_token'] ?? currentUser.refreshToken,
      );
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Token refresh failed');
    }
  }
}
