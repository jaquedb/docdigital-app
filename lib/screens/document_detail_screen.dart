import 'package:flutter/material.dart';
import '../models/documento.dart';
import '../widgets/app_background.dart';
import '../services/token_storage.dart';
import '../services/document_service.dart';
import '../config/api_config.dart';
import 'add_document_screen.dart';
import 'pdf_viewer_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentDetailScreen extends StatelessWidget {

  final Documento documento;

  const DocumentDetailScreen({
    super.key,
    required this.documento,
  });

  String formatarData(String dataIso) {

    final data = DateTime.parse(dataIso);

    return "${data.day.toString().padLeft(2,'0')}/"
        "${data.month.toString().padLeft(2,'0')}/"
        "${data.year}";
  }

  bool ehImagem() {

    final tipo = documento.tipoArquivo.toLowerCase();
    final nome = documento.caminhoArquivo.toLowerCase();

    return tipo.contains("image") ||
        nome.endsWith(".png") ||
        nome.endsWith(".jpg") ||
        nome.endsWith(".jpeg");
  }

  bool ehPdf() {

    final tipo = documento.tipoArquivo.toLowerCase();
    final nome = documento.caminhoArquivo.toLowerCase();

    return tipo.contains("pdf") || nome.endsWith(".pdf");
  }

  void visualizarDocumento(BuildContext context) {

    final url =
        "${ApiConfig.baseUrl}/documentos/visualizar/${documento.caminhoArquivo}";

    if (ehPdf()) {

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfViewerScreen(
            url: url,
            nomeDocumento: documento.nome,
          ),
        ),
      );

    } else if (ehImagem()) {

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
            ),
            body: Center(
              child: InteractiveViewer(
                child: Image.network(url),
              ),
            ),
          ),
        ),
      );

    }
  }

  Future<void> baixarDocumento() async {

    final uri = Uri.parse(
      "${ApiConfig.baseUrl}/documentos/download/${documento.caminhoArquivo}",
    );

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> editarDocumento(BuildContext context) async {

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddDocumentScreen(documento: documento),
      ),
    );

    if (!context.mounted) return;

    Navigator.pop(context, true);
  }

  Future<void> excluirDocumento(BuildContext context) async {

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {

        return AlertDialog(
          title: const Text("Excluir documento"),
          content: const Text(
            "Tem certeza que deseja excluir este documento? Esta ação não pode ser desfeita.",
          ),
          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Cancelar"),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Excluir"),
            ),

          ],
        );
      },
    );

    if (confirmar != true) return;

    final token = await TokenStorage.obterToken();

    if (token == null) return;

    await DocumentService.deletarDocumento(documento.id!, token);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Documento excluído com sucesso"),
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {

    final url =
        "${ApiConfig.baseUrl}/documentos/visualizar/${documento.caminhoArquivo}";

    return AppBackground(

      child: Scaffold(

        backgroundColor: Colors.transparent,

        appBar: AppBar(
          title: const Text(
            "Detalhes do documento",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF0B0F1A),
          elevation: 0,
        ),

        body: SingleChildScrollView(

          child: Padding(

            padding: const EdgeInsets.all(20),

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                const SizedBox(height: 20),

                Center(

                  child: ehImagem()

                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      url,
                      height: 250,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.image,
                          size: 120,
                          color: Colors.white70,
                        );
                      },
                    ),
                  )

                      : ehPdf()

                      ? const Icon(
                    Icons.picture_as_pdf,
                    size: 120,
                    color: Colors.redAccent,
                  )

                      : const Icon(
                    Icons.insert_drive_file,
                    size: 120,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  documento.nome,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Categoria: ${documento.categoria}",
                  style: const TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 10),

                Text(
                  "Enviado em: ${formatarData(documento.dataUpload)}",
                  style: const TextStyle(color: Colors.white70),
                ),

                if (documento.dataVencimento != null)
                  Text(
                    "Vence em: ${formatarData(documento.dataVencimento!)}",
                    style: const TextStyle(color: Colors.orangeAccent),
                  ),

                const SizedBox(height: 40),

                Row(
                  children: [

                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.visibility),
                        label: const Text("VISUALIZAR"),
                        onPressed: () => visualizarDocumento(context),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.download),
                        label: const Text("BAIXAR"),
                        onPressed: baixarDocumento,
                      ),
                    ),

                  ],
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text("EDITAR"),
                    onPressed: () => editarDocumento(context),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text("EXCLUIR"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => excluirDocumento(context),
                  ),
                ),

                const SizedBox(height: 30),

              ],
            ),
          ),
        ),
      ),
    );
  }
}