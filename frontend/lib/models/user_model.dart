/// User model for authentication.
class UserModel {
  final String uid;
  final String email;
  final String token;
  final String refreshToken;

  UserModel({
    required this.uid,
    required this.email,
    required this.token,
    this.refreshToken = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      token: json['token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'token': token,
      'refresh_token': refreshToken,
    };
  }

  UserModel copyWith({String? token, String? refreshToken}) {
    return UserModel(
      uid: uid,
      email: email,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}
