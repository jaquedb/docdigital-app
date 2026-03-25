import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {

  static const _storage = FlutterSecureStorage();
  static const _tokenKey = "auth_token";
  static const _nomeKey = "auth_nome";
  static const _usuarioIdKey = "auth_usuario_id";

  static Future<void> salvarToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> obterToken() async {

    final token = await _storage.read(key: _tokenKey);

    print("TOKEN RECUPERADO: $token");

    return token;
  }

  static Future<void> salvarNome(String nome) async {
    await _storage.write(key: _nomeKey, value: nome);
  }

  static Future<String?> obterNome() async {

    final nome = await _storage.read(key: _nomeKey);

    print("NOME RECUPERADO: $nome");

    return nome;
  }

  static Future<void> removerToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _nomeKey);
  }

  static Future<void> salvarUsuarioId(String id) async {
    await _storage.write(key: _usuarioIdKey, value: id);
  }

  static Future<String?> obterUsuarioId() async {

    final id = await _storage.read(key: _usuarioIdKey);

    print("ID RECUPERADO: $id");

    return id;
  }

}