import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/app_background.dart';
import '../services/document_service.dart';
import '../models/documento.dart';

class DocumentListScreen extends StatefulWidget {
  const DocumentListScreen({super.key});

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {

  // TOKEN FIXO TEMPORÁRIO
  final String token = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJqYXF1ZUBlbWFpbC5jb20iLCJpYXQiOjE3NzI5NDMxMDcsImV4cCI6MTc3Mjk0NjcwN30.XNV7tQ8eIfO_v7MgTH6yW9Mo_EXdjkvbmeEuEmTyppg";

  late Future<List<Documento>> documentosFuture;

  @override
  void initState() {
    super.initState();
    documentosFuture = DocumentService.listarDocumentos(token);
  }

  // FUNÇÃO PARA ABRIR O DOCUMENTO
  Future<void> abrirDocumento(String caminhoArquivo) async {

    final url = Uri.parse(
        "http://127.0.0.1:8080/documentos/visualizar/$caminhoArquivo"
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw Exception("Não foi possível abrir o documento");
    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.transparent,

      appBar: AppBar(
        title: const Text(
          "Meus Documentos",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0B0F1A),
        elevation: 0,
      ),

      body: AppBackground(

        child: FutureBuilder<List<Documento>>(

          future: documentosFuture,

          builder: (context, snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  "Erro ao carregar documentos",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            final documentos = snapshot.data!;

            if (documentos.isEmpty) {
              return const Center(
                child: Text(
                  "Nenhum documento cadastrado",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return ListView.builder(

              padding: const EdgeInsets.all(16),

              itemCount: documentos.length,

              itemBuilder: (context, index) {

                final doc = documentos[index];

                return Card(

                  color: const Color(0xFF1F2937),

                  margin: const EdgeInsets.only(bottom: 12),

                  child: ListTile(

                    leading: const Icon(
                      Icons.description,
                      color: Colors.white,
                    ),

                    title: Text(
                      doc.nome,
                      style: const TextStyle(color: Colors.white),
                    ),

                    subtitle: Text(
                      doc.categoria,
                      style: const TextStyle(color: Colors.white70),
                    ),

                    onTap: () {
                      abrirDocumento(doc.caminhoArquivo);
                    },

                  ),

                );

              },

            );

          },

        ),

      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),

    );
  }
}