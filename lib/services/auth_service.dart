import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {

  static const String baseUrl = "http://127.0.0.1:8080";

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