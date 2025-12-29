import 'package:hive/hive.dart';

class AuthUser {
  final String id;
  final String email;
  final String? name;

  AuthUser({required this.id, required this.email, this.name});

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'].toString(),
      email: json['email'],
      name: json['name'],
    );
  }
}

class AuthSession {
  final String accessToken;
  final AuthUser user;

  AuthSession({required this.accessToken, required this.user});
}

class AuthRepository {
  static const _boxName = 'auth_session';

  Future<Box> _box() => Hive.openBox(_boxName);

  Future<void> saveSession({
    required String token,
    required Map<String, dynamic> user,
  }) async {
    final box = await _box();
    await box.put('token', token);
    await box.put('user', user);
  }

  Future<AuthSession?> getSession() async {
    final box = await _box();
    final token = box.get('token');
    final user = box.get('user');

    if (token == null || user == null) return null;

    return AuthSession(
      accessToken: token,
      user: AuthUser.fromJson(Map<String, dynamic>.from(user)),
    );
  }

  Future<void> clear() async {
    final box = await _box();
    await box.clear();
  }
}
