import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {

  static const _storage = FlutterSecureStorage();
  static const _tokenKey = "auth_token";

  static Future<void> salvarToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> obterToken() async {

    final token = await _storage.read(key: _tokenKey);

    print("TOKEN RECUPERADO: $token");

    return token;
  }

  static Future<void> removerToken() async {
    await _storage.delete(key: _tokenKey);
  }

}