import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_storage.dart';
import '../config/api_config.dart';
import 'fcm_service.dart';

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
      final id = data["id"];

      if (token == null) {
        throw Exception("Token não recebido do backend");
      }

      await TokenStorage.salvarToken(token);

      if (nome != null) {
        nomeUsuario = nome;
        await TokenStorage.salvarNome(nome);
      }

      if (id != null){
        await TokenStorage.salvarUsuarioId(id.toString());
      }

      if (id != null) {
        await FcmService.enviarTokenParaBackend(int.parse(id.toString()));
      }

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

        if (mensagem.contains("Email não verificado")) {
          throw Exception("Email não verificado. Verifique seu email.");
        }

        throw Exception(mensagem);

      } catch (e) {

        if (e is Exception) {
          rethrow;
        }

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

  // REENVIAR CÓDIGO
  static Future<void> reenviarCodigo(String email) async {

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/auth/reenviar-codigo?email=$email"),
    );

    if (response.statusCode != 200) {
      throw Exception("Erro ao reenviar código");
    }
  }

  // CONFIRMAR CADASTRO
  static Future<void> confirmarCadastro(String email, String codigo) async {

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/auth/confirmar-cadastro?email=$email&codigo=$codigo"),
    );

    if (response.statusCode != 200) {
      throw Exception("Erro ao confirmar cadastro");
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

      final body = response.body;

      if (body.isNotEmpty) {
        final data = jsonDecode(body);

        String mensagem = data["message"] ?? "Erro ao redefinir senha";

        throw Exception(mensagem);
      }

      throw Exception("Erro ao redefinir senha");
    }
  }
}