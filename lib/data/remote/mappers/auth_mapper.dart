import '../../models/user.dart';

class AuthMapper {
  static User toUser(Map<String, dynamic> json) {
    return User(
      id: json["id"].toString(),
      email: json["email"] as String,
      name: json["name"] as String?,
    );
  }
}
