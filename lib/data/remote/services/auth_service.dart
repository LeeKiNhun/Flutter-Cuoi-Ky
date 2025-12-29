import 'package:dio/dio.dart';
import '../dtos/auth_dtos.dart';

class AuthService {
  final Dio _dio;
  AuthService(this._dio);

  Future<AuthResponseDto> register(RegisterRequestDto body) async {
    final res = await _dio.post("/auth/register", data: body.toJson());
    return AuthResponseDto.fromJson((res.data as Map).cast<String, dynamic>());
    // Nếu backend bọc data: {data:{...}} thì chỉnh tại đây
  }

  Future<AuthResponseDto> login(LoginRequestDto body) async {
    final res = await _dio.post("/auth/login", data: body.toJson());
    return AuthResponseDto.fromJson((res.data as Map).cast<String, dynamic>());
  }
}
