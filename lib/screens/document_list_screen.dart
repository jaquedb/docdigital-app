import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/app_background.dart';
import '../services/document_service.dart';
import '../services/token_storage.dart';
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

  Future<void> carregarDocumentos() async {

    final token = await TokenStorage.obterToken();

    if (token == null) return;

    setState(() {
      documentosFuture = DocumentService.listarDocumentos();
    });
  }

  Future<void> logout() async {

    await TokenStorage.removerToken();

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/login');
  }

  IconData obterIconeCategoria(String categoria) {

    switch (categoria) {

      case "DOCUMENTO_PESSOAL":
        return Icons.person;

      case "DOCUMENTO_VEICULAR":
        return Icons.directions_car;

      case "DOCUMENTO_ACADEMICO":
        return Icons.school;

      case "COMPROVANTE_PAGAMENTO":
        return Icons.payments;

      case "NOTA_FISCAL":
        return Icons.receipt;

      case "CONTRATO":
        return Icons.description;

      case "EXAME_MEDICO":
        return Icons.local_hospital;

      case "RECEITUARIO_MEDICO":
        return Icons.medical_services;

      default:
        return Icons.folder;
    }
  }

  String obterNomeCategoria(String categoria) {

    switch (categoria) {

      case "DOCUMENTO_PESSOAL":
        return "Documento pessoal";

      case "DOCUMENTO_VEICULAR":
        return "Documento veicular";

      case "DOCUMENTO_ACADEMICO":
        return "Documento acadêmico";

      case "COMPROVANTE_PAGAMENTO":
        return "Comprovante de pagamento";

      case "NOTA_FISCAL":
        return "Nota fiscal";

      case "CONTRATO":
        return "Contrato";

      case "EXAME_MEDICO":
        return "Exame médico";

      case "RECEITUARIO_MEDICO":
        return "Receituário médico";

      default:
        return "Outros";
    }
  }

  String formatarData(String dataIso) {

    final data = DateTime.parse(dataIso);

    return "${data.day.toString().padLeft(2,'0')}/"
        "${data.month.toString().padLeft(2,'0')}/"
        "${data.year}";
  }

  bool ehImagem(String tipoArquivo) {

    return tipoArquivo.contains("image");
  }

  Future<void> abrirDocumento(String caminhoArquivo) async {

    final url = Uri.parse(
      "http://127.0.0.1:8080/documentos/visualizar/$caminhoArquivo",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> abrirTelaAdicionar() async {

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddDocumentScreen(),
      ),
    );

    await carregarDocumentos();
  }

  Widget construirPreview(Documento doc) {

    final url =
        "http://127.0.0.1:8080/documentos/visualizar/${doc.caminhoArquivo}";

    if (ehImagem(doc.tipoArquivo)) {

      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          url,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        ),
      );

    } else {

      return const Icon(
        Icons.picture_as_pdf,
        size: 40,
        color: Colors.redAccent,
      );
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          )
        ],
      ),

      body: AppBackground(

        child: FutureBuilder<List<Documento>>(
          future: documentosFuture,

          builder: (context, snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) {

              return const Center(child: CircularProgressIndicator());
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

                    leading: construirPreview(doc),

                    title: Text(
                      doc.nome,
                      style: const TextStyle(color: Colors.white),
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          obterNomeCategoria(doc.categoria),
                          style: const TextStyle(color: Colors.white70),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          "📅 Enviado em ${formatarData(doc.dataUpload)}",
                          style: const TextStyle(color: Colors.white54),
                        ),

                        if (doc.dataVencimento != null)
                          Text(
                            "⏳ Vence em ${formatarData(doc.dataVencimento!)}",
                            style: const TextStyle(
                              color: Colors.orangeAccent,
                            ),
                          ),
                      ],
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