class RegisterRequestDto {
  final String email;
  final String password;
  final String? name;

  RegisterRequestDto({required this.email, required this.password, this.name});

  Map<String, dynamic> toJson() => {
    "email": email,
    "password": password,
    if (name != null) "name": name,
  };
}

class LoginRequestDto {
  final String email;
  final String password;

  LoginRequestDto({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    "email": email,
    "password": password,
  };
}

class AuthResponseDto {
  final String accessToken;
  final String? refreshToken;
  final Map<String, dynamic> user; // raw json

  AuthResponseDto({
    required this.accessToken,
    required this.user,
    this.refreshToken,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      accessToken: json["accessToken"] as String,
      refreshToken: json["refreshToken"] as String?,
      user: (json["user"] as Map).cast<String, dynamic>(),
    );
  }
}
