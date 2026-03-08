import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_storage.dart';

class AuthService {

  static const String baseUrl = "http://127.0.0.1:8080";

  // LOGIN
  static Future<void> login(String email, String senha) async {

    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "email": email,
        "senha": senha
      }),
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      final token = data["token"];

      if (token == null) {
        throw Exception("Token não recebido do backend");
      }

      print("TOKEN RECEBIDO DO LOGIN: $token");

      // SALVA TOKEN
      await TokenStorage.salvarToken(token);

      // CONFIRMA QUE FOI SALVO
      final tokenSalvo = await TokenStorage.obterToken();
      print("TOKEN SALVO NO STORAGE: $tokenSalvo");

    } else {

      throw Exception("Erro ao fazer login: ${response.body}");

    }
  }

  // RECUPERAR SENHA
  static Future<Map<String, dynamic>> forgotPassword(String email) async {

    final response = await http.post(
      Uri.parse("$baseUrl/auth/forgot-password?email=$email"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erro ao enviar código");
    }
  }

  // RESETAR SENHA
  static Future<Map<String, dynamic>> resetPassword(
      String email,
      String codigo,
      String novaSenha,
      ) async {

    final response = await http.post(
      Uri.parse(
        "$baseUrl/auth/reset-password?email=$email&codigo=$codigo&novaSenha=$novaSenha",
      ),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erro ao redefinir senha");
    }
  }

}