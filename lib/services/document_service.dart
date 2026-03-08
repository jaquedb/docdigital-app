import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/documento.dart';

class DocumentService {

  static const String baseUrl = "http://127.0.0.1:8080";

  static Future<List<Documento>> listarDocumentos(String token) async {

    final response = await http.get(
      Uri.parse("$baseUrl/documentos"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
    );

    if (response.statusCode == 200) {

      List jsonList = jsonDecode(response.body);

      return jsonList.map((doc) => Documento.fromJson(doc)).toList();

    } else {

      throw Exception("Erro ao carregar documentos");

    }

  }

}