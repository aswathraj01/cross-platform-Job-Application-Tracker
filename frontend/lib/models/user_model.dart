/// User model for authentication.
class UserModel {
  final String uid;
  final String email;
  final String token;

  UserModel({
    required this.uid,
    required this.email,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'token': token,
    };
  }
}
