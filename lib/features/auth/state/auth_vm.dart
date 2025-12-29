import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../data/remote/services/auth_api.dart';
import '../../../data/repositories/auth_repository.dart';

enum AuthStatus { unknown, loading, unauthenticated, authenticated, error }

class AuthVm extends ChangeNotifier {
  final AuthApi authApi;
  final AuthRepository authRepo;

  AuthVm({required this.authApi, required this.authRepo});

  AuthStatus status = AuthStatus.unknown;
  String? errorMessage;
  AuthSession? session;

  Future<void> init() async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final cached = await authRepo.getSession();
      if (cached != null) {
        session = cached;
        status = AuthStatus.authenticated;
      } else {
        status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      status = AuthStatus.error;
      errorMessage = e.toString();
    }

    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final json = await authApi.login(username: username, password: password);
      final token = json['token']?.toString();
      if (token == null || token.isEmpty) throw Exception('Missing token');

      final userJson = <String, dynamic>{
        'id': 'fakestore',
        'email': '$username@demo.local', // fake email để hiển thị
        'name': username,
      };

      await authRepo.saveSession(token: token, user: userJson);

      session = AuthSession(
        accessToken: token,
        user: AuthUser.fromJson(userJson),
      );

      status = AuthStatus.authenticated;
    } on DioException catch (e) {
      status = AuthStatus.error;
      errorMessage = _dioMsg(e);
    } catch (e) {
      status = AuthStatus.error;
      errorMessage = e.toString();
    }

    notifyListeners();
  }

  Future<void> register(String username, String password) async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final created = await authApi.register(username: username, password: password);

      // FakeStore create user không trả token => login luôn để lấy token
      final json = await authApi.login(username: username, password: password);
      final token = json['token']?.toString();
      if (token == null || token.isEmpty) throw Exception('Missing token');

      final userJson = <String, dynamic>{
        'id': created['id']?.toString() ?? 'fakestore',
        'email': (created['email'] ?? '$username@demo.local').toString(),
        'name': username,
      };

      await authRepo.saveSession(token: token, user: userJson);

      session = AuthSession(
        accessToken: token,
        user: AuthUser.fromJson(userJson),
      );

      status = AuthStatus.authenticated;
    } on DioException catch (e) {
      status = AuthStatus.error;
      errorMessage = _dioMsg(e);
    } catch (e) {
      status = AuthStatus.error;
      errorMessage = e.toString();
    }

    notifyListeners();
  }

  Future<void> logout() async {
    await authRepo.clear();
    session = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  String _dioMsg(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final msg = data['message']?.toString() ?? data['error']?.toString();
      if (msg != null && msg.isNotEmpty) return msg;
    }
    return e.message ?? 'Network error';
  }
}
