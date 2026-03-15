import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_storage.dart';
import '../config/api_config.dart';

class AuthService {

  static String? nomeUsuario;

  // LOGIN
  static Future<void> login(String email, String senha) async {

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/auth/login"),
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
      final nome = data["nome"];

      if (token == null) {
        throw Exception("Token não recebido do backend");
      }

      print("TOKEN RECEBIDO DO LOGIN: $token");

      // SALVA TOKEN
      await TokenStorage.salvarToken(token);

      // SALVA NOME DO USUÁRIO
      if (nome != null) {
        nomeUsuario = nome;
        await TokenStorage.salvarNome(nome);
      }

      // CONFIRMA QUE FOI SALVO
      final tokenSalvo = await TokenStorage.obterToken();
      print("TOKEN SALVO NO STORAGE: $tokenSalvo");

    } else {

      try {

        final data = jsonDecode(response.body);

        String mensagem = data["message"] ?? "Erro ao fazer login";

        if (mensagem.contains("Usuário não encontrado")) {
          throw Exception("Usuário não encontrado");
        }

        if (mensagem.contains("Senha")) {
          throw Exception("Senha incorreta");
        }

        throw Exception(mensagem);

      } catch (e) {

        throw Exception("Não foi possível realizar o login");

      }

    }
  }

  // REGISTRO DE USUÁRIO
  static Future<void> register(String nome, String email, String senha) async {

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/usuarios"),
      headers: {
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "nome": nome,
        "email": email,
        "senha": senha
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Erro ao criar usuário: ${response.body}");
    }

  }

  // RECUPERAR SENHA
  static Future<Map<String, dynamic>> forgotPassword(String email) async {

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/auth/forgot-password?email=$email"),
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
        "${ApiConfig.baseUrl}/auth/reset-password?email=$email&codigo=$codigo&novaSenha=$novaSenha",
      ),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erro ao redefinir senha");
    }
  }

}