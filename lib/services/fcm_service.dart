import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'token_storage.dart';
import 'dart:convert';

class FcmService {

  static Future<void> enviarTokenParaBackend(int usuarioId) async {

    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    final String? token = await messaging.getToken();

    if (token == null) {
      print("FCM: token nulo");
      return;
    }

    print("FCM: token obtido -> $token");

    try {

      final authToken = await TokenStorage.obterToken();

      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/usuarios/fcm-token"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $authToken",
        },
        body: jsonEncode({
          "usuarioId": usuarioId,
          "token": token,
        }),
      );

      print("FCM: status backend -> ${response.statusCode}");

    } catch (e) {
      print("FCM: erro ao enviar token -> $e");
    }
  }
}