import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/app_background.dart';
import '../services/document_service.dart';
import '../models/documento.dart';
import 'add_document_screen.dart';

class DocumentListScreen extends StatefulWidget {
  const DocumentListScreen({super.key});

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {

  late Future<List<Documento>> documentosFuture;

  @override
  void initState() {
    super.initState();
    carregarDocumentos();
  }

  void carregarDocumentos() {
    documentosFuture = DocumentService.listarDocumentos();
  }

  // FUNÇÃO PARA ABRIR O DOCUMENTO
  Future<void> abrirDocumento(String caminhoArquivo) async {

    final url = Uri.parse(
      "http://127.0.0.1:8080/documentos/visualizar/$caminhoArquivo",
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

  Future<void> abrirTelaAdicionar() async {

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddDocumentScreen(),
      ),
    );

    // Atualiza a lista ao voltar
    setState(() {
      carregarDocumentos();
    });
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

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  "Nenhum documento cadastrado",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            final documentos = snapshot.data!;

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
        onPressed: abrirTelaAdicionar,
        child: const Icon(Icons.add),
      ),
    );
  }
}