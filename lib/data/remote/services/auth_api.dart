import 'package:dio/dio.dart';

class AuthApi {
  AuthApi() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://fakestoreapi.com',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }

  late final Dio _dio;

  /// FakeStoreAPI login: POST /auth/login
  /// body: { "username": "...", "password": "..." }
  /// response: { "token": "..." }
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final res = await _dio.post(
      '/auth/login',
      data: {'username': username, 'password': password},
    );
    return (res.data as Map).cast<String, dynamic>();
  }

  /// FakeStoreAPI register: POST /users
  /// response: created user object (id,...)
  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    String email = 'demo@mail.com',
    String firstname = 'Demo',
    String lastname = 'User',
  }) async {
    final res = await _dio.post(
      '/users',
      data: {
        'email': email,
        'username': username,
        'password': password,
        'name': {'firstname': firstname, 'lastname': lastname},
        'address': {
          'city': 'HCM',
          'street': 'Street',
          'number': 1,
          'zipcode': '700000',
          'geolocation': {'lat': '0', 'long': '0'}
        },
        'phone': '0000000000',
      },
    );
    return (res.data as Map).cast<String, dynamic>();
  }
}
