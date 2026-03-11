import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import '../models/documento.dart';
import 'token_storage.dart';
import '../config/api_config.dart';

class DocumentService {

  // LISTAR DOCUMENTOS
  static Future<List<Documento>> listarDocumentos() async {

    final token = await TokenStorage.obterToken();

    if (token == null) {
      throw Exception("Usuário não autenticado");
    }

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/documentos"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
    );

    if (response.statusCode == 200) {

      List jsonList = jsonDecode(response.body);

      return jsonList.map((doc) => Documento.fromJson(doc)).toList();

    } else if (response.statusCode == 401 || response.statusCode == 400) {

      await TokenStorage.removerToken();
      throw Exception("TOKEN_INVALIDO");

    } else {

      throw Exception("Erro ao carregar documentos");

    }
  }

  // UPLOAD DOCUMENTO
  static Future<void> uploadDocumento({
    required PlatformFile arquivo,
    required String nome,
    required String descricao,
    required String categoria,
    String? dataVencimento,
  }) async {

    final token = await TokenStorage.obterToken();

    if (token == null) {
      throw Exception("Usuário não autenticado");
    }

    var request = http.MultipartRequest(
      "POST",
      Uri.parse("${ApiConfig.baseUrl}/documentos"),
    )..headers.addAll({
      "Authorization": "Bearer $token"
    });

    if (arquivo.bytes != null) {

      request.files.add(
        http.MultipartFile.fromBytes(
          "file",
          arquivo.bytes!,
          filename: arquivo.name,
        ),
      );

    } else if (arquivo.path != null) {

      request.files.add(
        await http.MultipartFile.fromPath(
          "file",
          arquivo.path!,
          filename: arquivo.name,
        ),
      );

    } else {

      throw Exception("Arquivo inválido");

    }

    request.fields["nome"] = nome;
    request.fields["descricao"] = descricao;
    request.fields["categoria"] = categoria;

    if (dataVencimento != null) {
      request.fields["dataVencimento"] = dataVencimento;
    }

    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {

      return;

    } else if (response.statusCode == 401 || response.statusCode == 400) {

      await TokenStorage.removerToken();
      throw Exception("TOKEN_INVALIDO");

    } else {

      throw Exception("Erro ao enviar documento: ${response.statusCode}");

    }
  }

  // ATUALIZAR DOCUMENTO
  static Future<void> atualizarDocumento({
    required int id,
    required String nome,
    required String descricao,
    required String categoria,
    String? dataVencimento,
  }) async {

    final token = await TokenStorage.obterToken();

    if (token == null) {
      throw Exception("Usuário não autenticado");
    }

    final response = await http.put(
      Uri.parse("${ApiConfig.baseUrl}/documentos/$id"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "nome": nome,
        "descricao": descricao,
        "categoria": categoria,
        "dataVencimento": dataVencimento
      }),
    );

    if (response.statusCode == 200) {

      return;

    } else if (response.statusCode == 401 || response.statusCode == 400) {

      await TokenStorage.removerToken();
      throw Exception("TOKEN_INVALIDO");

    } else {

      throw Exception("Erro ao atualizar documento");

    }
  }

  // DELETAR DOCUMENTO
  static Future<void> deletarDocumento(int id, String token) async {

    final response = await http.delete(
      Uri.parse("${ApiConfig.baseUrl}/documentos/$id"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
    );

    if (response.statusCode == 204) {

      return;

    } else if (response.statusCode == 401 || response.statusCode == 400) {

      await TokenStorage.removerToken();
      throw Exception("TOKEN_INVALIDO");

    } else {

      throw Exception("Erro ao deletar documento");

    }
  }

  // NOVO MÉTODO: DOWNLOAD POR STREAM (MAIS RÁPIDO)
  static Future<Uint8List> baixarDocumento(String caminhoArquivo) async {

    final token = await TokenStorage.obterToken();

    if (token == null) {
      throw Exception("Usuário não autenticado");
    }

    final request = http.Request(
      "GET",
      Uri.parse("${ApiConfig.baseUrl}/documentos/download/$caminhoArquivo"),
    );

    request.headers.addAll({
      "Authorization": "Bearer $token"
    });

    final streamedResponse = await request.send();

    if (streamedResponse.statusCode != 200) {
      throw Exception("Erro ao baixar documento");
    }

    final bytes = await streamedResponse.stream.toBytes();

    return bytes;
  }
}